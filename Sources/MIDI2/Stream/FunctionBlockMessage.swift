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

    // Provisional field mapping (spec §5.4):
    // data1: [kind:2][index:6] where kind=mt flags, index=function block index
    // data2: [flags:2][count:6] where flags may encode direction or active
    public var kind: UInt8 {
        get { (data1 >> 6) & 0x03 }
        set { data1 = (data1 & 0x3F) | ((newValue & 0x03) << 6) }
    }
    public var index: UInt8 {
        get { data1 & 0x3F }
        set { data1 = (data1 & 0xC0) | (newValue & 0x3F) }
    }
    public var flags: UInt8 {
        get { (data2 >> 6) & 0x03 }
        set { data2 = (data2 & 0x3F) | ((newValue & 0x03) << 6) }
    }
    public var count: UInt8 {
        get { data2 & 0x3F }
        set { data2 = (data2 & 0xC0) | (newValue & 0x3F) }
    }

    public init(kind: UInt8, index: UInt8, flags: UInt8, count: UInt8) {
        self.data1 = ((kind & 0x03) << 6) | (index & 0x3F)
        self.data2 = ((flags & 0x03) << 6) | (count & 0x3F)
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
