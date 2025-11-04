/// Typed wrapper for Stream message opcode `.functionBlock` (mt=0xF).
///
/// Encapsulates Function Block discovery/information. The underlying 32-bit UMP
/// packs two data bytes. Field semantics should follow M2-104-UM §5.4; this wrapper
/// intentionally preserves raw bytes while providing opcode-checked construction.
public struct FunctionBlockMessage: Equatable {
    public var data1: UInt8
    public var data2: UInt8

    public init(data1: UInt8 = 0, data2: UInt8 = 0) {
        self.data1 = data1
        self.data2 = data2
    }

    // Spec-aligned nibble mapping (schema §StreamBody.functionBlockInfo):
    // data1: index (UInt8)
    // data2: [firstGroup:4][groupCount:4]
    public var index: UInt8 {
        get { data1 }
        set { data1 = newValue }
    }
    public var firstGroup: UInt8 {
        get { (data2 >> 4) & 0x0F }
        set { data2 = (data2 & 0x0F) | ((newValue & 0x0F) << 4) }
    }
    public var groupCount: UInt8 {
        get { data2 & 0x0F }
        set { data2 = (data2 & 0xF0) | (newValue & 0x0F) }
    }

    public init(index: UInt8, firstGroup: UInt8, groupCount: UInt8) {
        self.data1 = index
        self.data2 = ((firstGroup & 0x0F) << 4) | (groupCount & 0x0F)
    }

    public func ump(group: Uint4) -> UmpPacket32 {
        StreamBody(opcode: .functionBlock, data1: data1, data2: data2).ump(group: group)
    }

    public init?(ump: UmpPacket32) {
        guard let body = StreamBody(ump: ump), body.opcode == .functionBlock else { return nil }
        self.init(data1: body.data1, data2: body.data2)
    }

    public init(parsingUMP ump: UmpPacket32) throws {
        let body = try StreamBody(parsingUMP: ump)
        guard body.opcode == .functionBlock else {
            throw MIDIError.malformedPacket("expected functionBlock opcode, got \(body.opcode)")
        }
        self.init(data1: body.data1, data2: body.data2)
    }
}
