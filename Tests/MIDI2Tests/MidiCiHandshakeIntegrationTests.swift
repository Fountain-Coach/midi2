import XCTest
@testable import MIDI2CI

final class MidiCiHandshakeIntegrationTests: XCTestCase {
    func testProtocolNegotiationFlow() {
        let request = CIHandshake.initiateProtocolNegotiation(supported: [.midi2, .midi1])
        let response = CIHandshake.respond(to: request, supported: [.midi2])
        XCTAssertEqual(response.acceptedProtocol, .midi2)
    }

    func testProfileInquiryFlow() {
        let request = CIHandshake.initiateProfileInquiry(profile: "com.example.profile")
        let response = CIHandshake.respond(to: request, supportedProfiles: ["com.example.profile"])
        XCTAssertTrue(response.supported)
    }

    func testPropertyExchangeFlow() {
        let request = CIHandshake.initiatePropertyGet(resource: "example")
        let response = CIHandshake.respond(to: request, properties: ["example": "value"])
        XCTAssertEqual(response.value, "value")
    }
}
