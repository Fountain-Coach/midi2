/// Group Terminal Blocks aggregate, composed from Function Block info messages.
public struct GroupTerminalBlock: Equatable {
    public var index: UInt8
    public var firstGroup: UInt8 // 0..15
    public var groupCount: UInt8 // 0..15

    public init(index: UInt8, firstGroup: UInt8, groupCount: UInt8) {
        self.index = index
        self.firstGroup = firstGroup & 0x0F
        self.groupCount = groupCount & 0x0F
    }
}

public struct GroupTerminalBlocks: Equatable {
    public var blocks: [GroupTerminalBlock]

    public init(blocks: [GroupTerminalBlock]) {
        self.blocks = blocks
    }

    /// Encode into a sequence of `.functionBlock` info packets, one per block.
    public func umps(group: Uint4) -> [UmpPacket32] {
        blocks.map { blk in
            FunctionBlockMessage(index: blk.index,
                                 firstGroup: blk.firstGroup,
                                 groupCount: blk.groupCount).ump(group: group)
        }
    }

    /// Parse from a sequence of `.functionBlock` info packets.
    public init(parsingUMPs packets: [UmpPacket32]) throws {
        var result: [GroupTerminalBlock] = []
        result.reserveCapacity(packets.count)
        for pkt in packets {
            let body = try StreamBody(parsingUMP: pkt)
            guard body.opcode == .functionBlock else {
                throw MIDIError.malformedPacket("expected functionBlock opcode, got \(body.opcode)")
            }
            let msg = FunctionBlockMessage(data1: body.data1, data2: body.data2)
            let blk = GroupTerminalBlock(index: msg.index,
                                         firstGroup: msg.firstGroup,
                                         groupCount: msg.groupCount)
            result.append(blk)
        }
        self.blocks = result
    }
}

