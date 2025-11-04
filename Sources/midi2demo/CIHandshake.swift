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

        // Profile inquiry
        let profileID = "org.midi.profile.piano"
        let profileRequest = CIHandshake.initiateProfileInquiry(profile: profileID)
        print("Initiator -> Responder: \(profileRequest)")

        let profileResponse = CIHandshake.respond(to: profileRequest, supportedProfiles: unsupportedProfile ? [] : [profileID])
        print("Responder -> Initiator: \(profileResponse)")
        print("Profile \(profileID) supported: \(profileResponse.supported)")

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
