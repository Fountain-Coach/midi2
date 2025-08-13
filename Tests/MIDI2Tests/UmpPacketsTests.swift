import XCTest
@testable import MIDI2

final class UmpPacketsTests: XCTestCase {
    func testUmp64RoundTrip() {
        let words: [UInt32] = [0x12345678, 0x9ABCDEF0]
        guard let packet = Ump64(words: words) else {
            XCTFail("Failed to create Ump64")
            return
        }
        XCTAssertEqual(packet.messageType, 0x1)
        XCTAssertEqual(packet.group, 0x2)
        XCTAssertEqual(packet.words, words)
        let bytes = packet.rawBytes
        XCTAssertEqual(bytes, [0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0])
        let decoded = Ump64(rawBytes: bytes)
        XCTAssertEqual(decoded?.words, words)
    }

    func testUmp96RoundTrip() {
        let words: [UInt32] = [0x12345678, 0x9ABCDEF0, 0x01020304]
        guard let packet = Ump96(words: words) else {
            XCTFail("Failed to create Ump96")
            return
        }
        XCTAssertEqual(packet.messageType, 0x1)
        XCTAssertEqual(packet.group, 0x2)
        XCTAssertEqual(packet.words, words)
        let bytes = packet.rawBytes
        XCTAssertEqual(bytes, [0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0, 0x01, 0x02, 0x03, 0x04])
        let decoded = Ump96(rawBytes: bytes)
        XCTAssertEqual(decoded?.words, words)
    }

    func testUmp128RoundTrip() {
        let words: [UInt32] = [0x12345678, 0x9ABCDEF0, 0x01020304, 0x55667788]
        guard let packet = Ump128(words: words) else {
            XCTFail("Failed to create Ump128")
            return
        }
        XCTAssertEqual(packet.messageType, 0x1)
        XCTAssertEqual(packet.group, 0x2)
        XCTAssertEqual(packet.words, words)
        let bytes = packet.rawBytes
        XCTAssertEqual(bytes, [0x12, 0x34, 0x56, 0x78,
                               0x9A, 0xBC, 0xDE, 0xF0,
                               0x01, 0x02, 0x03, 0x04,
                               0x55, 0x66, 0x77, 0x88])
        let decoded = Ump128(rawBytes: bytes)
        XCTAssertEqual(decoded?.words, words)
    }

    func testMalformedPackets() {
        // too few bytes
        XCTAssertNil(Ump64(rawBytes: [0x00, 0x01]))
        XCTAssertNil(Ump96(rawBytes: Array(repeating: 0x00, count: 8)))
        XCTAssertNil(Ump128(rawBytes: Array(repeating: 0x00, count: 12)))
    }
}
