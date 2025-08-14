import ArgumentParser
import MIDI2CI
import Foundation

struct CIHandshakeCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ci-handshake",
        abstract: "Simulate MIDI-CI protocol negotiation, profile inquiry, and property exchange."
    )

    func run() throws {
        // Protocol negotiation
        let initiatorSupported: [MidiCIProtocol] = [.midi2, .midi1]
        let responderSupported: [MidiCIProtocol] = [.midi2]

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

        let profileResponse = CIHandshake.respond(to: profileRequest, supportedProfiles: [profileID])
        print("Responder -> Initiator: \(profileResponse)")
        print("Profile \(profileID) supported: \(profileResponse.supported)")

        // Property exchange
        let resource = "/device/manufacturer"
        let propertyRequest = CIHandshake.initiatePropertyGet(resource: resource)
        print("Initiator -> Responder: \(propertyRequest)")

        let properties = [resource: "ACME Corp"]
        let propertyResponse = CIHandshake.respond(to: propertyRequest, properties: properties)
        print("Responder -> Initiator: \(propertyResponse)")
        if let value = propertyResponse.value {
            print("Property \(resource) value: \(value)")
        } else {
            print("Property \(resource) not found")
        }
    }
}

