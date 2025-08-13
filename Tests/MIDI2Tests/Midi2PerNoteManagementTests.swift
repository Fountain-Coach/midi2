import XCTest
@testable import MIDI2

final class Midi2PerNoteManagementTests: XCTestCase {
    func testEncodeDecode() {
        let msg = Midi2PerNoteManagement(group: Uint4(3)!, channel: Uint4(1)!, noteNumber: Uint7(64)!, detach: true, reset: false)
        let pkt = msg.ump()
        let decoded = Midi2PerNoteManagement(ump: pkt)
        XCTAssertEqual(decoded, msg)
    }
}
