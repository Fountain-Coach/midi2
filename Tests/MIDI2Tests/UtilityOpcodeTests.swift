import XCTest
@testable import MIDI2

final class UtilityOpcodeTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(UtilityOpcode.noop.rawValue, 0x00)
        XCTAssertEqual(UtilityOpcode.jrClock.rawValue, 0x01)
        XCTAssertEqual(UtilityOpcode.jrTimestamp.rawValue, 0x02)
    }

    func testInitFromRaw() {
        XCTAssertEqual(UtilityOpcode(rawValue: 0x00), .noop)
        XCTAssertEqual(UtilityOpcode(rawValue: 0x01), .jrClock)
        XCTAssertEqual(UtilityOpcode(rawValue: 0x02), .jrTimestamp)
        XCTAssertNil(UtilityOpcode(rawValue: 0x03))
    }
}
