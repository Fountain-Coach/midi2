import XCTest
@testable import MIDI2

final class Midi2ChannelVoiceBodyTests: XCTestCase {
    func testDecodeNoteOn() {
        let note = Midi2NoteOn(group: Uint4(1)!, channel: Uint4(2)!, note: Uint7(60)!, velocity: 0x1234)
        let pkt = note.ump()
        let body = Midi2ChannelVoiceBody(ump: pkt)
        XCTAssertNotNil(body)
        XCTAssertEqual(body?.group, Uint4(1)!)
        XCTAssertEqual(body?.status, 0x9)
        XCTAssertEqual(body?.channel, Uint4(2)!)
        XCTAssertEqual(body?.dataByte1, note.note.rawValue)
        XCTAssertEqual(body?.dataByte2, note.attributeType.rawValue)
        if case let .noteOn(decoded)? = body?.variant() {
            XCTAssertEqual(decoded, note)
        } else {
            XCTFail("Expected NoteOn variant")
        }
    }
}
