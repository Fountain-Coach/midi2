import XCTest
@testable import MIDI2

final class Uint4Tests: XCTestCase {
    func testRoundTrip() throws {
        let raw: UInt8 = 0xF
        let uint = try XCTUnwrap(Uint4(raw))
        XCTAssertEqual(uint.rawValue, raw)
    }

    func testGoldenVectors() {
        XCTAssertEqual(Uint4(0x0)?.rawValue, 0x0)
        XCTAssertEqual(Uint4(0xF)?.rawValue, 0xF)
    }

    func testError() {
        XCTAssertNil(Uint4(0x10))
        XCTAssertThrowsError(try Uint4(validating: 0x10))
    }

    func testFuzz() throws {
        for _ in 0..<1_000 {
            let raw = UInt8.random(in: 0x0...0xF)
            let uint = try Uint4(validating: raw)
            XCTAssertEqual(uint.rawValue, raw)
        }

        for _ in 0..<1_000 {
            let raw = UInt8.random(in: 0x10...UInt8.max)
            XCTAssertNil(Uint4(raw))
            XCTAssertThrowsError(try Uint4(validating: raw))
        }
    }
}
