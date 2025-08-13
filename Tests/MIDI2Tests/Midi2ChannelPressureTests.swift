import XCTest
@testable import MIDI2

final class Midi2ChannelPressureTests: XCTestCase {
    func testRoundTrip() {
        let group = Uint4(0x1)!
        let channel = Uint4(0x2)!
        let msg = Midi2ChannelPressure(group: group, channel: channel, pressure: 0x01020304)
        let packet = msg.ump()
        guard let parsed = Midi2ChannelPressure(ump: packet) else {
            return XCTFail("failed to parse packet")
        }
        XCTAssertEqual(parsed, msg)
    }

    func testInvalidStatusReturnsNil() {
        // create packet with wrong status nibble
        let word0 = UInt32(0x4 << 28) | UInt32(0x8 << 20)
        let packet = UmpPacket64(word0: word0, word1: 0)
        XCTAssertNil(Midi2ChannelPressure(ump: packet))
    }

    func testParsingThrowsForWrongMessageType() {
        let packet = UmpPacket64(word0: UInt32(0x5 << 28), word1: 0)
        XCTAssertThrowsError(try Midi2ChannelPressure(parsingUMP: packet))
    }
}
