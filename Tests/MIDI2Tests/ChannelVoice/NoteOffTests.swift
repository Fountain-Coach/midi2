import XCTest
@testable import MIDI2

final class NoteOffTests: XCTestCase {
    func testRoundTrip() {
        let message = NoteOff(
            group: Uint4(0x1)!,
            channel: Uint4(0x2)!,
            noteNumber: Uint7(0x3C)!,
            velocity: 0x1234,
            attributeType: NoteAttributeType(0x56)!,
            attributeData: 0x789A
        )
        let packet = message.ump()
        XCTAssertEqual(packet.word0, 0x41823C56)
        XCTAssertEqual(packet.word1, 0x1234789A)
        let decoded = NoteOff(ump: packet)
        XCTAssertEqual(decoded, message)
    }
}
