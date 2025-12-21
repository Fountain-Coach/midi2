import XCTest
@testable import MIDI2

final class UtilityOpcodeTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(UtilityOpcode.noop.rawValue, 0x0)
        XCTAssertEqual(UtilityOpcode.jrClock.rawValue, 0x1)
        XCTAssertEqual(UtilityOpcode.jrTimestamp.rawValue, 0x2)
        XCTAssertEqual(UtilityOpcode.dctpq.rawValue, 0x3)
        XCTAssertEqual(UtilityOpcode.deltaClockstamp.rawValue, 0x4)
    }

    func testInitFromRaw() {
        XCTAssertEqual(UtilityOpcode(rawValue: 0x0), .noop)
        XCTAssertEqual(UtilityOpcode(rawValue: 0x1), .jrClock)
        XCTAssertEqual(UtilityOpcode(rawValue: 0x2), .jrTimestamp)
        XCTAssertEqual(UtilityOpcode(rawValue: 0x3), .dctpq)
        XCTAssertEqual(UtilityOpcode(rawValue: 0x4), .deltaClockstamp)
        XCTAssertNil(UtilityOpcode(rawValue: 0x5))
    }
}
