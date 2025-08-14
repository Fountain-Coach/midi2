import XCTest
@testable import MIDI2

final class Midi1StatusNibbleTests: XCTestCase {
    func testRoundTrip() {
        for raw in 0x8...0xE {
            let status = Midi1StatusNibble(UInt8(raw))
            XCTAssertNotNil(status)
            XCTAssertEqual(status?.rawValue, UInt8(raw))
        }
    }

    func testGoldenVectors() {
        XCTAssertEqual(Midi1StatusNibble(0x8), .noteOff)
        XCTAssertEqual(Midi1StatusNibble(0xE), .pitchBend)
    }

    func testInvalidValues() {
        XCTAssertNil(Midi1StatusNibble(0x7))
        XCTAssertNil(Midi1StatusNibble(0xF))
    }
}
