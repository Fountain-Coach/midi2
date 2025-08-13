import XCTest
@testable import MIDI2

final class SysEx7PacketTests: XCTestCase {
    func testRoundTripGoldenVector() throws {
        let bytes: [UInt8] = [0x30, 0x16, 0x7D, 0x01, 0x02, 0x03, 0x04, 0x05]
        let packet = try SysEx7Packet(parsing: bytes)
        XCTAssertEqual(packet.group, Uint4(0x0)!)
        XCTAssertEqual(packet.status, .start)
        XCTAssertEqual(packet.byteCount, Uint4(0x6)!)
        XCTAssertEqual(packet.data, [0x7D, 0x01, 0x02, 0x03, 0x04, 0x05])
        XCTAssertEqual(packet.rawBytes, bytes)
        XCTAssertEqual(packet.ump.rawBytes, bytes)
    }

    func testInvalidMessageType() {
        let bad: [UInt8] = [0x40, 0x16, 0x7D, 0x01, 0x02, 0x03, 0x04, 0x05]
        XCTAssertNil(SysEx7Packet(rawBytes: bad))
        XCTAssertThrowsError(try SysEx7Packet(parsing: bad))
    }

    func testInvalidByteCount() {
        let bad: [UInt8] = [0x30, 0x1F, 0x7D, 0x01, 0x02, 0x03, 0x04, 0x05]
        XCTAssertNil(SysEx7Packet(rawBytes: bad))
        XCTAssertThrowsError(try SysEx7Packet(parsing: bad))
    }
}
