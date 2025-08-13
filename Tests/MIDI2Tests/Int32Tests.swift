import XCTest
@testable import MIDI2

final class Int32Tests: XCTestCase {
    func testRoundTrip() throws {
        let value: Int64 = 123_456
        let int = try XCTUnwrap(MIDI2.Int32(value))
        XCTAssertEqual(int.rawValue, 123_456)
    }

    func testError() {
        XCTAssertNil(MIDI2.Int32(Int64(Swift.Int32.max) + 1))
        XCTAssertThrowsError(try MIDI2.Int32(validating: Int64(Swift.Int32.max) + 1))

        XCTAssertNil(MIDI2.Int32(Int64(Swift.Int32.min) - 1))
        XCTAssertThrowsError(try MIDI2.Int32(validating: Int64(Swift.Int32.min) - 1))
    }

    func testFuzz() throws {
        for _ in 0..<1_000 {
            let raw = Int64.random(in: Int64(Swift.Int32.min)...Int64(Swift.Int32.max))
            let int = try MIDI2.Int32(validating: raw)
            XCTAssertEqual(int.rawValue, Swift.Int32(raw))
        }

        for _ in 0..<1_000 {
            let raw = Int64.random(in: (Int64(Swift.Int32.max) + 1)...(Int64(Swift.Int32.max) + 1_000))
            XCTAssertNil(MIDI2.Int32(raw))
            XCTAssertThrowsError(try MIDI2.Int32(validating: raw))
        }

        for _ in 0..<1_000 {
            let raw = Int64.random(in: (Int64(Swift.Int32.min) - 1_000)...(Int64(Swift.Int32.min) - 1))
            XCTAssertNil(MIDI2.Int32(raw))
            XCTAssertThrowsError(try MIDI2.Int32(validating: raw))
        }
    }
}
