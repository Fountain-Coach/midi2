import XCTest
@testable import MIDI2

final class GroupTerminalBlocksTests: XCTestCase {
    func testRoundTrip() throws {
        let blocks = [
            GroupTerminalBlock(index: 0, firstGroup: 0, groupCount: 4, active: true, direction: .input, midi1Bandwidth: .unrestricted, uiHints: 0x12),
            GroupTerminalBlock(index: 1, firstGroup: 4, groupCount: 4, active: false, direction: .output, midi1Bandwidth: .restrict31_25kbps, uiHints: 0x34)
        ]
        let gtb = GroupTerminalBlocks(blocks: blocks)
        let group = Uint4(0x3)!
        let pkts = try gtb.umps(group: group)
        XCTAssertEqual(pkts.count, 2)
        let parsed = try GroupTerminalBlocks(parsingUMPs: pkts)
        XCTAssertEqual(parsed.blocks, blocks)
    }

    func testRejectWrongOpcode() {
        let group = Uint4(0)!
        let w0 = (UInt32(0xF) << 28) | (UInt32(group.rawValue) << 24) | (UInt32(StreamOpcode.endpointDiscovery.rawValue) << 16)
        let pkt = UmpPacket64(word0: w0, word1: 0)
        XCTAssertThrowsError(try GroupTerminalBlocks(parsingUMPs: [pkt]))
    }

    func testGTBValidatorRejectsOverlap() {
        let blocks = [
            GroupTerminalBlock(index: 0, firstGroup: 0, groupCount: 4),
            GroupTerminalBlock(index: 1, firstGroup: 3, groupCount: 2)
        ]
        XCTAssertThrowsError(try GTBValidator.validate(blocks: blocks))
    }
}
