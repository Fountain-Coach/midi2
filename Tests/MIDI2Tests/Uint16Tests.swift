import XCTest
@testable import MIDI2

final class Uint16Tests: XCTestCase {
    func testRoundTrip() throws {
        let value: UInt32 = 0x1234
        let uint = try XCTUnwrap(Uint16(value))
        XCTAssertEqual(uint.rawValue, 0x1234)
    }

    func testError() {
        XCTAssertNil(Uint16(0x1_0000))
        XCTAssertThrowsError(try Uint16(validating: 0x1_0000))
    }

    func testFuzz() throws {
        for _ in 0..<1_000 {
            let raw = UInt32.random(in: 0...0xFFFF)
            let uint = try Uint16(validating: raw)
            XCTAssertEqual(uint.rawValue, UInt16(raw))
        }

        for _ in 0..<1_000 {
            let raw = UInt32.random(in: 0x1_0000...UInt32.max)
            XCTAssertNil(Uint16(raw))
            XCTAssertThrowsError(try Uint16(validating: raw))
        }
    }
}
