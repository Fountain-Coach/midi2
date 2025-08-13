import XCTest
@testable import MIDI2

final class Uint7Tests: XCTestCase {
    func testRoundTrip() throws {
        let raw: UInt8 = 0x7F
        let uint = try XCTUnwrap(Uint7(raw))
        XCTAssertEqual(uint.rawValue, raw)
    }

    func testGoldenVectors() {
        XCTAssertEqual(Uint7(0x00)?.rawValue, 0x00)
        XCTAssertEqual(Uint7(0x7F)?.rawValue, 0x7F)
    }

    func testError() {
        XCTAssertNil(Uint7(0x80))
        XCTAssertThrowsError(try Uint7(validating: 0x80))
    }

    func testFuzz() throws {
        for _ in 0..<1_000 {
            let raw = UInt8.random(in: 0x0...0x7F)
            let uint = try Uint7(validating: raw)
            XCTAssertEqual(uint.rawValue, raw)
        }

        for _ in 0..<1_000 {
            let raw = UInt8.random(in: 0x80...UInt8.max)
            XCTAssertNil(Uint7(raw))
            XCTAssertThrowsError(try Uint7(validating: raw))
        }
    }
}
