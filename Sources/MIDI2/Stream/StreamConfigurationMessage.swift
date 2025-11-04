/// Typed wrapper for Stream message opcode `.streamConfiguration` (mt=0xF).
///
/// Encodes/decodes the two data bytes of the message without interpreting bitfields.
/// See M2-104-UM §5.3 for the normative mapping.
public struct StreamConfigurationMessage: Equatable {
    public var data1: UInt8
    public var data2: UInt8

    public init(data1: UInt8 = 0, data2: UInt8 = 0) {
        self.data1 = data1
        self.data2 = data2
    }

    // Provisional field mapping (spec §5.3):
    // data1: [b7:reserved][b6..5:protocol][b4:jr][b3..1:mode][b0:isReply]
    public var isReply: Bool {
        get { (data1 & 0x01) != 0 }
        set { data1 = newValue ? (data1 | 0x01) : (data1 & ~0x01) }
    }
    public var mode: UInt8 {
        get { (data1 >> 1) & 0x07 }
        set { data1 = (data1 & ~(0x07 << 1)) | ((newValue & 0x07) << 1) }
    }
    public var jrRequested: Bool {
        get { (data1 & 0x10) != 0 }
        set { data1 = newValue ? (data1 | 0x10) : (data1 & ~0x10) }
    }
    public var protocolSelection: UInt8 {
        get { (data1 >> 5) & 0x03 }
        set { data1 = (data1 & ~(0x03 << 5)) | ((newValue & 0x03) << 5) }
    }
    public var reservedBit7: Bool {
        get { (data1 & 0x80) != 0 }
        set { data1 = newValue ? (data1 | 0x80) : (data1 & ~0x80) }
    }
    /// Group mask or additional config byte.
    public var groupMask: UInt8 {
        get { data2 }
        set { data2 = newValue }
    }

    public init(isReply: Bool, mode: UInt8, jrRequested: Bool, protocolSelection: UInt8, groupMask: UInt8) {
        var d1: UInt8 = 0
        d1 |= isReply ? 0x01 : 0
        d1 |= (mode & 0x07) << 1
        if jrRequested { d1 |= 0x10 }
        d1 |= (protocolSelection & 0x03) << 5
        self.data1 = d1
        self.data2 = groupMask
    }

    public func ump(group: Uint4) -> UmpPacket32 {
        StreamBody(opcode: .streamConfiguration, data1: data1, data2: data2).ump(group: group)
    }

    public init?(ump: UmpPacket32) {
        guard let body = StreamBody(ump: ump), body.opcode == .streamConfiguration else { return nil }
        self.init(data1: body.data1, data2: body.data2)
    }

    public init(parsingUMP ump: UmpPacket32) throws {
        let body = try StreamBody(parsingUMP: ump)
        guard body.opcode == .streamConfiguration else {
            throw MIDIError.malformedPacket("expected streamConfiguration opcode, got \(body.opcode)")
        }
        self.init(data1: body.data1, data2: body.data2)
    }
}
