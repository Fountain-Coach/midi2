import XCTest
@testable import MIDI2

final class Midi1ChannelVoiceBodyTests: XCTestCase {
    func testBodyEncodeDecode() throws {
        let g = Uint4(0)!
        let body = Midi1ChannelVoiceBody(statusNibble: .noteOn,
                                         channel: Uint4(0)!,
                                         noteNumber: Uint7(0x3C)!,
                                         velocity7: Uint7(0x40)!)
        let packet = body.ump(group: g)
        XCTAssertEqual(packet.word, 0x20903C40)
        XCTAssertEqual(Midi1ChannelVoiceBody(ump: packet), body)
        XCTAssertEqual(try Midi1ChannelVoiceBody(parsingUMP: packet), body)
    }

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

    func testRejectsReservedStatusNibble() {
        let g = Uint4(0)!
        let word = UmpPacket32(mt: 0x2, group: g, status: 0x70, data1: 0, data2: 0)
        XCTAssertNil(Midi1ChannelVoiceMessage(ump: word))
        XCTAssertThrowsError(try Midi1ChannelVoiceMessage(parsingUMP: word))
    }
}
