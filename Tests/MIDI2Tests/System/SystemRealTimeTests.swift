import XCTest
@testable import MIDI2

final class SystemRealTimeTests: XCTestCase {
    func testRoundTripClock() {
        let msg = SystemRealTime.timingClock(group: Uint4(0x2)!)
        let ump = msg.ump()
        let decoded = SystemRealTime(ump: ump)
        XCTAssertEqual(decoded, msg)
    }

    func testMalformedStatus() {
        // status 0xF1 is System Common, not Real-Time
        let byte0 = UInt32(0x1 << 4 | 0x0)
        let word = (byte0 << 24) | (UInt32(0xF1) << 16)
        let ump = UmpPacket32(word: word)
        XCTAssertNil(SystemRealTime(ump: ump))
    }
}
