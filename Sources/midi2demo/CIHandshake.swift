import ArgumentParser
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

        // Property exchange
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
    }
}

