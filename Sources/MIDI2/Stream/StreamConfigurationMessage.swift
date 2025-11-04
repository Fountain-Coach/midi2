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

