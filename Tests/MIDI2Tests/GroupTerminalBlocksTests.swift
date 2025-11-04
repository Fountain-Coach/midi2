import XCTest
@testable import MIDI2

final class GroupTerminalBlocksTests: XCTestCase {
    func testRoundTrip() throws {
        let blocks = [
            GroupTerminalBlock(index: 0, firstGroup: 0, groupCount: 4),
            GroupTerminalBlock(index: 1, firstGroup: 4, groupCount: 4)
        ]
        let gtb = GroupTerminalBlocks(blocks: blocks)
        let group = Uint4(0x3)!
        let pkts = gtb.umps(group: group)
        XCTAssertEqual(pkts.count, 2)
        let parsed = try GroupTerminalBlocks(parsingUMPs: pkts)
        XCTAssertEqual(parsed.blocks, blocks)
    }

    func testRejectWrongOpcode() {
        let group = Uint4(0)!
        let pkt = StreamBody(opcode: .endpointDiscovery, data1: 0x00, data2: 0x00).ump(group: group)
        XCTAssertThrowsError(try GroupTerminalBlocks(parsingUMPs: [pkt]))
    }
}

