import XCTest
@testable import MIDI2

final class MidiCiPropertyExchangeBodyTests: XCTestCase {
    func testRoundTripSysEx7() {
        let body = MidiCiPropertyExchangeBody(command: .get, requestId: 1, encoding: .json, header: ["h": "v"], data: [1,2])
        let bytes = body.sysEx7Bytes()
        let parsed = MidiCiPropertyExchangeBody(sysEx7Bytes: bytes)
        XCTAssertEqual(parsed.command, body.command)
        XCTAssertEqual(parsed.requestId, body.requestId)
        XCTAssertEqual(parsed.encoding, body.encoding)
        XCTAssertEqual(parsed.header["h"], "v")
        XCTAssertEqual(parsed.data, [1,2])
    }

    func testRoundTripSysEx8() {
        let body = MidiCiPropertyExchangeBody(command: .getReply, requestId: 2, encoding: .binary, header: [:], data: [3,4,5])
        let bytes = body.sysEx8Bytes()
        let parsed = MidiCiPropertyExchangeBody(sysEx8Bytes: bytes)
        XCTAssertEqual(parsed.command, body.command)
        XCTAssertEqual(parsed.requestId, body.requestId)
        XCTAssertEqual(parsed.encoding, body.encoding)
        XCTAssertEqual(parsed.data, body.data)
    }
}
