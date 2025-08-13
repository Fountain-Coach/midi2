import XCTest
@testable import MIDI2

final class UmpHeader64Tests: XCTestCase {
    /// Verify packing/unpacking and packet composition.
    func testPackingUnpacking() throws {
        let group = try XCTUnwrap(Uint4(0x1))
        let status = try XCTUnwrap(Uint4(0x9))
        let channel = try XCTUnwrap(Uint4(0x3))

        let header = try XCTUnwrap(
            UmpHeader64(group: group, status: status, channel: channel, byte3: 0x12, byte4: 0x34)
        )

        XCTAssertEqual(header.messageType, 0x4)
        XCTAssertEqual(header.group, group)
        XCTAssertEqual(header.status, status)
        XCTAssertEqual(header.channel, channel)
        XCTAssertEqual(header.byte3, 0x12)
        XCTAssertEqual(header.byte4, 0x34)
        XCTAssertEqual(header.dataWordCount, 1)
        XCTAssertEqual(header.dataByteCount, 6)

        let packet = UmpPacket64(header: header, word1: 0x55667788)
        XCTAssertEqual(packet.header, header)
    }

    /// Ensure invalid status nibbles and message types are detected.
    func testInvalidFields() throws {
        let group = try XCTUnwrap(Uint4(0x1))
        let channel = try XCTUnwrap(Uint4(0x3))
        let badStatus = try XCTUnwrap(Uint4(0x7)) // < 8
        XCTAssertNil(UmpHeader64(group: group, status: badStatus, channel: channel, byte3: 0, byte4: 0))

        let badWord: UInt32 = 0x5000_0000
        XCTAssertNil(UmpHeader64(word: badWord))
    }
}
