import XCTest
@testable import MIDI2

final class UmpMessageTypeTests: XCTestCase {
    /// Verify that known raw nibbles map to the expected enum cases.
    func testRawValueMapping() {
        XCTAssertEqual(UmpMessageType(rawValue: 0x0), .utility)
        XCTAssertEqual(UmpMessageType(rawValue: 0x1), .system)
        XCTAssertEqual(UmpMessageType(rawValue: 0x2), .midi1ChannelVoice)
        XCTAssertEqual(UmpMessageType(rawValue: 0x3), .sysEx7)
        XCTAssertEqual(UmpMessageType(rawValue: 0x4), .midi2ChannelVoice)
        XCTAssertEqual(UmpMessageType(rawValue: 0x5), .data)
        XCTAssertEqual(UmpMessageType(rawValue: 0xD), .flex)
        XCTAssertEqual(UmpMessageType(rawValue: 0xF), .stream)
    }

    /// Ensure invalid nibble values fail to initialise.
    func testInvalidNibbles() {
        let invalid: [UInt8] = [0x6, 0x7, 0x8, 0x9, 0xA, 0xB, 0xC, 0xE]
        for raw in invalid {
            XCTAssertNil(UmpMessageType(rawValue: raw), "Expected nil for 0x\(String(raw, radix: 16))")
        }
    }
}
