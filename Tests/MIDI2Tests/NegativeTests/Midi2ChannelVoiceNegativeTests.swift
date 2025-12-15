import XCTest
@testable import MIDI2

final class Midi2ChannelVoiceNegativeTests: XCTestCase {
    func testInvalidStatusNibbleReturnsNil() {
        // Status nibble 0x7 is undefined for MIDI 2.0 Channel Voice
        let word0: UInt32 = (0x4 << 28) | (0x0 << 24) | (0x7 << 20)
        let pkt = UmpPacket64(word0: word0, word1: 0)
        XCTAssertNotNil(Midi2ChannelVoiceBody(ump: pkt)) // structural parse succeeds
        XCTAssertNil(Midi2ChannelVoiceVariants(ump: pkt)) // typed variant rejects unknown status
    }

    func testNoteOnRejectsNoteAbove7Bit() {
        // note=0xFF should fail validation
        let word0: UInt32 = (0x4 << 28) | (0x0 << 24) | (0x9 << 20) | (0x0 << 16) | (0xFF << 8)
        let pkt = UmpPacket64(word0: word0, word1: 0)
        XCTAssertNil(Midi2NoteOn(ump: pkt))
    }

    func testPerNoteManagementRejectsInvalidNote() {
        // per-note management with note=0xFF
        let word0: UInt32 = (0x4 << 28) | (0x0 << 24) | (0xF << 20) | (0x0 << 16) | (0xFF << 8)
        let pkt = UmpPacket64(word0: word0, word1: 0)
        XCTAssertNil(Midi2PerNoteManagement(ump: pkt))
    }
}
