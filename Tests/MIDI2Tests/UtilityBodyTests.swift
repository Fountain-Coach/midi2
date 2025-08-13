import XCTest
@testable import MIDI2

final class UtilityBodyTests: XCTestCase {
    func testRoundTripJRClock() throws {
        let body = UtilityBody(opcode: .jrClock, value: 0x1234)
        let packet = body.ump()
        let decoded = UtilityBody(ump: packet)
        XCTAssertEqual(decoded, body)

        // throwing variant
        XCTAssertNoThrow(try UtilityBody(parsingUMP: packet))
    }
}
