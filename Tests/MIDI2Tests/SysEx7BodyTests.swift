import XCTest
@testable import MIDI2

final class SysEx7BodyTests: XCTestCase {
    func testRoundTripGoldenVector() throws {
        let manufacturer: [UInt8] = [0x7D]
        let payload: [UInt8] = [0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08]
        let body = try SysEx7Body(manufacturerID: manufacturer, payload: payload, group: Uint4(0x0)!)
        let expected: [[UInt8]] = [
            [0x30, 0x16, 0x7D, 0x01, 0x02, 0x03, 0x04, 0x05],
            [0x30, 0x33, 0x06, 0x07, 0x08, 0x00, 0x00, 0x00]
        ]
        XCTAssertEqual(body.rawPackets, expected)
        let (mfr, rebuilt) = try body.manufacturerAndPayload()
        XCTAssertEqual(mfr, manufacturer)
        XCTAssertEqual(rebuilt, payload)
    }

    func testInvalidManufacturer() {
        XCTAssertThrowsError(try SysEx7Body(manufacturerID: [0x00], payload: [], group: Uint4(0x0)!))
    }

    func testInvalidPacketSequence() {
        let pkt1 = SysEx7Packet(group: Uint4(0x0)!, status: .start, data: [0x7D])
        let pkt2 = SysEx7Packet(group: Uint4(0x0)!, status: .start, data: [0x00])
        let body = SysEx7Body(packets: [pkt1, pkt2])
        XCTAssertThrowsError(try body.manufacturerAndPayload())
    }
}
