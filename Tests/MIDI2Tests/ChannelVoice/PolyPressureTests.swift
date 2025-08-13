import XCTest
@testable import MIDI2

final class PolyPressureTests: XCTestCase {
    func testRoundTrip() {
        let message = PolyPressure(
            group: Uint4(0x1)!,
            channel: Uint4(0x0)!,
            noteNumber: Uint7(0x40)!,
            pressure: 0x12345678
        )
        let packet = message.ump()
        XCTAssertEqual(packet.word0, 0x41A04000)
        XCTAssertEqual(packet.word1, 0x12345678)
        let decoded = PolyPressure(ump: packet)
        XCTAssertEqual(decoded, message)
    }
}
