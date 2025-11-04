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

    // Spec-aligned field mapping (schema §StreamBody.streamConfig*):
    // data1 bits: [7:0]
    //  - b0: isNotification (1 = notification/reply, 0 = request)
    //  - b1: jrTimestampsTx
    //  - b2: jrTimestampsRx
    //  - b3..4: reserved (0)
    //  - b5..6: protocol (0 = midi1, 1 = midi2)
    //  - b7: reserved (0)
    public enum ProtocolSelection: UInt8 { case midi1 = 0, midi2 = 1 }

    public var isNotification: Bool {
        get { (data1 & 0x01) != 0 }
        set { data1 = newValue ? (data1 | 0x01) : (data1 & ~0x01) }
    }
    public var jrTimestampsTx: Bool {
        get { (data1 & 0x02) != 0 }
        set { data1 = newValue ? (data1 | 0x02) : (data1 & ~0x02) }
    }
    public var jrTimestampsRx: Bool {
        get { (data1 & 0x04) != 0 }
        set { data1 = newValue ? (data1 | 0x04) : (data1 & ~0x04) }
    }
    public var protocolSelection: ProtocolSelection {
        get { (((data1 >> 5) & 0x03) == 1) ? .midi2 : .midi1 }
        set {
            let val: UInt8 = (newValue == .midi2) ? 1 : 0
            data1 = (data1 & ~(0x03 << 5)) | ((val & 0x03) << 5)
        }
    }
    public var reservedBits: UInt8 { (data1 & 0x98) >> 3 }
    public var reservedByte2: UInt8 {
        get { data2 }
        set { data2 = newValue }
    }

    public init(isNotification: Bool, jrTimestampsTx: Bool, jrTimestampsRx: Bool, protocolSelection: ProtocolSelection) {
        var d1: UInt8 = 0
        if isNotification { d1 |= 0x01 }
        if jrTimestampsTx { d1 |= 0x02 }
        if jrTimestampsRx { d1 |= 0x04 }
        let proto: UInt8 = (protocolSelection == .midi2) ? 1 : 0
        d1 |= (proto & 0x03) << 5
        self.data1 = d1
        self.data2 = 0
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
