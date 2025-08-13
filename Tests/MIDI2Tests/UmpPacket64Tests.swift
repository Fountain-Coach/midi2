import XCTest
@testable import MIDI2

final class UmpPacket64Tests: XCTestCase {
    func testRoundTripWords() {
        let packet = UmpPacket64(word0: 0x11223344, word1: 0x55667788)
        let reconstructed = UmpPacket64(words: packet.words)
        XCTAssertEqual(reconstructed, packet)
    }

    func testHeader() {
        let headerWord: UInt32 = 0x41234567
        let packet = UmpPacket64(word0: headerWord, word1: 0x89ABCDEF)
        XCTAssertEqual(packet.header.word, headerWord)
    }

    func testInitInvalidCount() {
        XCTAssertNil(UmpPacket64(words: [0x1]))
        XCTAssertNil(UmpPacket64(words: [0x1, 0x2, 0x3]))
    }
}
