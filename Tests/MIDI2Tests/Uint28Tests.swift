import XCTest
@testable import MIDI2

final class Uint28Tests: XCTestCase {
    func testRoundTrip() throws {
        let value: UInt32 = 0x0ABC_DEF
        let uint = try XCTUnwrap(Uint28(value))
        XCTAssertEqual(uint.rawValue, value)
    }

    func testError() {
        XCTAssertNil(Uint28(0x1_0000_000))
        XCTAssertThrowsError(try Uint28(validating: 0x1_0000_000))
    }

    func testFuzz() throws {
        for _ in 0..<1_000 {
            let raw = UInt32.random(in: 0...0x0FFF_FFFF)
            let uint = try Uint28(validating: raw)
            XCTAssertEqual(uint.rawValue, raw)
        }

        for _ in 0..<1_000 {
            let raw = UInt32.random(in: 0x1_0000_000...UInt32.max)
            XCTAssertNil(Uint28(raw))
            XCTAssertThrowsError(try Uint28(validating: raw))
        }
    }
}
