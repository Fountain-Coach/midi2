import XCTest
@testable import MIDI2

final class SystemCommonRealtimeBodyTests: XCTestCase {
    func testRoundTripAllStatuses() throws {
        let group = Uint4(0x3)!
        let cases: [(SystemStatus, UInt8, UInt8)] = [
            (.mtcQuarterFrame, 0x10, 0),
            (.songPositionPointer, 0x01, 0x02),
            (.songSelect, 0x7F, 0),
            (.tuneRequest, 0, 0),
            (.timingClock, 0, 0),
            (.start, 0, 0),
            (.continue, 0, 0),
            (.stop, 0, 0),
            (.activeSensing, 0, 0),
            (.systemReset, 0, 0)
        ]

        for (status, d1, d2) in cases {
            let body = SystemCommonRealtimeBody(status: status, data1: d1, data2: d2)
            let packet = body.ump(group: group)
            let decoded = SystemCommonRealtimeBody(ump: packet)
            XCTAssertEqual(decoded, body)
            XCTAssertNoThrow(try SystemCommonRealtimeBody(parsingUMP: packet))
        }
    }

    func testInvalidMessageType() {
        // mt field not equal to 0x1
        let word = UInt32(0x2 << 28)
        let packet = UmpPacket32(word: word)
        XCTAssertNil(SystemCommonRealtimeBody(ump: packet))
        XCTAssertThrowsError(try SystemCommonRealtimeBody(parsingUMP: packet))
    }

    func testInvalidStatus() {
        // status byte 0xF4 is undefined
        let word = (UInt32(0x1 << 28) | (UInt32(0xF4) << 16))
        let packet = UmpPacket32(word: word)
        XCTAssertNil(SystemCommonRealtimeBody(ump: packet))
        XCTAssertThrowsError(try SystemCommonRealtimeBody(parsingUMP: packet))
    }
}
