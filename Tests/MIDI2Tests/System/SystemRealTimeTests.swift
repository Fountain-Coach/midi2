import XCTest
@testable import MIDI2

final class SystemRealTimeTests: XCTestCase {
    func testRoundTripAllMessages() {
        let cases: [SystemRealTime] = [
            .timingClock(group: Uint4(0x0)!),
            .start(group: Uint4(0x1)!),
            .continue(group: Uint4(0x2)!),
            .stop(group: Uint4(0x3)!),
            .activeSensing(group: Uint4(0x4)!),
            .systemReset(group: Uint4(0x5)!)
        ]

        for msg in cases {
            let ump = msg.ump()
            let decoded = SystemRealTime(ump: ump)
            XCTAssertEqual(decoded, msg)
            XCTAssertNoThrow(try SystemRealTime(parsingUMP: ump))
        }
    }

    func testMalformedStatus() {
        // status 0xF1 is System Common, not Real-Time
        let byte0 = UInt32(0x1 << 4 | 0x0)
        let word = (byte0 << 24) | (UInt32(0xF1) << 16)
        let ump = UmpPacket32(word: word)
        XCTAssertNil(SystemRealTime(ump: ump))
        XCTAssertThrowsError(try SystemRealTime(parsingUMP: ump))
    }

    func testMalformedMessageType() {
        // mt field not equal to 0x1
        let word = UInt32(0x2 << 28)
        let ump = UmpPacket32(word: word)
        XCTAssertNil(SystemRealTime(ump: ump))
        XCTAssertThrowsError(try SystemRealTime(parsingUMP: ump))
    }
}
