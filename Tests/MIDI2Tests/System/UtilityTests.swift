import XCTest
@testable import MIDI2

final class UtilityTests: XCTestCase {
    func testRoundTripJRClock() {
        let msg = Utility.jrClock(0x1234)
        let ump = msg.ump()
        let decoded = Utility(ump: ump)
        XCTAssertEqual(decoded, msg)
    }

    func testRoundTripJRTimestamp() {
        let msg = Utility.jrTimestamp(0x2345)
        let ump = msg.ump()
        let decoded = Utility(ump: ump)
        XCTAssertEqual(decoded, msg)
    }

    func testMalformedGroupNibble() {
        // group nibble must be zero for utility messages
        let byte0 = UInt32(0x0 << 4 | 0x1) // mt=0, group=1 -> invalid
        let word = (byte0 << 24) | (UInt32(0x00) << 16)
        let ump = UmpPacket32(word: word)
        XCTAssertNil(Utility(ump: ump))
    }
}
