import XCTest
@testable import MIDI2

final class Uint8Tests: XCTestCase {
    func testRoundTrip() throws {
        let value: UInt16 = 0xAB
        let uint = try XCTUnwrap(Uint8(value))
        XCTAssertEqual(uint.rawValue, 0xAB)
    }

    func testError() {
        XCTAssertNil(Uint8(0x100))
        XCTAssertThrowsError(try Uint8(validating: 0x100))
    }

    func testFuzz() throws {
        for _ in 0..<1_000 {
            let raw = UInt16.random(in: 0...0xFF)
            let uint = try Uint8(validating: raw)
            XCTAssertEqual(uint.rawValue, UInt8(raw))
        }

        for _ in 0..<1_000 {
            let raw = UInt16.random(in: 0x100...UInt16.max)
            XCTAssertNil(Uint8(raw))
            XCTAssertThrowsError(try Uint8(validating: raw))
        }
    }
}
