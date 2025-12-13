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

        let all = try! session.onFunctionBlockDiscovery(FunctionBlockDiscovery(filterBitmap: 0))
        XCTAssertEqual(all.blocks, gtb.blocks)

        let mask: UInt32 = (UInt32(1) << 0) | (UInt32(1) << 5)
        let subset = try! session.onFunctionBlockDiscovery(FunctionBlockDiscovery(filterBitmap: mask))
        XCTAssertEqual(subset.blocks.map { $0.index }, [0, 5])

        let none = try! session.onFunctionBlockDiscovery(FunctionBlockDiscovery(filterBitmap: UInt32(1) << 7))
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

    func testProfileAssociationUpdates() throws {
        let gtb = GroupTerminalBlocks(blocks: [
            GroupTerminalBlock(index: 1, firstGroup: 4, groupCount: 4)
        ])
        let session = StreamNegotiationSession(responderCaps: .init(), functionBlocks: gtb)
        session.setProfileAssociations(for: 1, profiles: ["/org.midi/piano", "/org.midi/organ"])
        let subset = try session.onFunctionBlockDiscovery(FunctionBlockDiscovery(filterBitmap: UInt32(1) << 1))
        XCTAssertEqual(subset.blocks.first?.profiles ?? [], ["/org.midi/piano", "/org.midi/organ"])
    }

    func testProfileAssociationIncrementalUpdates() throws {
        let gtb = GroupTerminalBlocks(blocks: [
            GroupTerminalBlock(index: 2, firstGroup: 0, groupCount: 4)
        ])
        let session = StreamNegotiationSession(responderCaps: .init(), functionBlocks: gtb)
        session.updateProfileAssociation(functionBlock: 2, profileId: "/org.midi/piano", enabled: true)
        session.updateProfileAssociation(functionBlock: 2, profileId: "/org.midi/organ", enabled: true)
        var subset = try session.onFunctionBlockDiscovery(FunctionBlockDiscovery(filterBitmap: UInt32(1) << 2))
        XCTAssertEqual(Set(subset.blocks.first?.profiles ?? []), Set(["/org.midi/piano", "/org.midi/organ"]))
        session.updateProfileAssociation(functionBlock: 2, profileId: "/org.midi/piano", enabled: false)
        subset = try session.onFunctionBlockDiscovery(FunctionBlockDiscovery(filterBitmap: UInt32(1) << 2))
        XCTAssertEqual(subset.blocks.first?.profiles ?? [], ["/org.midi/organ"])
    }

    func testGtbAllowedMessageTypesContext() throws {
        let session = StreamNegotiationSession(responderCaps: .init(), functionBlocks: GroupTerminalBlocks(blocks: []))
        session.setGtbAllowedMessageTypes(for: 1, allowed: [0xF])
        XCTAssertEqual(session.allowedMessageTypes(for: 1), [0xF])
        XCTAssertNoThrow(try session.enforceAllowedMessageType(mt: 0xF, group: 1))
        XCTAssertThrowsError(try session.enforceAllowedMessageType(mt: 0x2, group: 1))
    }

    func testGtbAllowedMessageTypesEnforcementOnUmpPackets() throws {
        let session = StreamNegotiationSession(responderCaps: .init(), functionBlocks: GroupTerminalBlocks(blocks: []))
        session.setGtbAllowedMessageTypes(for: 2, allowed: [0x0, 0xF])
        // Stream (0xF) on group 2 passes
        let streamWord0: UInt32 = (UInt32(0xF) << 28) | (UInt32(2) << 24)
        let streamPkt = UmpPacket64(word0: streamWord0, word1: 0)
        XCTAssertNoThrow(try session.enforceAllowedMessageType(for: streamPkt))
        // Utility (0x0) on group 2 passes
        let utilPkt = UmpPacket32(mt: 0x0, group: Uint4(2)!, status: 0, data1: 0, data2: 0)
        XCTAssertNoThrow(try session.enforceAllowedMessageType(for: utilPkt))
        // Disallowed MT on group 2 fails
        let channelPkt = UmpPacket64(word0: (UInt32(0x2) << 28) | (UInt32(2) << 24), word1: 0)
        XCTAssertThrowsError(try session.enforceAllowedMessageType(for: channelPkt))
    }

    func testGtbNegotiationStoresDescriptorAndSeedsMap() throws {
        let blocks = GroupTerminalBlocks(blocks: [
            GroupTerminalBlock(index: 0, firstGroup: 0, groupCount: 2)
        ])
        let session = StreamNegotiationSession(responderCaps: .init(), functionBlocks: blocks)
        let desc = GtbDescriptor(raw: [0: [0xF]])
        try session.negotiate(gtbDescriptor: desc)
        XCTAssertEqual(session.gtbDescriptor?.groups[0], Set([0xF]))
        XCTAssertEqual(session.allowedMessageTypes(for: 0), Set([0xF]))
    }

    func testGtbNegotiationRespectsAllowOverlapFlag() throws {
        let overlapping = GroupTerminalBlocks(blocks: [
            GroupTerminalBlock(index: 0, firstGroup: 0, groupCount: 3),
            GroupTerminalBlock(index: 1, firstGroup: 2, groupCount: 2)
        ])
        let desc = GtbDescriptor(raw: [2: [0xF]])
        let session = StreamNegotiationSession(responderCaps: .init(), functionBlocks: overlapping, allowGtbOverlap: true)
        XCTAssertNoThrow(try session.negotiate(gtbDescriptor: desc))
    }

    func testGtbEnforcementForUniversalPacket() throws {
        let session = StreamNegotiationSession(responderCaps: .init(), functionBlocks: GroupTerminalBlocks(blocks: []))
        session.setGtbAllowedMessageTypes(for: 3, allowed: [0xF])
        let allowed = UmpPacket128(word0: (UInt32(0xF) << 28) | (UInt32(3) << 24), word1: 0, word2: 0, word3: 0)
        try session.enforceAllowedMessageType(for: allowed)
        let blocked = UmpPacket128(word0: (UInt32(0x2) << 28) | (UInt32(3) << 24), word1: 0, word2: 0, word3: 0)
        XCTAssertThrowsError(try session.enforceAllowedMessageType(for: blocked))
    }

    func testGtbGuardIncomingWords() throws {
        let session = StreamNegotiationSession(responderCaps: .init(), functionBlocks: GroupTerminalBlocks(blocks: []))
        session.setGtbAllowedMessageTypes(for: 1, allowed: [0xF])
        let allowedWords: [UInt32] = [(UInt32(0xF) << 28) | (UInt32(1) << 24)]
        XCTAssertNoThrow(try session.guardIncoming(words: allowedWords))
        let blockedWords: [UInt32] = [(UInt32(0x2) << 28) | (UInt32(1) << 24)]
        XCTAssertThrowsError(try session.guardIncoming(words: blockedWords))
    }
}
