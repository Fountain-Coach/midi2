import XCTest
@testable import MIDI2

final class UmpPacket128Tests: XCTestCase {
    func testRoundTripWords() {
        let packet = UmpPacket128(
            word0: 0x11223344,
            word1: 0x55667788,
            word2: 0x99AABBCC,
            word3: 0xDDEEFF00
        )
        let reconstructed = UmpPacket128(words: packet.words)
        XCTAssertEqual(reconstructed, packet)
    }

    func testHeader() {
        let headerWord: UInt32 = 0x51234567 // mt=0x5 SysEx8
        let packet = UmpPacket128(
            word0: headerWord,
            word1: 0x89ABCDEF,
            word2: 0x01234567,
            word3: 0x89ABCDEF
        )
        XCTAssertEqual(packet.header.word, headerWord)
    }

    func testInitInvalidCount() {
        XCTAssertNil(UmpPacket128(words: [0x1]))
        XCTAssertNil(UmpPacket128(words: [0x1, 0x2, 0x3]))
    }
}
