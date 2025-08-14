import XCTest
@testable import MIDI2

final class Midi1ChannelVoiceBodyTests: XCTestCase {
    func testRoundTrip() throws {
        let g = Uint4(0)!
        let msg = Midi1ChannelVoiceMessage.noteOn(group: g, channel: Uint4(0)!, note: Uint7(0x3C)!, velocity: Uint7(0x40)!)
        let packet = msg.ump()
        XCTAssertEqual(packet.word, 0x20903C40)
        XCTAssertEqual(Midi1ChannelVoiceMessage(ump: packet), msg)
        XCTAssertEqual(try Midi1ChannelVoiceMessage(parsingUMP: packet), msg)

        let bytes = [UInt8](msg.midi1Bytes())
        XCTAssertEqual(bytes, [0x90, 0x3C, 0x40])
        XCTAssertEqual(Midi1ChannelVoiceMessage(midi1Bytes: bytes, group: g)?.midi1Bytes(), bytes)
        XCTAssertEqual(try Midi1ChannelVoiceMessage(parsingMidi1Bytes: bytes, group: g).midi1Bytes(), bytes)
    }

    func testInvalidMessageType() {
        let g = Uint4(0)!
        let packet = UmpPacket32(mt: 0x0, group: g, status: 0, data1: 0, data2: 0)
        XCTAssertNil(Midi1ChannelVoiceMessage(ump: packet))
        XCTAssertThrowsError(try Midi1ChannelVoiceMessage(parsingUMP: packet))
    }

    func testRangeEnforcement() {
        let g = Uint4(0)!
        let bytes: [UInt8] = [0x90, 0xFF, 0x40]
        XCTAssertNil(Midi1ChannelVoiceMessage(midi1Bytes: bytes, group: g))
        XCTAssertThrowsError(try Midi1ChannelVoiceMessage(parsingMidi1Bytes: bytes, group: g))
    }
}
