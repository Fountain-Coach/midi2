import XCTest
@testable import MIDI2

final class StreamNegativeValidationTests: XCTestCase {
    func testEndpointInfoRejectsReservedNumberOfFunctionBlocks() {
        let word: UInt32 = (UInt32(0xF) << 28) |
            (UInt32(StreamOpcode.endpointInfoNotification.rawValue) << 16) |
            (UInt32(0x21) << 8) // numberOfFunctionBlocks = 0x21 (reserved range)
        let pkt = UmpPacket32(word: word)
        XCTAssertThrowsError(try EndpointInfoNotification(parsingUMP: pkt))
    }

    func testFunctionBlockInfoRejectsReservedMidi1Bandwidth() {
        let group = Uint4(0)!
        let word0: UInt32 = (UInt32(0xF) << 28) |
            (UInt32(group.rawValue) << 24) |
            (UInt32(StreamOpcode.functionBlockInfoNotification.rawValue) << 16) |
            (UInt32(0x00) << 8) | // index
            (UInt32(0x0) << 4) | // firstGroup
            UInt32(0x1) // groupCount
        let word1: UInt32 = (UInt32(FunctionBlockDirection.input.rawValue) << 16) |
            (UInt32(Midi1Bandwidth.reserved.rawValue) << 8) // reserved midi1Bandwidth = 3
        let pkt = UmpPacket64(word0: word0, word1: word1)
        XCTAssertThrowsError(try FunctionBlockInfoNotification(parsingUMP64: pkt))
    }

    func testUtilityRejectsNonZeroGroupAndUnsupportedStatus() {
        let nonZeroGroup = UmpPacket32(word: (UInt32(0x0) << 28) | (UInt32(0x1) << 24) | (UInt32(0x00) << 16))
        XCTAssertThrowsError(try Utility(parsingUMP: nonZeroGroup))

        let unsupportedStatus = UmpPacket32(word: (UInt32(0x0) << 28) | (UInt32(0x00) << 24) | (UInt32(0x7F) << 16))
        XCTAssertThrowsError(try Utility(parsingUMP: unsupportedStatus))
    }
}
