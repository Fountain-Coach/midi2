/// Simple stateful stream negotiation session.
public final class StreamNegotiationSession {
    public struct Capabilities: Equatable {
        public var supportsMIDI2: Bool
        public var jrTx: Bool
        public var jrRx: Bool
        public init(supportsMIDI2: Bool = true, jrTx: Bool = true, jrRx: Bool = true) {
            self.supportsMIDI2 = supportsMIDI2
            self.jrTx = jrTx
            self.jrRx = jrRx
        }
    }

    public let responderCaps: Capabilities
    public let functionBlocks: GroupTerminalBlocks
    public private(set) var negotiated: StreamConfigurationMessage?

    public init(responderCaps: Capabilities, functionBlocks: GroupTerminalBlocks = GroupTerminalBlocks(blocks: [])) {
        self.responderCaps = responderCaps
        self.functionBlocks = functionBlocks
    }

    /// Accept an Endpoint Discovery and return responder's discovery (echoing versions and max groups).
    public func onEndpointDiscovery(_ req: EndpointDiscoveryMessage) -> EndpointDiscoveryMessage {
        // For demo purposes, echo back same versions and maxGroups
        EndpointDiscoveryMessage(majorVersion: req.majorVersion, minorVersion: req.minorVersion, maxGroups: req.maxGroups)
    }

    /// Process a Stream Configuration request and return a notification reflecting negotiated settings.
    public func onStreamConfigRequest(_ req: StreamConfigurationMessage) -> StreamConfigurationMessage {
        var notif = StreamConfigurationMessage(isNotification: true, jrTimestampsTx: false, jrTimestampsRx: false, protocolSelection: .midi1)
        // Protocol negotiation
        notif.protocolSelection = responderCaps.supportsMIDI2 && (req.protocolSelection == .midi2) ? .midi2 : .midi1
        // JR flags intersection
        notif.jrTimestampsTx = responderCaps.jrTx && req.jrTimestampsTx
        notif.jrTimestampsRx = responderCaps.jrRx && req.jrTimestampsRx
        negotiated = notif
        return notif
    }

    /// Filter known function blocks in response to a discovery request. Filter bits map directly to block indexes; a zero filter returns all blocks.
    public func onFunctionBlockDiscovery(_ req: FunctionBlockDiscovery) -> GroupTerminalBlocks {
        guard req.filterBitmap != 0 else { return functionBlocks }
        let filtered = functionBlocks.blocks.filter { block in
            guard block.index < 32 else { return false }
            let bit = UInt32(1) << UInt32(block.index)
            return (req.filterBitmap & bit) != 0
        }
        return GroupTerminalBlocks(blocks: filtered)
    }

    /// Convenience that emits UMP packets for the selected function blocks (64-bit Function Block Info).
    public func onFunctionBlockDiscovery(_ req: FunctionBlockDiscovery, group: Uint4) throws -> [UmpPacket64] {
        try onFunctionBlockDiscovery(req).umps(group: group)
    }
}
