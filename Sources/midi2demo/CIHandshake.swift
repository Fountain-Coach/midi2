import ArgumentParser
import MIDI2
import MIDI2CI
import Foundation

struct CIHandshakeCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ci-handshake",
        abstract: "Simulate MIDI-CI protocol negotiation, profile inquiry, and property exchange.",
        discussion: "Runs a scripted interaction showing how MIDI-CI messages are exchanged. Flags allow simulating failure scenarios. See midi2demo(1) for background and examples."
    )

    @Flag(name: .long, help: "Simulate no common protocol during negotiation")
    var noCommonProtocol: Bool = false

    @Flag(name: .long, help: "Simulate profile not supported by responder")
    var unsupportedProfile: Bool = false

    @Flag(name: .long, help: "Simulate missing property value in exchange")
    var missingProperty: Bool = false

    @Flag(name: .long, help: "Demonstrate Property Exchange subscribe/notify flow")
    var peSubscribe: Bool = false

    @Flag(name: .long, help: "Use a large property value to trigger chunked GET replies")
    var peLarge: Bool = false

    @Flag(name: .long, help: "Simulate error on Set (reply ok=0)")
    var peErrorSet: Bool = false

    @Option(name: .long, help: "UMP group (0-15) for SysEx8 framing")
    var group: Int = 0

    func run() throws {
        // Device discovery (CI) – advertise device info
        let discovery = MidiCiDiscoveryBody(
            muid: 0x01020304,
            manufacturerId: [0x00, 0x20, 0x33],
            deviceFamily: 0x1234,
            deviceModel: 0x5678,
            softwareRev: 0x00010002,
            categories: .init(profiles: true, propertyExchange: true, processInquiry: true),
            maxSysEx: 1024
        )
        do { try discovery.validate() } catch { print("Discovery validation error: \(error)") }
        let ciPayload = discovery.sysEx8Bytes()
        print("Device Discovery (CI): sysEx8 bytes=\(ciPayload.map{String(format: "%02X", $0)}.joined(separator: " "))")
        if let parsed = MidiCiDiscoveryBody(sysEx8Bytes: ciPayload) {
            print(String(format: "Parsed MUID=0x%08X fam=0x%04X model=0x%04X rev=0x%08X maxSysEx=%u cats[p=%d,pe=%d,pi=%d]",
                         parsed.muid, parsed.deviceFamily, parsed.deviceModel, parsed.softwareRev, parsed.maxSysEx,
                         parsed.categories.profiles ? 1:0, parsed.categories.propertyExchange ? 1:0, parsed.categories.processInquiry ? 1:0))
        }

        // Protocol negotiation
        let initiatorSupported: [MidiCIProtocol] = noCommonProtocol ? [.midi2] : [.midi2, .midi1]
        let responderSupported: [MidiCIProtocol] = noCommonProtocol ? [.midi1] : [.midi2]

        let pnRequest = CIHandshake.initiateProtocolNegotiation(supported: initiatorSupported)
        print("Initiator -> Responder: \(pnRequest)")

        let pnResponse = CIHandshake.respond(to: pnRequest, supported: responderSupported)
        print("Responder -> Initiator: \(pnResponse)")
        if let accepted = pnResponse.acceptedProtocol {
            print("Agreed protocol: \(accepted)")
        } else {
            print("No common protocol accepted")
        }

        // Profile inquiry + enable/disable flow
        let profileID = "org.midi.profile.piano"
        let profileRequest = CIHandshake.initiateProfileInquiry(profile: profileID)
        print("Initiator -> Responder: \(profileRequest)")

        let profileResponse = CIHandshake.respond(to: profileRequest, supportedProfiles: unsupportedProfile ? [] : [profileID])
        print("Responder -> Initiator: \(profileResponse)")
        print("Profile \(profileID) supported: \(profileResponse.supported)")

        // Demonstrate enable/disable and details replies via Profiles session
        let session = ProfileSession(supportedProfiles: unsupportedProfile ? [] : ["/org.midi/piano"]) // use slash-prefixed ID for SysEx body
        let ch0 = [Uint4(0)!]
        // Enable
        for r in session.handle(MidiCiProfilesBody(command: .setOn, profileId: "/org.midi/piano", target: .channel, channels: ch0)) {
            print("Profiles -> \(r.command) details=\(r.details ?? [:])")
        }
        // Details inquiry
        for r in session.handle(MidiCiProfilesBody(command: .detailsInquiry, profileId: "/org.midi/piano", target: .channel, channels: ch0)) {
            if let d = r.details {
                let ver = d["ver"] ?? 0
                let cmL = UInt16(d["cmL"] ?? 0)
                let cmH = UInt16(d["cmH"] ?? 0)
                let mask = (cmH << 8) | cmL
                var list: [String] = []
                for ch in 0..<16 { if (mask & (1 << ch)) != 0 { list.append(String(ch)) } }
                print("Profiles -> detailsReply ver=\(ver) channels=\(list.joined(separator: ","))")
            } else {
                print("Profiles -> detailsReply (no details)")
            }
        }
        // Disable
        for r in session.handle(MidiCiProfilesBody(command: .setOff, profileId: "/org.midi/piano", target: .channel, channels: ch0)) {
            print("Profiles -> \(r.command) details=\(r.details ?? [:])")
        }

        // Profile Specific Data (PSD) roundtrip
        let psd = ProfileSpecificDataMessage(profileId: "/org.midi/piano", target: .channel, channels: ch0, data: [0x01, 0x02, 0x03])
        let psdBytes = psd.sysEx8Bytes()
        print("PSD SysEx8: \(psdBytes.map{String(format: "%02X", $0)}.joined(separator: " "))")
        if let parsedPSD = ProfileSpecificDataMessage(sysEx8Bytes: psdBytes) {
            print("PSD Decoded -> profile=\(parsedPSD.profileId) target=\(parsedPSD.target?.rawValue.description ?? "-") len=\(parsedPSD.data.count)")
        }

        // Property exchange (simple GET)
        let resource = "/device/manufacturer"
        let propertyRequest = CIHandshake.initiatePropertyGet(resource: resource)
        print("Initiator -> Responder: \(propertyRequest)")

        let properties = missingProperty ? [:] : [resource: "ACME Corp"]
        let propertyResponse = CIHandshake.respond(to: propertyRequest, properties: properties)
        print("Responder -> Initiator: \(propertyResponse)")
        if let value = propertyResponse.value {
            print("Property \(resource) value: \(value)")
        } else {
            print("Property \(resource) not found")
        }

        // Extended Property Exchange demo (subscribe/notify and/or chunked GET)
        if peSubscribe || peLarge || peErrorSet {
            print("\n-- Extended Property Exchange Demo --")
            let encoding: MidiCiPropertyExchangeBody.Encoding = .json
            let session: PropertyExchangeSession
            if peLarge {
                // preload a large value to demonstrate chunked GET
                let large = Array(0..<300).map { UInt8($0 & 0xFF) }
                session = PropertyExchangeSession(initialStore: [resource: large], maxDataPerMessage: 60, setAllowed: { _, _ in !peErrorSet })
            } else {
                session = PropertyExchangeSession(initialStore: [resource: Array("ACME Corp".utf8)], setAllowed: { _, _ in !peErrorSet })
            }

            if peSubscribe {
                let subReq = PropertyExchangeBuilder.makeSubscribe(resource: resource, requestId: 10, encoding: encoding)
                print("Initiator -> Responder: subscribe \(subReq.header)")
                let subReplies = session.handle(subReq)
                subReplies.forEach { print("Responder -> Initiator: \($0.command) \($0.header)") }

                // Simulate a property change by issuing a SET
                let newValue = peLarge ? Array(0..<300).map { UInt8((255 - $0) & 0xFF) } : Array("FOO Corp".utf8)
                let setReq = PropertyExchangeBuilder.makeSet(resource: resource, requestId: 11, encoding: encoding, data: newValue)
                print("Initiator -> Responder: set \(setReq.header) bytes=\(setReq.data.count)")
                let setReplies = session.handle(setReq)
                setReplies.forEach { reply in
                    if reply.command == .notify {
                        print("Responder -> Initiator: notify res=\(reply.header["res"] ?? "") bytes=\(reply.data.count)")
                    } else {
                        print("Responder -> Initiator: \(reply.command) \(reply.header)")
                    }
                }
            }

            // Perform a GET to demonstrate chunked replies (if large)
            let getReq = PropertyExchangeBuilder.makeGet(resource: resource, requestId: 12, encoding: encoding)
            print("Initiator -> Responder: get \(getReq.header)")
            let getReplies = session.handle(getReq)
            getReplies.enumerated().forEach { (idx, r) in
                print("Responder -> Initiator: getReply chunk#\(idx) offset=\(r.header["offset"] ?? "") len=\(r.header["length"] ?? "") more=\(r.header["more"] ?? "")")
            }
            // Reassemble on the initiator side
            let rx = PropertyExchangeTransaction(requestId: 12, resource: resource, encoding: encoding)
            var ok = false
            for r in getReplies { ok = try rx.ingest(reply: r) }
            print("Initiator: reassembled bytes=\(rx.buffer.count) done=\(ok)")

            // Show SysEx8 UMP framing for the first getReply
            if let first = getReplies.first {
                let env = MidiCiEnvelope(scope: .nonRealtime, subId2: 0x7C, version: 1, body: .propertyExchange(first))
                let payload = env.sysEx8Payload()
                if let groupNibble = Uint4(UInt8(group)) {
                    do {
                        let frames = try SysEx8.fragment(manufacturerID: [0x7E], payload: payload, group: groupNibble.rawValue)
                        print("SysEx8 UMP frames: \(frames.count), first=\(frames.first?.map { String(format: "%02X", $0) }.joined(separator: " ") ?? "-")")
                    } catch {
                        print("SysEx8 framing failed: \(error)")
                    }
                } else {
                    print("Invalid group \(group) for SysEx8 framing; skipping")
                }
            }
        }
    }
}
