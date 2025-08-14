import XCTest
@testable import MIDI2

final class Midi2StatusNibbleTests: XCTestCase {
    func testRoundTrip() throws {
        for raw in 0x8...0xF {
            let nibble = try Midi2StatusNibble(validating: UInt8(raw))
            XCTAssertEqual(nibble.rawValue, UInt8(raw))
        }
    }

    func testGoldenVectors() {
        XCTAssertEqual(Midi2StatusNibble(0x8)?.rawValue, 0x8)
        XCTAssertEqual(Midi2StatusNibble(0xF)?.rawValue, 0xF)
    }

    func testInvalidValues() {
        XCTAssertNil(Midi2StatusNibble(0x7))
        XCTAssertThrowsError(try Midi2StatusNibble(validating: 0x7))
    }
}
