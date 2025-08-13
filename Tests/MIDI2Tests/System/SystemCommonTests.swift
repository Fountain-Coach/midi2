import XCTest
@testable import MIDI2

final class SystemCommonTests: XCTestCase {
    func testRoundTripMTCQuarterFrame() {
        let msg = SystemCommon.mtcQuarterFrame(group: Uint4(0x1)!, message: Uint7(0x10)!)
        let ump = msg.ump()
        let decoded = SystemCommon(ump: ump)
        XCTAssertEqual(decoded, msg)
    }

    func testRoundTripSongSelect() {
        let msg = SystemCommon.songSelect(group: Uint4(0x2)!, song: Uint7(0x7F)!)
        let ump = msg.ump()
        let decoded = SystemCommon(ump: ump)
        XCTAssertEqual(decoded, msg)
    }

    func testRoundTripSongPosition() {
        let msg = SystemCommon.songPositionPointer(group: Uint4(0x3)!, position: Uint14(0x1FFF)!)
        let ump = msg.ump()
        let decoded = SystemCommon(ump: ump)
        XCTAssertEqual(decoded, msg)
    }

    func testRoundTripTuneRequest() {
        let msg = SystemCommon.tuneRequest(group: Uint4(0x4)!)
        let ump = msg.ump()
        let decoded = SystemCommon(ump: ump)
        XCTAssertEqual(decoded, msg)
    }

    func testMalformedStatus() {
        // status 0xF4 is undefined for System Common
        let byte0 = UInt32(0x1 << 4 | 0x1)
        let status = UInt32(0xF4)
        let word = (byte0 << 24) | (status << 16)
        let ump = UmpPacket32(word: word)
        XCTAssertNil(SystemCommon(ump: ump))
    }

    func testMalformedMessageType() {
        // mt field not equal to 0x1
        let word = UInt32(0x2 << 28)
        let ump = UmpPacket32(word: word)
        XCTAssertNil(SystemCommon(ump: ump))
    }
}
