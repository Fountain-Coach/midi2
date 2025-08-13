import XCTest
@testable import MIDI2

final class Midi2RegPerNoteControllerTests: XCTestCase {
    func testEncodeDecode() {
        let msg = Midi2RegPerNoteController(group: Uint4(2)!, channel: Uint4(0)!, noteNumber: Uint7(60)!, controller: 0x20, value: 0x12345678)
        let pkt = msg.ump()
        let decoded = Midi2RegPerNoteController(ump: pkt)
        XCTAssertEqual(decoded, msg)
    }
}
