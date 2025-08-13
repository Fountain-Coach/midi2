import XCTest
@testable import MIDI2

final class ControlChangeTests: XCTestCase {
    func testRoundTrip() {
        let message = ControlChange(
            group: Uint4(0x0)!,
            channel: Uint4(0x5)!,
            control: Uint7(0x0A)!,
            value: 0x87654321
        )
        let packet = message.ump()
        XCTAssertEqual(packet.word0, 0x40B50A00)
        XCTAssertEqual(packet.word1, 0x87654321)
        let decoded = ControlChange(ump: packet)
        XCTAssertEqual(decoded, message)
    }
}
