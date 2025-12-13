import Foundation
#if os(Linux)
import UMPALSA
import MIDI2
import MIDI2CI

struct GroupState {
    var profiles = ProfileSession(supportedProfiles: ["/org.midi/piano"]) // demo profile
    var pe = PropertyExchangeSession(initialStore: [:], maxDataPerMessage: 80)
    var pi = ProcessInquirySession(filters: ["noteOn": 1, "ci": 1])
    var fbProfiles: [UInt8: [String]] = [:]
}

var groups: [UInt8: GroupState] = [:]

@discardableResult
func sendUMP32(_ word: UInt32) -> Int32 {
    var w = [word]
    return ump_alsa_send(&w, 1, Int((word >> 24) & 0xF))
}

@discardableResult
func sendUMP128(_ pkt: UmpPacket128) -> Int32 {
    var words = pkt.words
    return words.withUnsafeMutableBufferPointer { buf in
        return ump_alsa_send(buf.baseAddress, 4, Int((pkt.word0 >> 24) & 0xF))
    }
}

// SysEx8 reassembly per group
var syx8Acc: [UInt8: [UmpPacket128]] = [:]

func handleSysEx8(group: UInt8, pkt128: UmpPacket128) {
    var arr = syx8Acc[group] ?? []
    arr.append(pkt128)
    if let body = DataMessageBody(sysex8Packets: arr) {
        // Completed message
        syx8Acc[group] = []
        switch body {
        case .sysex8(let mfr, let data):
            // Expect 0x7E for MIDI-CI
            guard (mfr.count == 1 && mfr[0] == 0x7E) || (mfr.count == 3 && mfr[0] == 0x00) else { return }
            do {
                let env = try MidiCiEnvelope(sysEx8Payload: data)
                var st = groups[group] ?? GroupState()
                switch env.body {
                case .profiles(let b):
                    // Hook: update FB profile associations if target is functionBlock
                    if b.target == .functionBlock, let fbIdxByte = b.channels?.first?.rawValue {
                        let fbIdx = UInt8(fbIdxByte)
                        let profileId = b.profileId
                        let enable = b.command == .setOn || b.command == .enabledReport
                        var set = Set(st.fbProfiles[fbIdx] ?? [])
                        if enable {
                            set.insert(profileId)
                        } else {
                            set.remove(profileId)
                        }
                        st.fbProfiles[fbIdx] = Array(set)
                    }
                    for rep in st.profiles.handle(b) {
                        let payload = rep.sysEx8Bytes()
                        if let frames = try? SysEx8.fragment(manufacturerID: [0x7E], payload: payload, group: Int(group)) {
                            for f in frames { if let p = UmpPacket128(words: f) { _ = sendUMP128(p) } }
                        }
                    }
                case .propertyExchange(let b):
                    for rep in st.pe.handle(b) {
                        let payload = rep.sysEx8Bytes()
                        if let frames = try? SysEx8.fragment(manufacturerID: [0x7E], payload: payload, group: Int(group)) {
                            for f in frames { if let p = UmpPacket128(words: f) { _ = sendUMP128(p) } }
                        }
                    }
                case .processInquiry(let b):
                    if let rep = st.pi.handle(b) {
                        let payload = rep.sysEx8Bytes()
                        if let frames = try? SysEx8.fragment(manufacturerID: [0x7E], payload: payload, group: Int(group)) {
                            for f in frames { if let p = UmpPacket128(words: f) { _ = sendUMP128(p) } }
                        }
                    }
                case .discovery(_):
                    // Reply with our device advert
                    let adv = MidiCiDiscoveryBody(
                        muid: 0x0A0B0C0D,
                        manufacturerId: [0x00, 0x20, 0x33],
                        deviceFamily: 0x1234,
                        deviceModel: 0x5678,
                        softwareRev: 0x00010001,
                        categories: .init(profiles: true, propertyExchange: true, processInquiry: true),
                        maxSysEx: 2048
                    )
                    let payload = adv.sysEx8Bytes()
                    if let frames = try? SysEx8.fragment(manufacturerID: [0x7E], payload: payload, group: Int(group)) {
                        for f in frames { if let p = UmpPacket128(words: f) { _ = sendUMP128(p) } }
                    }
                case .ackNak(_): break
                }
                groups[group] = st
            } catch {
                // ignore
            }
        default: break
        }
    } else {
        syx8Acc[group] = arr
    }
}

func handleStream32(group: UInt8, word: UInt32) {
    let pkt = UmpPacket32(word: word)
    guard let body = StreamBody(ump: pkt) else { return }
    // Track a minimal state for negotiated protocol if needed
    switch body.opcode {
    case .endpointDiscovery:
        // Echo a standard endpoint discovery reply
        var ep = EndpointDiscoveryMessage(majorVersion: 1, minorVersion: 0, maxGroups: 8)
        let reply = StreamBody(opcode: .endpointDiscovery, data1: ep.data1, data2: ep.data2).ump(group: Uint4(group)!)
        _ = sendUMP32(reply.word)
    case .streamConfigurationRequest, .streamConfigurationNotification:
        // If request, reply with notification and same JR/proto
        var sc = StreamConfigurationMessage(opcode: body.opcode, data1: body.data1, data2: body.data2)
        if sc.isNotification == false {
            sc.isNotification = true
            let reply = StreamBody(opcode: .streamConfigurationNotification, data1: sc.data1, data2: sc.data2).ump(group: Uint4(group)!)
            _ = sendUMP32(reply.word)
        }
    case .functionBlockDiscovery:
        // Provide FB info (two blocks of 4 groups starting at 0 then 4) with profile hints in metadata
        let fb1 = try? FunctionBlockInfoNotification(index: 0, firstGroup: 0, groupCount: 4, active: true, direction: .bidirectional, midi1Bandwidth: .unrestricted, uiHints: 0x10)
        let fb2 = try? FunctionBlockInfoNotification(index: 1, firstGroup: 4, groupCount: 4, active: true, direction: .output, midi1Bandwidth: .restrict31_25kbps, uiHints: 0x20)
        if let fb1 = fb1 { _ = sendUMP128(fb1.ump(group: Uint4(group)!)) }
        if let fb2 = fb2 { _ = sendUMP128(fb2.ump(group: Uint4(group)!)) }
        // Send Function Block names to mirror Figure 22 sequence (optional)
        let names: [(UInt8, String)] = [(0, "FB 0 (BiDir)"), (1, "FB 1 (Out)")]
        for (idx, name) in names {
            let nameBytes = Array(name.utf8).prefix(12)
            var bytesPadded = Array(nameBytes)
            while bytesPadded.count < 12 { bytesPadded.append(0) }
            let word0 = (UInt32(0xF) << 28) | (UInt32(group) << 24) | (UInt32(StreamOpcode.functionBlockNameNotification.rawValue) << 16)
            let word1 = (UInt32(idx) << 24) | (UInt32(bytesPadded[0]) << 16) | (UInt32(bytesPadded[1]) << 8) | UInt32(bytesPadded[2])
            let word2 = (UInt32(bytesPadded[3]) << 24) | (UInt32(bytesPadded[4]) << 16) | (UInt32(bytesPadded[5]) << 8) | UInt32(bytesPadded[6])
            let word3 = (UInt32(bytesPadded[7]) << 24) | (UInt32(bytesPadded[8]) << 16) | (UInt32(bytesPadded[9]) << 8) | UInt32(bytesPadded[10])
            let word4 = (UInt32(bytesPadded[11]) << 24)
            _ = sendUMP32(word0)
            _ = sendUMP32(word1)
            _ = sendUMP32(word2)
            _ = sendUMP32(word3)
            _ = sendUMP32(word4)
        }
    default:
        break
    }
}

// Main
if ump_alsa_open() != 0 {
    fputs("Failed to open ALSA UMP client\n", stderr)
    exit(1)
}

var words = [UInt32](repeating: 0, count: 4)
var cnt: Int32 = 0
var grp: Int32 = 0

while true {
    if ump_alsa_get_event(&words, &cnt, &grp) == 0 {
        let group = UInt8(grp)
        let mt = UInt8((words[0] >> 28) & 0xF)
        if mt == 0xF { handleStream32(group: group, word: words[0]) }
        else if mt == 0x5 && cnt >= 4 {
            if let pkt = UmpPacket128(words: words) { handleSysEx8(group: group, pkt128: pkt) }
        }
    } else {
        usleep(1000)
    }
}
#else
print("midi2umpd is Linux-only")
#endif
