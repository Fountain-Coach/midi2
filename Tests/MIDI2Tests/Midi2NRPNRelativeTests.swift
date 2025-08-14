import XCTest
@testable import MIDI2

final class Midi2NRPNRelativeTests: XCTestCase {
    func testEncodingDecoding() throws {
        let group = Uint4(2)!
        let channel = Uint4(3)!
        let address = Midi2NRPNAddress(rawValue: 0x1234)!
        let delta: Swift.Int32 = -123_456
        let msg = Midi2NRPNRelative(group: group, channel: channel, address: address, delta: delta)
        let pkt = msg.ump()
        XCTAssertEqual(pkt.word0, 0x42532434)
        XCTAssertEqual(pkt.word1, 0xFFFE1DC0)
        let decoded = try Midi2NRPNRelative(parsingUMP: pkt)
        XCTAssertEqual(decoded, msg)
    }

    func testMalformed() {
        let group = Uint4(2)!
        let channel = Uint4(3)!
        let address = Midi2NRPNAddress(rawValue: 0x1234)!
        let msg = Midi2NRPNRelative(group: group, channel: channel, address: address, delta: 0)
        let pkt = msg.ump()
        // Corrupt message type
        let bad = UmpPacket64(word0: pkt.word0 & 0x0FFFFFFF, word1: pkt.word1)
        XCTAssertThrowsError(try Midi2NRPNRelative(parsingUMP: bad))
    }
}
