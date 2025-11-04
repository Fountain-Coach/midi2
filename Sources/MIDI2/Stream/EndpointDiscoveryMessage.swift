/// Typed wrapper for Stream message opcode `.endpointDiscovery` (mt=0xF).
///
/// This message is used during endpoint discovery. The underlying format is a
/// 32-bit UMP with two data bytes. Bit-level semantics should follow M2-104-UM §5;
/// this wrapper preserves the two data bytes with a dedicated type to avoid opcode mixups.
public struct EndpointDiscoveryMessage: Equatable {
    public var data1: UInt8
    public var data2: UInt8

    public init(data1: UInt8 = 0, data2: UInt8 = 0) {
        self.data1 = data1
        self.data2 = data2
    }

    // Spec-aligned nibble mapping (schema §StreamBody.endpointDiscovery):
    // - data1: [major:4][minor:4]
    // - data2: [reserved:4][maxGroups:4]
    public var majorVersion: UInt8 {
        get { (data1 >> 4) & 0x0F }
        set { data1 = (newValue & 0x0F) << 4 | (data1 & 0x0F) }
    }
    public var minorVersion: UInt8 {
        get { data1 & 0x0F }
        set { data1 = (data1 & 0xF0) | (newValue & 0x0F) }
    }
    public var reservedHighNibble: UInt8 {
        get { (data2 >> 4) & 0x0F }
        set { data2 = (newValue & 0x0F) << 4 | (data2 & 0x0F) }
    }
    public var maxGroups: UInt8 {
        get { data2 & 0x0F }
        set { data2 = (data2 & 0xF0) | (newValue & 0x0F) }
    }

    public init(majorVersion: UInt8, minorVersion: UInt8, maxGroups: UInt8) {
        self.data1 = ((majorVersion & 0x0F) << 4) | (minorVersion & 0x0F)
        self.data2 = 0x00 | (maxGroups & 0x0F)
    }

    /// Encode to a 32-bit UMP in the given group.
    public func ump(group: Uint4) -> UmpPacket32 {
        StreamBody(opcode: .endpointDiscovery, data1: data1, data2: data2).ump(group: group)
    }

    /// Decode from a 32-bit UMP. Fails if the opcode does not match.
    public init?(ump: UmpPacket32) {
        guard let body = StreamBody(ump: ump), body.opcode == .endpointDiscovery else { return nil }
        // Reserved high nibble in data2 must be zero per spec
        guard (body.data2 & 0xF0) == 0 else { return nil }
        self.init(data1: body.data1, data2: body.data2)
    }

    /// Throwing decode from a 32-bit UMP that validates opcode.
    public init(parsingUMP ump: UmpPacket32) throws {
        let body = try StreamBody(parsingUMP: ump)
        guard body.opcode == .endpointDiscovery else {
            throw MIDIError.malformedPacket("expected endpointDiscovery opcode, got \(body.opcode)")
        }
        // Reserved high nibble in data2 must be zero per spec
        guard (body.data2 & 0xF0) == 0 else {
            throw MIDIError.malformedPacket("reserved bits non-zero")
        }
        self.init(data1: body.data1, data2: body.data2)
    }
}
