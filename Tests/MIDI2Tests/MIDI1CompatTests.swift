import XCTest
@testable import MIDI2

final class MIDI1CompatTests: XCTestCase {
    func testCanonicalSequences() {
        let g = Uint4(0)!
        let messages: [(Midi1ChannelVoiceMessage, UInt32)] = [
            (.noteOn(group: g, channel: Uint4(0)!, note: Uint7(0x3C)!, velocity: Uint7(0x40)!), 0x20903C40),
            (.noteOff(group: g, channel: Uint4(1)!, note: Uint7(0x3C)!, velocity: Uint7(0x00)!), 0x20813C00),
            (.polyPressure(group: g, channel: Uint4(2)!, note: Uint7(0x10)!, pressure: Uint7(0x20)!), 0x20A21020),
            (.controlChange(group: g, channel: Uint4(3)!, control: Uint7(0x07)!, value: Uint7(0x40)!), 0x20B30740),
            (.programChange(group: g, channel: Uint4(4)!, program: Uint7(0x22)!), 0x20C42200),
            (.channelPressure(group: g, channel: Uint4(5)!, pressure: Uint7(0x40)!), 0x20D54000),
            (.pitchBend(group: g, channel: Uint4(6)!, value: Uint14(0x2000)!), 0x20E60040)
        ]
        for (msg, word) in messages {
            let packet = msg.ump()
            XCTAssertEqual(packet.word, word)
            let decoded = Midi1ChannelVoiceMessage(ump: packet)
            XCTAssertEqual(decoded, msg)
            XCTAssertEqual(decoded?.midi1Bytes(), msg.midi1Bytes())
        }
    }

    func testRoundTripBytes() {
        let g = Uint4(0)!
        let sequences: [[UInt8]] = [
            [0x90, 0x3C, 0x40],
            [0x80, 0x3C, 0x00],
            [0xA2, 0x10, 0x20],
            [0xB3, 0x07, 0x40],
            [0xC4, 0x22],
            [0xD5, 0x40],
            [0xE6, 0x00, 0x40]
        ]
        for bytes in sequences {
            let msg = Midi1ChannelVoiceMessage(midi1Bytes: bytes, group: g)
            XCTAssertNotNil(msg)
            let packet = msg!.ump()
            let rt = Midi1ChannelVoiceMessage(ump: packet)
            XCTAssertEqual(rt?.midi1Bytes(), bytes)
        }
    }
}
