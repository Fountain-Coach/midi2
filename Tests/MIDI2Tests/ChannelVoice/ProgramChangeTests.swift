import XCTest
@testable import MIDI2

final class ProgramChangeTests: XCTestCase {
    func testRoundTrip() {
        let message = ProgramChange(
            group: Uint4(0x2)!,
            channel: Uint4(0x3)!,
            program: Uint7(0x05)!,
            bankMsb: Uint7(0x07)!,
            bankLsb: Uint7(0x09)!
        )
        let packet = message.ump()
        XCTAssertEqual(packet.word0, 0x42C30580)
        XCTAssertEqual(packet.word1, 0x07090000)
        let decoded = ProgramChange(ump: packet)
        XCTAssertEqual(decoded, message)
    }
}
