import XCTest
@testable import MIDI2

final class MidiCiProfilesBodyTests: XCTestCase {
    func testRoundTripSysEx7() {
        let body = MidiCiProfilesBody(command: .setOn, profileId: "com.example.profile", target: .group, channels: [Uint4(2)!])
        let bytes = body.sysEx7Bytes()
        let parsed = MidiCiProfilesBody(sysEx7Bytes: bytes)
        XCTAssertEqual(parsed.command, body.command)
        XCTAssertEqual(parsed.profileId, body.profileId)
        XCTAssertEqual(parsed.target, body.target)
        XCTAssertEqual(parsed.channels, body.channels)
    }

    func testRoundTripSysEx8() {
        let body = MidiCiProfilesBody(command: .reply, profileId: "com.example.profile", target: .channel, channels: [Uint4(1)!], details: ["v": 1])
        let bytes = body.sysEx8Bytes()
        let parsed = MidiCiProfilesBody(sysEx8Bytes: bytes)
        XCTAssertEqual(parsed.command, body.command)
        XCTAssertEqual(parsed.profileId, body.profileId)
        XCTAssertEqual(parsed.target, body.target)
        XCTAssertEqual(parsed.channels, body.channels)
        XCTAssertEqual(parsed.details?["v"], 1)
    }
}
