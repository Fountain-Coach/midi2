import XCTest
@testable import MIDI2

final class Uint14Tests: XCTestCase {
    func testRoundTrip() throws {
        let raw: UInt16 = 0x3FFF
        let uint = try XCTUnwrap(Uint14(raw))
        XCTAssertEqual(uint.rawValue, raw)
    }

    func testGoldenVectors() {
        XCTAssertEqual(Uint14(0x0000)?.rawValue, 0x0000)
        XCTAssertEqual(Uint14(0x3FFF)?.rawValue, 0x3FFF)
    }

    func testError() {
        XCTAssertNil(Uint14(0x4000))
        XCTAssertThrowsError(try Uint14(validating: 0x4000))
    }

    func testFuzz() throws {
        for _ in 0..<1_000 {
            let raw = UInt16.random(in: 0x0...0x3FFF)
            let uint = try Uint14(validating: raw)
            XCTAssertEqual(uint.rawValue, raw)
        }

        for _ in 0..<1_000 {
            let raw = UInt16.random(in: 0x4000...UInt16.max)
            XCTAssertNil(Uint14(raw))
            XCTAssertThrowsError(try Uint14(validating: raw))
        }
    }
}
