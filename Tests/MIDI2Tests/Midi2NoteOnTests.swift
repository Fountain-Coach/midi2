import XCTest
@testable import MIDI2

final class Midi2NoteOnTests: XCTestCase {
    func testRoundTrip() {
        let group = Uint4(0x1)!
        let channel = Uint4(0x2)!
        let note = Uint7(60)!
        let msg = Midi2NoteOn(group: group, channel: channel, note: note, velocity: 0x1234, attributeType: .none, attributeData: 0x5678)
        let packet = msg.ump()
        guard let parsed = Midi2NoteOn(ump: packet) else {
            return XCTFail("failed to parse packet")
        }
        XCTAssertEqual(parsed, msg)
    }

    func testInvalidStatusReturnsNil() {
        let packet = UmpPacket64(word0: 0, word1: 0)
        XCTAssertNil(Midi2NoteOn(ump: packet))
    }

    func testParsingThrowsForWrongMessageType() {
        let packet = UmpPacket64(word0: UInt32(0x5 << 28), word1: 0)
        XCTAssertThrowsError(try Midi2NoteOn(parsingUMP: packet))
    }
}
