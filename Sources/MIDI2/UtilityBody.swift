/// UMP Type 0x0 Utility messages (groupless).
public struct UtilityBody: Equatable {
    /// The opcode describing the utility message.
    public var opcode: UtilityOpcode
    /// Raw 20-bit payload carried in the low bits of the packet.
    public var value: UInt32

    /// Creates a new body with the supplied opcode and value.
    public init(opcode: UtilityOpcode, value: UInt32 = 0) {
        self.opcode = opcode
        self.value = value & 0xFFFFF
    }

    /// Encodes the body into a 32‑bit UMP packet.
    public func ump() -> UmpPacket32 {
        let word = (UInt32(0x0) << 28) |
            (UInt32(opcode.rawValue) << 20) |
            (UInt32(value) & 0xFFFFF)
        return UmpPacket32(word: word)
    }

    /// Decodes a body from a 32‑bit UMP packet.
    /// Returns `nil` if the packet is not a Utility message.
    public init?(ump: UmpPacket32) {
        let word = ump.word
        let mt = UInt8((word >> 28) & 0xF)
        guard mt == 0x0 else { return nil }
        guard ((word >> 24) & 0xF) == 0 else { return nil }
        let opcodeRaw = UInt8((word >> 20) & 0xF)
        guard let op = UtilityOpcode(rawValue: opcodeRaw) else { return nil }
        let value = word & 0xFFFFF
        if op == .noop, value != 0 { return nil }
        if op == .dctpq, (value & 0xF0000) != 0 { return nil }
        self.init(opcode: op, value: value)
    }

    /// Failable initialiser that validates the packet and throws `MIDIError`
    /// on malformed input.
    public init(parsingUMP ump: UmpPacket32) throws {
        let word = ump.word
        let mt = UInt8((word >> 28) & 0xF)
        guard mt == 0x0 else {
            throw MIDIError.malformedPacket("expected mt 0x0 but got \(mt)")
        }
        guard ((word >> 24) & 0xF) == 0 else {
            throw MIDIError.malformedPacket("utility messages must have group 0")
        }
        let opcodeRaw = UInt8((word >> 20) & 0xF)
        guard let op = UtilityOpcode(rawValue: opcodeRaw) else {
            throw MIDIError.malformedPacket("unknown utility opcode 0x\(String(opcodeRaw, radix: 16))")
        }
        let value = word & 0xFFFFF
        if op == .noop, value != 0 {
            throw MIDIError.malformedPacket("utility noop must carry zero data")
        }
        if op == .dctpq, (value & 0xF0000) != 0 {
            throw MIDIError.malformedPacket("utility dctpq must use a 16-bit payload")
        }
        self.init(opcode: op, value: value)
    }
}
