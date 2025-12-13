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
    private var profileMap: [UInt8: [String]] = [:]
    private var gtbAllowedMt: [UInt8: Set<UInt8>] = [:]
    public private(set) var negotiated: StreamConfigurationMessage?

    public init(responderCaps: Capabilities, functionBlocks: GroupTerminalBlocks = GroupTerminalBlocks(blocks: [])) {
        self.responderCaps = responderCaps
        self.functionBlocks = functionBlocks
        for block in functionBlocks.blocks {
            if !block.profiles.isEmpty {
                profileMap[block.index] = block.profiles
            }
        }
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
    public func onFunctionBlockDiscovery(_ req: FunctionBlockDiscovery) throws -> GroupTerminalBlocks {
        let sourceBlocks = functionBlocks.blocks.map { blk -> GroupTerminalBlock in
            var copy = blk
            if let profiles = profileMap[blk.index] {
                copy.profiles = profiles
            }
            return copy
        }
        try GTBValidator.validate(blocks: sourceBlocks)
        guard req.filterBitmap != 0 else { return GroupTerminalBlocks(blocks: sourceBlocks) }
        let filtered = sourceBlocks.filter { block in
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

    /// Return profile associations for a function block index (if provided in the session's blocks).
    public func profileAssociations(for index: UInt8) -> [String] {
        functionBlocks.blocks.first(where: { $0.index == index })?.profiles ?? []
    }

    /// Update profile associations for a function block index.
    public func setProfileAssociations(for index: UInt8, profiles: [String]) {
        profileMap[index] = profiles
    }

    /// Add or remove a single profile association for a function block index.
    public func updateProfileAssociation(functionBlock index: UInt8, profileId: String, enabled: Bool) {
        var existing = profileMap[index] ?? []
        if enabled {
            if !existing.contains(profileId) {
                existing.append(profileId)
            }
        } else {
            existing.removeAll { $0 == profileId }
        }
        profileMap[index] = existing
    }

    /// Set allowed message types (mt nibble) for a given group in a GTB context.
    public func setGtbAllowedMessageTypes(for group: UInt8, allowed: Set<UInt8>) {
        gtbAllowedMt[group & 0x0F] = allowed
    }

    /// Apply a GTB descriptor (e.g., parsed from USB) to seed per-group allowed message types.
    public func apply(gtbDescriptor: GtbDescriptor) {
        for (group, mts) in gtbDescriptor.groups {
            setGtbAllowedMessageTypes(for: group, allowed: mts)
        }
    }

    /// Get allowed message types (if any) for a given group.
    public func allowedMessageTypes(for group: UInt8) -> Set<UInt8>? {
        gtbAllowedMt[group & 0x0F]
    }

    /// Enforce allowed message types if GTB context exists for the group.
    public func enforceAllowedMessageType(mt: UInt8, group: UInt8) throws {
        if let allowed = allowedMessageTypes(for: group) {
            try GTBValidator.enforceAllowedMessageType(mt: mt, allowed: allowed)
        }
    }
}
