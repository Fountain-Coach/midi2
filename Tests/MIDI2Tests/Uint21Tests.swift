import XCTest
@testable import MIDI2

final class Uint21Tests: XCTestCase {
    func testRoundTrip() throws {
        let value: UInt32 = 0x1A_BCDE
        let uint = try XCTUnwrap(Uint21(value))
        XCTAssertEqual(uint.rawValue, value)
    }

    func testError() {
        XCTAssertNil(Uint21(0x20_0000))
        XCTAssertThrowsError(try Uint21(validating: 0x20_0000))
    }

    func testFuzz() throws {
        for _ in 0..<1_000 {
            let raw = UInt32.random(in: 0...0x1F_FFFF)
            let uint = try Uint21(validating: raw)
            XCTAssertEqual(uint.rawValue, raw)
        }

        for _ in 0..<1_000 {
            let raw = UInt32.random(in: 0x20_0000...UInt32.max)
            XCTAssertNil(Uint21(raw))
            XCTAssertThrowsError(try Uint21(validating: raw))
        }
    }
}
