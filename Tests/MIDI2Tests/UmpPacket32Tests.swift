import XCTest
@testable import MIDI2

final class UmpPacket32Tests: XCTestCase {
    func testMidi1NoteOnRoundtrip() {
        let bytes: [UInt8] = [0x90, 0x40, 0x7F]
        let group = Uint4(0x2)!
        guard let packet = UmpPacket32(midi1Bytes: bytes, group: group) else {
            return XCTFail("failed to construct packet")
        }
        XCTAssertEqual(packet.midi1Bytes(), bytes)
    }

    func testProgramChangeRoundtrip() {
        let bytes: [UInt8] = [0xC3, 0x22]
        let group = Uint4(0x1)!
        guard let packet = UmpPacket32(midi1Bytes: bytes, group: group) else {
            return XCTFail("failed to construct packet")
        }
        XCTAssertEqual(packet.midi1Bytes(), bytes)
    }
}
