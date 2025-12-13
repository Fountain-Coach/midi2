/// Group Terminal Blocks aggregate, composed from Function Block info messages.
public struct GroupTerminalBlock: Equatable {
    public var index: UInt8
    public var firstGroup: UInt8 // 0..15
    public var groupCount: UInt8 // 0..15
    public var active: Bool
    public var direction: FunctionBlockDirection
    public var midi1Bandwidth: Midi1Bandwidth

    public init(index: UInt8, firstGroup: UInt8, groupCount: UInt8, active: Bool = false, direction: FunctionBlockDirection = .reserved, midi1Bandwidth: Midi1Bandwidth = .notMidi1) {
        self.index = index
        self.firstGroup = firstGroup & 0x0F
        self.groupCount = groupCount & 0x0F
        self.active = active
        self.direction = direction
        self.midi1Bandwidth = midi1Bandwidth
    }
}

public struct GroupTerminalBlocks: Equatable {
    public var blocks: [GroupTerminalBlock]

    public init(blocks: [GroupTerminalBlock]) {
        self.blocks = blocks
    }

    /// Encode into a sequence of `.functionBlockInfoNotification` packets, one per block.
    public func umps(group: Uint4) throws -> [UmpPacket64] {
        try blocks.map { blk in
            let info = try FunctionBlockInfoNotification(
                index: blk.index,
                firstGroup: blk.firstGroup,
                groupCount: blk.groupCount,
                active: blk.active,
                direction: blk.direction,
                midi1Bandwidth: blk.midi1Bandwidth
            )
            return info.ump(group: group)
        }
    }

    /// Parse from a sequence of `.functionBlockInfoNotification` packets.
    public init(parsingUMPs packets: [UmpPacket64]) throws {
        var result: [GroupTerminalBlock] = []
        result.reserveCapacity(packets.count)
        for pkt in packets {
            let info = try FunctionBlockInfoNotification(parsingUMP64: pkt)
            let blk = GroupTerminalBlock(index: info.index,
                                         firstGroup: info.firstGroup,
                                         groupCount: info.groupCount,
                                         active: info.active,
                                         direction: info.direction,
                                         midi1Bandwidth: info.midi1Bandwidth)
            result.append(blk)
        }
        self.blocks = result
    }
}
