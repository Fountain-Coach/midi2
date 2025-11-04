import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class ProfileSpecificDataTests: XCTestCase {
    func testRoundTripSysEx8() {
        let msg = ProfileSpecificDataMessage(profileId: "/org.midi/piano", target: .channel, channels: [Uint4(0)!], data: [1,2,3,4])
        let bytes = msg.sysEx8Bytes()
        let parsed = ProfileSpecificDataMessage(sysEx8Bytes: bytes)
        XCTAssertEqual(parsed, msg)
    }

    func testRoundTripSysEx7() {
        let msg = ProfileSpecificDataMessage(profileId: "/org.midi/piano", target: .group, channels: [Uint4(2)!], data: [1,2,3])
        let bytes = msg.sysEx7Bytes()
        let parsed = ProfileSpecificDataMessage(sysEx7Bytes: bytes)
        XCTAssertEqual(parsed, msg)
    }
}

