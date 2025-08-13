import XCTest
@testable import MIDI2

final class SysEx7PacketTests: XCTestCase {
    func testFragmentAndReassemble() throws {
        let manufacturer: [UInt8] = [0x7D]
        let payload: [UInt8] = [0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08]
        let packets = try SysEx7.fragment(manufacturerID: manufacturer, payload: payload)
        let expected: [[UInt8]] = [
            [0x30, 0x16, 0x7D, 0x01, 0x02, 0x03, 0x04, 0x05],
            [0x30, 0x33, 0x06, 0x07, 0x08, 0x00, 0x00, 0x00]
        ]
        XCTAssertEqual(packets, expected)
        let (mfr, reassembled) = try SysEx7.reassemble(packets)
        XCTAssertEqual(mfr, manufacturer)
        XCTAssertEqual(reassembled, payload)
    }

    func testInvalidManufacturer() {
        XCTAssertThrowsError(try SysEx7.fragment(manufacturerID: [0x00], payload: []))
    }
}
