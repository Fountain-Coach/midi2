import XCTest
@testable import MIDI2

final class SysEx8Tests: XCTestCase {
    func testFragmentAndReassemble() throws {
        let manufacturer: [UInt8] = [0x00, 0x20, 0x33]
        let payload: [UInt8] = Array(1...20).map { UInt8($0) }
        let packets = try SysEx8.fragment(manufacturerID: manufacturer, payload: payload)
        let expected: [[UInt8]] = [
            [0x50, 0x1E, 0x00, 0x20, 0x33, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B],
            [0x50, 0x39, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00]
        ]
        XCTAssertEqual(packets, expected)
        let (mfr, reassembled) = try SysEx8.reassemble(packets)
        XCTAssertEqual(mfr, manufacturer)
        XCTAssertEqual(reassembled, payload)
    }

    func testInvalidManufacturer() {
        XCTAssertThrowsError(try SysEx8.fragment(manufacturerID: [0x01, 0x02], payload: []))
    }
}
