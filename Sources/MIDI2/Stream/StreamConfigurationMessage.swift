/// Typed wrapper for Stream message opcodes `.streamConfigurationRequest` / `.streamConfigurationNotification` (mt=0xF).
///
/// Encodes/decodes the two data bytes of the message without interpreting bitfields.
/// See M2-104-UM §5.3 for the normative mapping.
public struct StreamConfigurationMessage: Equatable {
    public var opcode: StreamOpcode
    public var data1: UInt8
    public var data2: UInt8

    public init(opcode: StreamOpcode = .streamConfigurationRequest, data1: UInt8 = 0, data2: UInt8 = 0) {
        self.opcode = opcode
        self.data1 = data1
        self.data2 = data2
    }

    // Spec-aligned field mapping (schema §StreamBody.streamConfig*):
    // data1 bits: [7:0]
    //  - b0: reserved (0)
    //  - b1: jrTimestampsTx
    //  - b2: jrTimestampsRx
    //  - b3..4: reserved (0)
    //  - b5..6: protocol (0 = midi1, 1 = midi2)
    //  - b7: reserved (0)
    public enum ProtocolSelection: UInt8 { case midi1 = 0, midi2 = 1 }

    public var isNotification: Bool {
        get { opcode == .streamConfigurationNotification }
        set { opcode = newValue ? .streamConfigurationNotification : .streamConfigurationRequest }
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
    public var reservedBits: UInt8 { data1 & 0b1001_1001 }
    public var reservedByte2: UInt8 {
        get { data2 }
        set { data2 = newValue }
    }

    public init(isNotification: Bool, jrTimestampsTx: Bool, jrTimestampsRx: Bool, protocolSelection: ProtocolSelection) {
        var d1: UInt8 = 0
        if jrTimestampsTx { d1 |= 0x02 }
        if jrTimestampsRx { d1 |= 0x04 }
        let proto: UInt8 = (protocolSelection == .midi2) ? 1 : 0
        d1 |= (proto & 0x03) << 5
        self.opcode = isNotification ? .streamConfigurationNotification : .streamConfigurationRequest
        self.data1 = d1
        self.data2 = 0
    }

    public func ump(group: Uint4) -> UmpPacket32 {
        StreamBody(opcode: opcode, data1: data1, data2: data2).ump(group: group)
    }

    public init?(ump: UmpPacket32) {
        guard let body = StreamBody(ump: ump),
              body.opcode == .streamConfigurationRequest || body.opcode == .streamConfigurationNotification else { return nil }
        // Validate reserved bits: data1 b0,b3,b4,b7 must be 0; protocol must be 0 or 1; data2 must be 0
        let reservedMask: UInt8 = 0b1001_1001 // b7, b4, b3, b0
        guard (body.data1 & reservedMask) == 0 else { return nil }
        let protoField = (body.data1 >> 5) & 0x03
        guard protoField == 0 || protoField == 1 else { return nil }
        guard body.data2 == 0 else { return nil }
        self.init(opcode: body.opcode, data1: body.data1, data2: body.data2)
    }

    public init(parsingUMP ump: UmpPacket32) throws {
        let body = try StreamBody(parsingUMP: ump)
        guard body.opcode == .streamConfigurationRequest || body.opcode == .streamConfigurationNotification else {
            throw MIDIError.malformedPacket("expected streamConfiguration opcode, got \(body.opcode)")
        }
        // Validate reserved bits: data1 b0,b3,b4,b7 must be 0; protocol must be 0 or 1; data2 must be 0
        let reservedMask: UInt8 = 0b1001_1001 // b7, b4, b3, b0
        guard (body.data1 & reservedMask) == 0 else {
            throw MIDIError.malformedPacket("reserved bits non-zero")
        }
        let protoField = (body.data1 >> 5) & 0x03
        guard protoField == 0 || protoField == 1 else {
            throw MIDIError.malformedPacket("reserved bits non-zero")
        }
        guard body.data2 == 0 else {
            throw MIDIError.malformedPacket("reserved bits non-zero")
        }
        self.init(opcode: body.opcode, data1: body.data1, data2: body.data2)
    }
}
