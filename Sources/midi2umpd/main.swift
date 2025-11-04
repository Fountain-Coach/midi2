import Foundation
#if os(Linux)
import UMPALSA
import MIDI2
import MIDI2CI

struct GroupState {
    var profiles = ProfileSession(supportedProfiles: ["/org.midi/piano"]) // demo profile
    var pe = PropertyExchangeSession(initialStore: [:], maxDataPerMessage: 80)
    var pi = ProcessInquirySession(filters: ["noteOn": 1, "ci": 1])
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
    switch body.opcode {
    case .endpointDiscovery:
        // Echo a standard endpoint discovery reply
        var ep = EndpointDiscoveryMessage(majorVersion: 1, minorVersion: 0, maxGroups: 8)
        let reply = StreamBody(opcode: .endpointDiscovery, data1: ep.data1, data2: ep.data2).ump(group: Uint4(group)!)
        _ = sendUMP32(reply.word)
    case .streamConfiguration:
        // If request (notification=false), reply with notification set and same JR/proto
        var sc = StreamConfigurationMessage(data1: body.data1, data2: body.data2)
        if sc.isNotification == false {
            sc.isNotification = true
            let reply = StreamBody(opcode: .streamConfiguration, data1: sc.data1, data2: sc.data2).ump(group: Uint4(group)!)
            _ = sendUMP32(reply.word)
        }
    case .functionBlock:
        // Provide a simple FB info (two blocks of 4 groups starting at 0 then 4)
        let fb1 = FunctionBlockMessage(index: 0, firstGroup: 0, groupCount: 4)
        let fb2 = FunctionBlockMessage(index: 1, firstGroup: 4, groupCount: 4)
        _ = sendUMP32(StreamBody(opcode: .functionBlock, data1: fb1.data1, data2: fb1.data2).ump(group: Uint4(group)!).word)
        _ = sendUMP32(StreamBody(opcode: .functionBlock, data1: fb2.data1, data2: fb2.data2).ump(group: Uint4(group)!).word)
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

