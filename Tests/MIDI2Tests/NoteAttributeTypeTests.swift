import XCTest
@testable import MIDI2

final class NoteAttributeTypeTests: XCTestCase {
    func testRoundTrip() throws {
        let raw: UInt8 = 0x7F
        let attr = try XCTUnwrap(NoteAttributeType(raw))
        XCTAssertEqual(attr.rawValue, raw)
    }

    func testGoldenVectors() {
        XCTAssertEqual(NoteAttributeType(0x00)?.rawValue, 0x00)
        XCTAssertEqual(NoteAttributeType(0x7F)?.rawValue, 0x7F)
    }

    func testError() {
        XCTAssertNil(NoteAttributeType(0x80))
        XCTAssertThrowsError(try NoteAttributeType(validating: 0x80))
    }

    func testFuzz() throws {
        for _ in 0..<1_000 {
            let raw = UInt8.random(in: 0x0...0x7F)
            let attr = try NoteAttributeType(validating: raw)
            XCTAssertEqual(attr.rawValue, raw)
        }

        for _ in 0..<1_000 {
            let raw = UInt8.random(in: 0x80...UInt8.max)
            XCTAssertNil(NoteAttributeType(raw))
            XCTAssertThrowsError(try NoteAttributeType(validating: raw))
        }
    }
}

