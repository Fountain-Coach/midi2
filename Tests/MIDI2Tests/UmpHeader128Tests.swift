import XCTest
@testable import MIDI2

final class UmpHeader128Tests: XCTestCase {
    func testPackingUnpacking() throws {
        let group = try XCTUnwrap(Uint4(0x1))
        let header = try XCTUnwrap(
            UmpHeader128(messageType: 0x5, group: group, status: 0x7F, byte3: 0x01, byte4: 0x02)
        )

        XCTAssertEqual(header.messageType, 0x5)
        XCTAssertEqual(header.group, group)
        XCTAssertEqual(header.status, 0x7F)
        XCTAssertEqual(header.byte3, 0x01)
        XCTAssertEqual(header.byte4, 0x02)
        XCTAssertEqual(header.dataWordCount, 3)
        XCTAssertEqual(header.dataByteCount, 14)

        let packet = Ump128(header: header, word1: 0x11111111, word2: 0x22222222, word3: 0x33333333)
        XCTAssertEqual(packet.header, header)
    }

    func testInvalidMessageType() throws {
        let group = try XCTUnwrap(Uint4(0x1))
        XCTAssertNil(UmpHeader128(messageType: 0x7, group: group, status: 0, byte3: 0, byte4: 0))

        let badWord: UInt32 = 0x7000_0000
        XCTAssertNil(UmpHeader128(word: badWord))
    }
}
