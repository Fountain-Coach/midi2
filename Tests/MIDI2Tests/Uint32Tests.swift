import XCTest
@testable import MIDI2

final class Uint32Tests: XCTestCase {
    func testRoundTrip() throws {
        let value: UInt64 = 0xDEAD_BEEF
        let uint = try XCTUnwrap(Uint32(value))
        XCTAssertEqual(uint.rawValue, 0xDEAD_BEEF)
    }

    func testError() {
        XCTAssertNil(Uint32(0x1_0000_0000))
        XCTAssertThrowsError(try Uint32(validating: 0x1_0000_0000))
    }

    func testFuzz() throws {
        for _ in 0..<1_000 {
            let raw = UInt64.random(in: 0...0xFFFF_FFFF)
            let uint = try Uint32(validating: raw)
            XCTAssertEqual(uint.rawValue, UInt32(raw))
        }

        for _ in 0..<1_000 {
            let raw = UInt64.random(in: 0x1_0000_0000...UInt64.max)
            XCTAssertNil(Uint32(raw))
            XCTAssertThrowsError(try Uint32(validating: raw))
        }
    }
}
