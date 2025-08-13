import XCTest
@testable import MIDI2

final class ChannelVoiceErrorTests: XCTestCase {
    func testNoteOnOutOfRangeNote() {
        let bytes: [UInt8] = [0x90, 0xFF, 0x40]
        let group = Uint4(0x0)!
        XCTAssertThrowsError(try Midi1ChannelVoiceMessage(parsingMidi1Bytes: bytes, group: group)) { error in
            XCTAssertEqual(error.localizedDescription, "Uint7 value 255 out of range 0...127")
        }
    }

    func testInvalidStatusNibble() {
        let bytes: [UInt8] = [0xF0, 0x00]
        let group = Uint4(0x0)!
        XCTAssertThrowsError(try Midi1ChannelVoiceMessage(parsingMidi1Bytes: bytes, group: group)) { error in
            XCTAssertTrue(error.localizedDescription.contains("invalid status nibble"))
        }
    }
}
