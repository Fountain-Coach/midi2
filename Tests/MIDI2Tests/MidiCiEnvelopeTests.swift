import XCTest
@testable import MIDI2

final class MidiCiEnvelopeTests: XCTestCase {
    func testRoundTripSysEx7() throws {
        let body = MidiCiProfilesBody(command: .inquiry, profileId: "com.example", target: .channel, channels: [Uint4(1)!])
        let env = MidiCiEnvelope(scope: .nonRealtime, subId2: 0x72, version: 1, body: .profiles(body))
        let payload = env.sysEx7Payload()
        let parsed = try MidiCiEnvelope(sysEx7Payload: payload)
        XCTAssertEqual(parsed, env)
    }

    func testRoundTripSysEx8() throws {
        let body = MidiCiPropertyExchangeBody(command: .get, requestId: 1, encoding: .json, header: ["res": "example"], data: [1,2,3])
        let env = MidiCiEnvelope(scope: .realtime, subId2: 0x7C, version: 1, body: .propertyExchange(body))
        let payload = env.sysEx8Payload()
        let parsed = try MidiCiEnvelope(sysEx8Payload: payload)
        XCTAssertEqual(parsed, env)
    }
}
