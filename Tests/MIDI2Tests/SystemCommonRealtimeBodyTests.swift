import XCTest
@testable import MIDI2

final class SystemCommonRealtimeBodyTests: XCTestCase {
    func testRoundTripSongSelect() throws {
        let body = SystemCommonRealtimeBody(status: .songSelect, data1: 0x7F)
        let packet = body.ump(group: Uint4(0x3)!)
        let decoded = SystemCommonRealtimeBody(ump: packet)
        XCTAssertEqual(decoded, body)

        XCTAssertNoThrow(try SystemCommonRealtimeBody(parsingUMP: packet))
    }
}
