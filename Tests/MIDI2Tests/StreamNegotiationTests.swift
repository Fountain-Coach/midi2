import XCTest
@testable import MIDI2

final class StreamNegotiationTests: XCTestCase {
    func testNegotiationMIDI2Accepted() {
        let session = StreamNegotiationSession(responderCaps: .init(supportsMIDI2: true, jrTx: true, jrRx: false))
        let ep = EndpointDiscoveryMessage(majorVersion: 1, minorVersion: 0, maxGroups: 8)
        _ = session.onEndpointDiscovery(ep)
        let req = StreamConfigurationMessage(isNotification: false, jrTimestampsTx: true, jrTimestampsRx: true, protocolSelection: .midi2)
        let reply = session.onStreamConfigRequest(req)
        XCTAssertTrue(reply.isNotification)
        XCTAssertEqual(reply.protocolSelection, .midi2)
        XCTAssertTrue(reply.jrTimestampsTx)
        XCTAssertFalse(reply.jrTimestampsRx)
    }

    func testNegotiationFallsBackToMIDI1() {
        let session = StreamNegotiationSession(responderCaps: .init(supportsMIDI2: false, jrTx: true, jrRx: true))
        let req = StreamConfigurationMessage(isNotification: false, jrTimestampsTx: true, jrTimestampsRx: true, protocolSelection: .midi2)
        let reply = session.onStreamConfigRequest(req)
        XCTAssertEqual(reply.protocolSelection, .midi1)
    }

    func testFunctionBlockDiscoveryFiltersBlocksByMask() {
        let gtb = GroupTerminalBlocks(blocks: [
            GroupTerminalBlock(index: 0, firstGroup: 0, groupCount: 4),
            GroupTerminalBlock(index: 1, firstGroup: 4, groupCount: 4),
            GroupTerminalBlock(index: 5, firstGroup: 8, groupCount: 2)
        ])
        let session = StreamNegotiationSession(responderCaps: .init(), functionBlocks: gtb)

        let all = session.onFunctionBlockDiscovery(FunctionBlockDiscovery(filterBitmap: 0))
        XCTAssertEqual(all.blocks, gtb.blocks)

        let mask: UInt32 = (UInt32(1) << 0) | (UInt32(1) << 5)
        let subset = session.onFunctionBlockDiscovery(FunctionBlockDiscovery(filterBitmap: mask))
        XCTAssertEqual(subset.blocks.map { $0.index }, [0, 5])

        let none = session.onFunctionBlockDiscovery(FunctionBlockDiscovery(filterBitmap: UInt32(1) << 7))
        XCTAssertTrue(none.blocks.isEmpty)
    }

    func testFunctionBlockDiscoveryUMPsRoundTrip() throws {
        let gtb = GroupTerminalBlocks(blocks: [
            GroupTerminalBlock(index: 2, firstGroup: 2, groupCount: 4),
            GroupTerminalBlock(index: 4, firstGroup: 8, groupCount: 2)
        ])
        let session = StreamNegotiationSession(responderCaps: .init(), functionBlocks: gtb)
        let req = FunctionBlockDiscovery(filterBitmap: UInt32(1) << 4)
        let group = Uint4(3)!
        let pkts = try session.onFunctionBlockDiscovery(req, group: group)
        let parsed = try GroupTerminalBlocks(parsingUMPs: pkts)
        XCTAssertEqual(parsed.blocks, [GroupTerminalBlock(index: 4, firstGroup: 8, groupCount: 2, active: false, direction: .reserved, midi1Bandwidth: .notMidi1, uiHints: 0)])
    }

    func testFunctionBlockDiscoveryUMPsCarryFlags() throws {
        let gtb = GroupTerminalBlocks(blocks: [
            GroupTerminalBlock(index: 0, firstGroup: 0, groupCount: 4, active: true, direction: .bidirectional, midi1Bandwidth: .restrict31_25kbps, uiHints: 0x5A, profiles: ["/org.midi/piano"])
        ])
        let session = StreamNegotiationSession(responderCaps: .init(), functionBlocks: gtb)
        let req = FunctionBlockDiscovery(filterBitmap: 0)
        let group = Uint4(1)!
        let pkts = try session.onFunctionBlockDiscovery(req, group: group)
        XCTAssertEqual(pkts.count, 1)
        let word1 = pkts[0].word1
        XCTAssertEqual((word1 & 0x80000000) != 0, true)
        XCTAssertEqual((word1 >> 16) & 0x03, 3)
        XCTAssertEqual((word1 >> 8) & 0x03, 2)
        XCTAssertEqual(word1 & 0xFF, 0x5A)
        XCTAssertEqual(session.profileAssociations(for: 0), ["/org.midi/piano"])
    }
}
