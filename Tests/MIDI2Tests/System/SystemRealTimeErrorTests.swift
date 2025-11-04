import XCTest
@testable import MIDI2

final class SystemRealTimeErrorTests: XCTestCase {
    func testUnsupportedStatus() {
        // Use status 0xF7 (undefined between tuneRequest 0xF6 and timingClock 0xF8)
        let byte0 = UInt32(0x1 << 4 | 0x0)
        let status = UInt32(0xF7)
        let word = (byte0 << 24) | (status << 16)
        let ump = UmpPacket32(word: word)
        XCTAssertThrowsError(try SystemRealTime(parsingUMP: ump)) { error in
            XCTAssertTrue(error.localizedDescription.contains("unsupported system realtime status"))
        }
    }

    func testInvalidMessageType() {
        let word = UInt32(0x2 << 28)
        let ump = UmpPacket32(word: word)
        XCTAssertThrowsError(try SystemRealTime(parsingUMP: ump)) { error in
            XCTAssertTrue(error.localizedDescription.contains("expected mt 0x1"))
        }
    }
}

