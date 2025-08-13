import XCTest
@testable import MIDI2

final class DataMessageBodyTests: XCTestCase {
    func testRoundTripSysEx8() throws {
        let body = DataMessageBody.sysex8(manufacturerID: [0x7D], data: [0x01,0x02,0x03,0x04,0x05])
        let packets = try body.umpPackets(group: Uint4(0x0)!)
        let decoded = DataMessageBody(sysex8Packets: packets)
        XCTAssertEqual(decoded, body)
    }
}
