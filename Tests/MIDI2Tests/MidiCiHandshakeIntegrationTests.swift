import XCTest
@testable import MIDI2

final class MidiCiHandshakeIntegrationTests: XCTestCase {
    func testProfileInquiryFlow() throws {
        let requestBody = MidiCiProfilesBody(command: .inquiry, profileId: "com.example.profile", target: .channel, channels: [Uint4(0)!])
        let requestEnv = MidiCiEnvelope(scope: .nonRealtime, subId2: 0x72, version: 1, body: .profiles(requestBody))
        let reqPayload = requestEnv.sysEx7Payload()
        let parsedRequest = try MidiCiEnvelope(sysEx7Payload: reqPayload)
        guard case .profiles(let parsedBody) = parsedRequest.body else { return XCTFail("expected profiles body") }
        XCTAssertEqual(parsedBody.profileId, "com.example.profile")

        let responseBody = MidiCiProfilesBody(command: .reply, profileId: parsedBody.profileId, target: parsedBody.target, channels: parsedBody.channels)
        let responseEnv = MidiCiEnvelope(scope: .nonRealtime, subId2: 0x72, version: 1, body: .profiles(responseBody))
        let respPayload = responseEnv.sysEx7Payload()
        let parsedResponse = try MidiCiEnvelope(sysEx7Payload: respPayload)
        guard case .profiles(let respBody) = parsedResponse.body else { return XCTFail("expected profiles body") }
        XCTAssertEqual(respBody.command, .reply)
    }

    func testPropertyExchangeFlow() throws {
        let requestBody = MidiCiPropertyExchangeBody(command: .get, requestId: 1, encoding: .json, header: ["res": "example"], data: [])
        let requestEnv = MidiCiEnvelope(scope: .nonRealtime, subId2: 0x7C, version: 1, body: .propertyExchange(requestBody))
        let reqPayload = requestEnv.sysEx8Payload()
        let parsedRequest = try MidiCiEnvelope(sysEx8Payload: reqPayload)
        guard case .propertyExchange(let reqBody) = parsedRequest.body else { return XCTFail("expected property exchange body") }
        XCTAssertEqual(reqBody.requestId, 1)

        let responseBody = MidiCiPropertyExchangeBody(command: .getReply, requestId: reqBody.requestId, encoding: .json, header: ["res": "example"], data: [1])
        let responseEnv = MidiCiEnvelope(scope: .nonRealtime, subId2: 0x7C, version: 1, body: .propertyExchange(responseBody))
        let respPayload = responseEnv.sysEx8Payload()
        let parsedResponse = try MidiCiEnvelope(sysEx8Payload: respPayload)
        guard case .propertyExchange(let respBody) = parsedResponse.body else { return XCTFail("expected property exchange body") }
        XCTAssertEqual(respBody.command, .getReply)
        XCTAssertEqual(respBody.data, [1])
    }
}
