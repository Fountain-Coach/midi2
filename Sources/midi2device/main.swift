import Foundation
#if canImport(CoreMIDI)
import CoreMIDI
#endif
import MIDI2
import MIDI2CI

#if canImport(CoreMIDI)

@MainActor
final class UMPDevice {
    private var client = MIDIClientRef()
    private var source = MIDIEndpointRef()
    private var destination = MIDIEndpointRef()
    private let streamSession = StreamNegotiationSession(responderCaps: .init())

    // Simple stateful sessions for CI flows
    private let profiles = ProfileSession(supportedProfiles: ["/org.midi/piano"]) // example profile
    private let peSession = PropertyExchangeSession(initialStore: [:], maxDataPerMessage: 80)
    private let piSession = ProcessInquirySession(filters: ["sysex": 1, "ci": 1])

    init() throws {
        try createClient()
        try createEndpoints()
        loadGtbContextIfPresent()
    }

    deinit {
        if source != 0 { MIDIEndpointDispose(source) }
        if destination != 0 { MIDIEndpointDispose(destination) }
        if client != 0 { MIDIClientDispose(client) }
    }

    private func createClient() throws {
        let status = MIDIClientCreate("MIDI2 Swift Device" as CFString, nil, nil, &client)
        guard status == noErr else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status)) }
    }

    private func createEndpoints() throws {
        var status = MIDISourceCreate(client, "MIDI2 Swift Device Source" as CFString, &source)
        guard status == noErr else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status)) }
        status = MIDIDestinationCreateWithProtocol(client, "MIDI2 Swift Device Dest" as CFString, ._2_0, &destination, { pktList, _ in
            UMPDevice.shared?.handleEventList(pktList)
        })
        guard status == noErr else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status)) }
    }

    /// Seed GTB allowed MTs from config if available (non-fatal).
    private func loadGtbContextIfPresent() {
        let path = FileManager.default.currentDirectoryPath + "/docs/config/gtb.context.json"
        guard FileManager.default.fileExists(atPath: path) else { return }
        do {
            let desc = try GtbDescriptor.load(from: URL(fileURLWithPath: path))
            try streamSession.negotiate(gtbDescriptor: desc)
        } catch {
            // Ignore failures; GTB enforcement remains disabled.
        }
    }

    // MARK: - Receive and handle

    private func handleEventList(_ list: UnsafePointer<MIDIEventList>) {
        var el = list.pointee
        withUnsafeMutablePointer(to: &el.packet) { pktPtr in
            var p = pktPtr
            for _ in 0..<el.numPackets {
                let time = p.pointee.timeStamp
                let wc = Int(p.pointee.wordCount)
                let words = withUnsafePointer(to: &p.pointee.words) { wp -> [UInt32] in
                    let base = UnsafeRawPointer(wp).assumingMemoryBound(to: UInt32.self)
                    var arr: [UInt32] = []
                    arr.reserveCapacity(wc)
                    for i in 0..<wc { arr.append(base[i]) }
                    return arr
                }
                // GTB ingress guard (no-op if no descriptor is loaded)
                try? streamSession.guardIncoming(words: words)
                process(words: words, hostTime: time)
                p = MIDIEventPacketNext(p)
            }
        }
    }

    private func process(words: [UInt32], hostTime: UInt64) {
        guard let first = words.first else { return }
        let mt = (first >> 28) & 0xF
        let group = UInt8((first >> 24) & 0xF)
        switch mt {
        case 0xF: // Stream messages (32-bit)
            for w in words { handleStream32(w, group: group, hostTime: hostTime) }
        case 0x5: // Data messages (SysEx8/MDS) – 128-bit groups
            // Split into 4-word packets
            var i = 0
            var packets: [UmpPacket128] = []
            while i + 3 < words.count {
                let raw: [UInt32] = Array(words[i..<(i+4)])
                if let pkt = UmpPacket128(words: raw) { packets.append(pkt) }
                i += 4
            }
            handleData128(packets, group: group, hostTime: hostTime)
        default:
            break
        }
    }

    private func handleStream32(_ word: UInt32, group: UInt8, hostTime: UInt64) {
        let pkt = UmpPacket32(word: word)
        guard let body = StreamBody(ump: pkt) else { return }
        switch body.opcode {
        case .streamConfigurationRequest, .streamConfigurationNotification:
            // Interpret as request if opcode is the request; reply with our capabilities
            var sc = StreamConfigurationMessage(opcode: body.opcode, data1: body.data1, data2: body.data2)
            if sc.isNotification == false {
                // Prepare a reply: switch opcode to notification and echo JR/proto selection
                sc.isNotification = true
                sendUMP32(StreamBody(opcode: .streamConfigurationNotification, data1: sc.data1, data2: sc.data2).ump(group: Uint4(group)!))
            }
        case .endpointDiscovery:
            // Echo back info as a reply (same fields)
            let ep = EndpointDiscoveryMessage(data1: body.data1, data2: body.data2)
            sendUMP32(StreamBody(opcode: .endpointDiscovery, data1: ep.data1, data2: ep.data2).ump(group: Uint4(group)!))
        default:
            break
        }
    }

    private func handleData128(_ packets: [UmpPacket128], group: UInt8, hostTime: UInt64) {
        guard !packets.isEmpty else { return }
        // Try SysEx8 reassembly
        if let body = DataMessageBody(sysex8Packets: packets) {
            switch body {
            case .sysex8(_, let data):
                handleSysEx8(data: data, group: group)
            default:
                break
            }
        }
    }

    private func handleSysEx8(data: [UInt8], group: UInt8) {
        // Parse CI envelope
        guard let env = try? MidiCiEnvelope(sysEx8Payload: data) else { return }
        switch env.body {
        case .profiles(let b):
            let replies = profiles.handle(b)
            for rep in replies {
                sendCIEnvelope(rep, group: group)
            }
        case .propertyExchange(let b):
            let replies = peSession.handle(b)
            for rep in replies { sendCIEnvelope(rep, group: group) }
        case .processInquiry(let b):
            if let rep = piSession.handle(b) { sendCIEnvelope(rep, group: group) }
        case .discovery(_):
            // Reply with our device advertisement
            let adv = MidiCiDiscoveryBody(
                muid: 0x0A0B0C0D,
                manufacturerId: [0x00, 0x20, 0x33],
                deviceFamily: 0x1234,
                deviceModel: 0x5678,
                softwareRev: 0x00010001,
                categories: .init(profiles: true, propertyExchange: true, processInquiry: true),
                maxSysEx: 2048
            )
            sendCIEnvelope(adv, group: group)
        case .ackNak(let a):
            _ = a
        }
    }

    private func sendCIEnvelope(_ body: MidiCiProfilesBody, group: UInt8) {
        let payload = body.sysEx8Bytes()
        sendSysEx8(payload, group: group)
    }
    private func sendCIEnvelope(_ body: MidiCiPropertyExchangeBody, group: UInt8) {
        let payload = body.sysEx8Bytes()
        sendSysEx8(payload, group: group)
    }
    private func sendCIEnvelope(_ body: MidiCiProcessInquiryBody, group: UInt8) {
        let payload = body.sysEx8Bytes()
        sendSysEx8(payload, group: group)
    }
    private func sendCIEnvelope(_ body: MidiCiDiscoveryBody, group: UInt8) {
        let payload = body.sysEx8Bytes()
        sendSysEx8(payload, group: group)
    }

    private func sendSysEx8(_ payload: [UInt8], group: UInt8) {
        // Use Universal Non-Real-Time 0x7E as manufacturer ID for CI
        let mfr: [UInt8] = [0x7E]
        do {
            let frames = try SysEx8.fragment(manufacturerID: mfr, payload: payload, group: group)
            for raw in frames {
                if let pkt = UmpPacket128(rawBytes: raw) { sendUMP128(pkt) }
            }
        } catch {
            // ignore
        }
    }

    private func sendUMP32(_ pkt: UmpPacket32) {
        try? streamSession.guardOutgoing(words: [pkt.word])
        var l = MIDIEventList()
        l.protocol = ._2_0
        withUnsafeMutablePointer(to: &l.packet) { p in
            p.pointee.timeStamp = 0
            p.pointee.wordCount = 1
            withUnsafeMutablePointer(to: &p.pointee.words) { wptr in
                let w = UnsafeMutableRawPointer(wptr).assumingMemoryBound(to: UInt32.self)
                w[0] = pkt.word
            }
        }
        MIDIReceivedEventList(source, &l)
    }

    private func sendUMP128(_ pkt: UmpPacket128) {
        // Build event list with 4 words
        let words = [pkt.word0, pkt.word1, pkt.word2, pkt.word3]
        try? streamSession.guardOutgoing(words: words)
        words.withUnsafeBufferPointer { buf in
            var l = MIDIEventList()
            l.protocol = ._2_0
            withUnsafeMutablePointer(to: &l.packet) { p in
                p.pointee.timeStamp = 0
                p.pointee.wordCount = 4
                withUnsafeMutablePointer(to: &p.pointee.words) { wptr in
                    let w = UnsafeMutableRawPointer(wptr).assumingMemoryBound(to: UInt32.self)
                    w[0] = buf[0]
                    w[1] = buf[1]
                    w[2] = buf[2]
                    w[3] = buf[3]
                }
            }
            MIDIReceivedEventList(source, &l)
        }
    }

    func run() {
        print("MIDI2 device online: source 'MIDI2 Swift Device Source', destination 'MIDI2 Swift Device Dest'")
        RunLoop.current.run()
    }
}

// Entry point
extension UMPDevice { static var shared: UMPDevice? }

do {
    let dev = try UMPDevice()
    UMPDevice.shared = dev
    dev.run()
} catch {
    fputs("Failed to start device: \(error)\n", stderr)
    exit(1)
}

#else
print("CoreMIDI not available on this platform.")
#endif
