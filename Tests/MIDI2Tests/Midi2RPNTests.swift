import XCTest
@testable import MIDI2

final class Midi2RPNTests: XCTestCase {
    func testRoundTrip() throws {
        let group = Uint4(0x3)!
        let channel = Uint4(0x4)!
        let address = Midi2RPNAddress(rawValue: 0x2345)!
        let value: UInt32 = 0xCAFEBABE
        let msg = Midi2RPN(group: group, channel: channel, address: address, value: value)
        let pkt = msg.ump()
        let decoded = try Midi2RPN(parsingUMP: pkt)
        XCTAssertEqual(decoded, msg)
    }

    func testEdgeCases() throws {
        let group = Uint4(0x0)!
        let channel = Uint4(0x0)!
        let minAddr = Midi2RPNAddress(rawValue: 0x0000)!
        let min = Midi2RPN(group: group, channel: channel, address: minAddr, value: 0)
        let decodedMin = try Midi2RPN(parsingUMP: min.ump())
        XCTAssertEqual(decodedMin, min)

        let maxAddr = Midi2RPNAddress(rawValue: 0x3FFF)!
        let max = Midi2RPN(group: group, channel: channel, address: maxAddr, value: 0xFFFF_FFFF)
        let decodedMax = try Midi2RPN(parsingUMP: max.ump())
        XCTAssertEqual(decodedMax, max)
    }

    func testDecodeFailure() {
        let group = Uint4(0x1)!
        let channel = Uint4(0x2)!
        let address = Midi2RPNAddress(rawValue: 0x2345)!
        let value: UInt32 = 0x0A0B0C0D
        let msg = Midi2RPN(group: group, channel: channel, address: address, value: value)
        let pkt = msg.ump()
        let bad = UmpPacket64(word0: (pkt.word0 & ~0x00F00000) | UInt32(0x3 << 20), word1: pkt.word1)
        XCTAssertThrowsError(try Midi2RPN(parsingUMP: bad))
        let badBank = UmpPacket64(word0: pkt.word0 | 0x00008000, word1: pkt.word1)
        XCTAssertThrowsError(try Midi2RPN(parsingUMP: badBank))
    }
}
