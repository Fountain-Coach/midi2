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
        // Status nibbles outside 0x8...0xE should be rejected
        XCTAssertNil(Midi1StatusNibble(0xF))
    }
}
