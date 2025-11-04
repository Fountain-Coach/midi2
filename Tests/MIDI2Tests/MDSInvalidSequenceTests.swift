import XCTest
@testable import MIDI2

final class MDSInvalidSequenceTests: XCTestCase {
    func testWrongHeaderStatus() {
        // Header with wrong status nibble (0x7 instead of 0x8)
        var header = Array(repeating: UInt8(0), count: 16)
        header[0] = 0x50
        header[1] = 0x70 // 0x7 << 4 | mdsID=0
        header[2] = 0
        header[3] = 16 // validBytes=16
        XCTAssertThrowsError(try MixedDataSet.reassemble([header]))
    }

    func testMismatchedPayloadPacketCount() {
        // valid header expecting payload > 0, but no payload packets provided
        var header = Array(repeating: UInt8(0), count: 16)
        header[0] = 0x50
        header[1] = 0x80 // mdsID=0
        header[2] = 0
        header[3] = 17 // validBytes=17 => 1 byte payload
        // Missing payload packet
        XCTAssertThrowsError(try MixedDataSet.reassemble([header]))
    }

    func testWrongPayloadStatusOrMdsId() {
        // header ok expecting 1 payload packet (14 bytes)
        var header = Array(repeating: UInt8(0), count: 16)
        header[0] = 0x50
        header[1] = 0x8F // mdsID=0xF
        header[2] = 0
        header[3] = 30 // 16 header + 14 payload
        // payload with wrong status nibble (0xA)
        var payload = Array(repeating: UInt8(0), count: 16)
        payload[0] = 0x50
        payload[1] = 0xAF // 0xA << 4 | 0xF
        XCTAssertThrowsError(try MixedDataSet.reassemble([header, payload]))
        // payload with right status nibble (0x9) but wrong mdsID
        payload[1] = 0x90 // 0x9 << 4 | 0x0
        XCTAssertThrowsError(try MixedDataSet.reassemble([header, payload]))
    }
}
