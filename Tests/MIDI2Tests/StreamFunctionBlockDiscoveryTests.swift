import XCTest
@testable import MIDI2

final class StreamFunctionBlockDiscoveryTests: XCTestCase {
    func testRoundTripEncodeDecode() throws {
        let value: UInt32 = 0xA5A5_F00D
        let disc = FunctionBlockDiscovery(filterBitmap: value)
        let group = Uint4(0x2)!
        let pkts = disc.umps(group: group)
        XCTAssertEqual(pkts.count, 2)
        let parsed = try FunctionBlockDiscovery(parsingUMPs: pkts)
        XCTAssertEqual(parsed.filterBitmap, value)
    }

    func testInvalidPacketCount() {
        let group = Uint4(0)!
        let pkt = StreamBody(opcode: .functionBlock, data1: 0x00, data2: 0x01).ump(group: group)
        XCTAssertThrowsError(try FunctionBlockDiscovery(parsingUMPs: [pkt]))
    }

    func testWrongOpcodeFails() {
        let group = Uint4(0)!
        let pkt1 = StreamBody(opcode: .endpointDiscovery, data1: 0x00, data2: 0x00).ump(group: group)
        let pkt2 = StreamBody(opcode: .functionBlock, data1: 0x00, data2: 0x00).ump(group: group)
        XCTAssertThrowsError(try FunctionBlockDiscovery(parsingUMPs: [pkt1, pkt2]))
    }
}

