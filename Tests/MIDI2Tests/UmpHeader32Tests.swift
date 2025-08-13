import XCTest
@testable import MIDI2

final class UmpHeader32Tests: XCTestCase {
    /// Verify packing and unpacking of fields as well as composition with packet types.
    func testPackingUnpacking() throws {
        let group = try XCTUnwrap(Uint4(0x2))
        let header = try XCTUnwrap(
            UmpHeader32(messageType: 0x2, group: group, status: 0x90, byte1: 0x12, byte2: 0x34)
        )

        XCTAssertEqual(header.messageType, 0x2)
        XCTAssertEqual(header.group, group)
        XCTAssertEqual(header.status, 0x90)
        XCTAssertEqual(header.byte1, 0x12)
        XCTAssertEqual(header.byte2, 0x34)
        XCTAssertEqual(header.dataByteCount, 2)

        // Compose with UmpPacket32
        let packet32 = UmpPacket32(header: header)
        XCTAssertEqual(packet32.header, header)

        // Compose with Ump96
        let packet96 = Ump96(header: header, word1: 0x01020304, word2: 0x05060708)
        XCTAssertEqual(packet96.header, header)
    }

    /// Ensure invalid message types are rejected.
    func testInvalidMessageType() throws {
        let group = try XCTUnwrap(Uint4(0x1))
        XCTAssertNil(UmpHeader32(messageType: 0x6, group: group, status: 0x00, byte1: 0x00, byte2: 0x00))

        let word: UInt32 = 0x6000_0000
        XCTAssertNil(UmpHeader32(word: word))
    }
}
