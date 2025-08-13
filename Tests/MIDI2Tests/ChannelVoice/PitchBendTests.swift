import XCTest
@testable import MIDI2

final class PitchBendTests: XCTestCase {
    func testRoundTrip() {
        let message = PitchBend(
            group: Uint4(0xF)!,
            channel: Uint4(0x1)!,
            value: 0x11223344
        )
        let packet = message.ump()
        XCTAssertEqual(packet.word0, 0x4FE10000)
        XCTAssertEqual(packet.word1, 0x11223344)
        let decoded = PitchBend(ump: packet)
        XCTAssertEqual(decoded, message)
    }
}
