import XCTest
@testable import MIDI2

final class Midi2RPNRelativeTests: XCTestCase {
    func testEncodingDecoding() throws {
        let group = Uint4(1)!
        let channel = Uint4(2)!
        let address = Midi2RPNAddress(rawValue: 0x2345)!
        let delta: Swift.Int32 = 123
        let msg = Midi2RPNRelative(group: group, channel: channel, address: address, delta: delta)
        let pkt = msg.ump()
        XCTAssertEqual(pkt.word0, 0x41424645)
        XCTAssertEqual(pkt.word1, 123)
        let decoded = try Midi2RPNRelative(parsingUMP: pkt)
        XCTAssertEqual(decoded, msg)
    }

    func testMalformed() {
        let group = Uint4(1)!
        let channel = Uint4(2)!
        let address = Midi2RPNAddress(rawValue: 0x2345)!
        let msg = Midi2RPNRelative(group: group, channel: channel, address: address, delta: 0)
        let pkt = msg.ump()
        // Corrupt status nibble
        let bad = UmpPacket64(word0: (pkt.word0 & ~0x00F00000) | UInt32(0x5 << 20), word1: pkt.word1)
        XCTAssertThrowsError(try Midi2RPNRelative(parsingUMP: bad))
    }
}
