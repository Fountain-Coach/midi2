import XCTest
@testable import MIDI2

final class ByteArrayTests: XCTestCase {
    func testRoundTrip() throws {
        let raw: [UInt16] = [0x00, 0x7F, 0xFF]
        let arr = try XCTUnwrap(ByteArray(raw))
        XCTAssertEqual(arr.rawValue, [0x00, 0x7F, 0xFF])
    }

    func testError() {
        XCTAssertNil(ByteArray([0x100]))
        XCTAssertThrowsError(try ByteArray(validating: [0x100]))
    }

    func testFuzz() throws {
        for _ in 0..<100 {
            let length = Int.random(in: 0...50)
            let bytes = (0..<length).map { _ in UInt16.random(in: 0...0xFF) }
            let arr = try ByteArray(validating: bytes)
            XCTAssertEqual(arr.rawValue.count, length)
        }

        for _ in 0..<100 {
            let length = Int.random(in: 1...50)
            var bytes = (0..<(length - 1)).map { _ in UInt16.random(in: 0...0xFF) }
            bytes.append(UInt16.random(in: 0x100...UInt16.max))
            XCTAssertNil(ByteArray(bytes))
            XCTAssertThrowsError(try ByteArray(validating: bytes))
        }
    }
}
