import XCTest
@testable import MIDI2

final class MidiCiAckNakBodyTests: XCTestCase {
    func testRoundTripSysEx7() {
        let body = MidiCiAckNakBody(ack: true, statusCode: 2, message: "ok")
        let bytes = body.sysEx7Bytes()
        let parsed = MidiCiAckNakBody(sysEx7Bytes: bytes)
        XCTAssertEqual(parsed, body)
    }

    func testRoundTripSysEx8() {
        let body = MidiCiAckNakBody(ack: false, statusCode: 5, message: "err")
        let bytes = body.sysEx8Bytes()
        let parsed = MidiCiAckNakBody(sysEx8Bytes: bytes)
        XCTAssertEqual(parsed, body)
    }
}
