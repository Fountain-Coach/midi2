import XCTest
@testable import MIDI2

final class SysEx8InvalidSequenceTests: XCTestCase {
    func testWrongMessageType() {
        // 16 bytes, but mt nibble 0x4 instead of 0x5
        let pkt: [UInt8] = Array([UInt8(0x40), 0x00] + Array(repeating: UInt8(0), count: 14))
        XCTAssertThrowsError(try SysEx8.reassemble([pkt]))
    }

    func testBadCountNibble() {
        // count > 14 in second byte low nibble
        let pkt: [UInt8] = Array([0x50, 0x0F] + Array(repeating: UInt8(0), count: 14))
        XCTAssertThrowsError(try SysEx8.reassemble([pkt]))
    }

    func testOutOfOrderStatuses() {
        // continuation as first packet (0x2)
        let pkt: [UInt8] = Array([0x50, 0x20] + Array(repeating: UInt8(0), count: 14))
        XCTAssertThrowsError(try SysEx8.reassemble([pkt]))
    }

    func testEndNotLast() {
        // end status in first, but more than one packet
        let p1: [UInt8] = Array([0x50, 0x30] + Array(repeating: UInt8(0), count: 14))
        let p2: [UInt8] = Array([0x50, 0x00] + Array(repeating: UInt8(0), count: 14))
        XCTAssertThrowsError(try SysEx8.reassemble([p1, p2]))
    }

    func testInvalidManufacturerId() {
        // single packet, count=1, first data byte 0x00 invalid as 1-byte manufacturer ID
        var pkt: [UInt8] = Array([0x50, 0x01] + Array(repeating: UInt8(0), count: 14))
        pkt[2] = 0x00
        XCTAssertThrowsError(try SysEx8.reassemble([pkt]))
    }
}
