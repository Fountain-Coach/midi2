/// UMP Type 0x0 Utility messages (groupless).
public struct UtilityBody: Equatable {
    /// The opcode describing the utility message.
    public var opcode: UtilityOpcode
    /// Raw 16‑bit value carried in bytes 2 and 3 of the packet.
    public var value: UInt16

    /// Creates a new body with the supplied opcode and value.
    public init(opcode: UtilityOpcode, value: UInt16 = 0) {
        self.opcode = opcode
        self.value = value
    }

    /// Encodes the body into a 32‑bit UMP packet.
    public func ump() -> UmpPacket32 {
        let byte0 = UInt32(0x0 << 4) // message type 0x0, groupless
        let word = (byte0 << 24) | (UInt32(opcode.rawValue) << 16) | UInt32(value)
        return UmpPacket32(word: word)
    }

    /// Decodes a body from a 32‑bit UMP packet.
    /// Returns `nil` if the packet is not a Utility message.
    public init?(ump: UmpPacket32) {
        let word = ump.word
        let byte0 = UInt8((word >> 24) & 0xFF)
        let mt = byte0 >> 4
        guard mt == 0x0 else { return nil }
        guard byte0 & 0x0F == 0 else { return nil }
        let status = UInt8((word >> 16) & 0xFF)
        guard let op = UtilityOpcode(rawValue: status) else { return nil }
        let value = UInt16(word & 0xFFFF)
        self.init(opcode: op, value: value)
    }

    /// Failable initialiser that validates the packet and throws `MIDIError`
    /// on malformed input.
    public init(parsingUMP ump: UmpPacket32) throws {
        let word = ump.word
        let byte0 = UInt8((word >> 24) & 0xFF)
        let mt = byte0 >> 4
        guard mt == 0x0 else {
            throw MIDIError.malformedPacket("expected mt 0x0 but got \(mt)")
        }
        guard byte0 & 0x0F == 0 else {
            throw MIDIError.malformedPacket("utility messages must have group 0")
        }
        let status = UInt8((word >> 16) & 0xFF)
        guard let op = UtilityOpcode(rawValue: status) else {
            throw MIDIError.malformedPacket("unknown utility opcode 0x\(String(status, radix: 16))")
        }
        let value = UInt16(word & 0xFFFF)
        self.init(opcode: op, value: value)
    }
}

