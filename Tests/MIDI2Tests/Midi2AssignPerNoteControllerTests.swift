import XCTest
@testable import MIDI2

final class Midi2AssignPerNoteControllerTests: XCTestCase {
    func testEncodeDecode() {
        let msg = Midi2AssignPerNoteController(group: Uint4(1)!, channel: Uint4(2)!, noteNumber: Uint7(70)!, controller: 0x90, value: 0x01020304)
        let pkt = msg.ump()
        let decoded = Midi2AssignPerNoteController(ump: pkt)
        XCTAssertEqual(decoded, msg)
    }
}
