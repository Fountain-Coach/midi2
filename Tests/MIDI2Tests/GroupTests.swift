import XCTest
@testable import MIDI2

final class GroupTests: XCTestCase {
    func testRoundTrip() throws {
        let group = try XCTUnwrap(Group(0x7))
        XCTAssertEqual(group.rawValue, 0x7)
    }

    func testError() {
        XCTAssertNil(Group(0x10))
        XCTAssertThrowsError(try Group(validating: 0x10))
    }

    func testFuzz() throws {
        for _ in 0..<1_000 {
            let raw = UInt8.random(in: 0...0xF)
            let group = try Group(validating: raw)
            XCTAssertEqual(group.rawValue, raw)
        }

        for _ in 0..<1_000 {
            let raw = UInt8.random(in: 0x10...UInt8.max)
            XCTAssertNil(Group(raw))
            XCTAssertThrowsError(try Group(validating: raw))
        }
    }
}
