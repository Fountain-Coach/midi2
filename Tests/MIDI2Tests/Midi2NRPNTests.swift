import XCTest
@testable import MIDI2

final class Midi2NRPNTests: XCTestCase {
    func testRoundTrip() throws {
        let group = Uint4(0x2)!
        let channel = Uint4(0x7)!
        let address = Midi2NRPNAddress(rawValue: 0x1234)!
        let value: UInt32 = 0xDEADBEEF
        let msg = Midi2NRPN(group: group, channel: channel, address: address, value: value)
        let pkt = msg.ump()
        let decoded = try Midi2NRPN(parsingUMP: pkt)
        XCTAssertEqual(decoded, msg)
    }

    func testEdgeCases() throws {
        let group = Uint4(0x0)!
        let channel = Uint4(0xF)!
        let minAddr = Midi2NRPNAddress(rawValue: 0x0000)!
        let min = Midi2NRPN(group: group, channel: channel, address: minAddr, value: 0)
        let decodedMin = try Midi2NRPN(parsingUMP: min.ump())
        XCTAssertEqual(decodedMin, min)

        let maxAddr = Midi2NRPNAddress(rawValue: 0x3FFF)!
        let max = Midi2NRPN(group: group, channel: channel, address: maxAddr, value: 0xFFFF_FFFF)
        let decodedMax = try Midi2NRPN(parsingUMP: max.ump())
        XCTAssertEqual(decodedMax, max)
    }

    func testDecodeFailure() {
        let group = Uint4(0x1)!
        let channel = Uint4(0x2)!
        let address = Midi2NRPNAddress(rawValue: 0x1234)!
        let value: UInt32 = 0x01020304
        let msg = Midi2NRPN(group: group, channel: channel, address: address, value: value)
        let pkt = msg.ump()
        let bad = UmpPacket64(word0: (pkt.word0 & ~0x00F00000) | UInt32(0x2 << 20), word1: pkt.word1)
        XCTAssertThrowsError(try Midi2NRPN(parsingUMP: bad))
        let badIndex = UmpPacket64(word0: pkt.word0 | 0x00000080, word1: pkt.word1)
        XCTAssertThrowsError(try Midi2NRPN(parsingUMP: badIndex))
    }
}
