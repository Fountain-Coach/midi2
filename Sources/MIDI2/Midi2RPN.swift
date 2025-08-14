/// Registered Parameter Number (RPN) address.
///
/// RPN addresses are 14-bit values. This enum models well-known
/// addresses and allows representing any other address within the
/// valid range.
public enum Midi2RPNAddress: Equatable {
    /// Per-Note Pitch controller (RPN 0).
    case perNotePitch
    /// Per-Note Pressure controller (RPN 1).
    case perNotePressure
    /// Per-Note Timbre controller (RPN 2).
    case perNoteTimbre
    /// Any other RPN address within the 14-bit range.
    case other(Swift.UInt16)

    /// Creates an RPN address from the raw 14-bit value. Returns `nil` if the
    /// value is outside the permitted range `0...0x3FFF`.
    public init?(rawValue: Swift.UInt16) {
        guard rawValue <= 0x3FFF else { return nil }
        switch rawValue {
            case 0x0000: self = .perNotePitch
            case 0x0001: self = .perNotePressure
            case 0x0002: self = .perNoteTimbre
            default: self = .other(rawValue)
        }
    }

    /// The raw 14-bit address value.
    public var rawValue: Swift.UInt16 {
        switch self {
            case .perNotePitch: return 0x0000
            case .perNotePressure: return 0x0001
            case .perNoteTimbre: return 0x0002
            case .other(let v): return v
        }
    }
}

/// Registered Controller (absolute).
///
/// Carries a 32-bit value for a Registered Parameter Number (RPN)
/// address. The message is encoded as a 64-bit Universal MIDI Packet with
/// status nibble ``0x2``. The 14-bit address is split into a 7-bit bank and
/// 7-bit index occupying the third and fourth bytes of the first word. The
/// parameter value is stored in the second word.
public struct Midi2RPN: Equatable {
    public let group: Uint4
    public let channel: Uint4
    public let address: Midi2RPNAddress
    public let value: Swift.UInt32

    public init(group: Uint4, channel: Uint4, address: Midi2RPNAddress, value: Swift.UInt32) {
        self.group = group
        self.channel = channel
        self.address = address
        self.value = value
    }

    /// Encodes the message into a Universal MIDI Packet.
    public func ump() -> UmpPacket64 {
        let raw = address.rawValue
        let bank = UInt8((raw >> 7) & 0x7F)
        let index = UInt8(raw & 0x7F)
        let word0 = UInt32(0x4 << 28) |
                    UInt32(group.rawValue) << 24 |
                    UInt32(0x2) << 20 |
                    UInt32(channel.rawValue) << 16 |
                    UInt32(bank) << 8 |
                    UInt32(index)
        return UmpPacket64(word0: word0, word1: value)
    }

    /// Failable initializer from a Universal MIDI Packet.
    public init?(ump: UmpPacket64) {
        guard (ump.word0 >> 28) & 0xF == 0x4 else { return nil }
        guard ((ump.word0 >> 20) & 0xF) == 0x2 else { return nil }
        let bank = UInt8((ump.word0 >> 8) & 0xFF)
        let index = UInt8(ump.word0 & 0xFF)
        guard bank < 0x80, index < 0x80 else { return nil }
        guard let group = Uint4(UInt8((ump.word0 >> 24) & 0xF)) else { return nil }
        guard let channel = Uint4(UInt8((ump.word0 >> 16) & 0xF)) else { return nil }
        let addrValue = Swift.UInt16(bank) << 7 | Swift.UInt16(index)
        guard let addr = Midi2RPNAddress(rawValue: addrValue) else { return nil }
        let value = ump.word1
        self.init(group: group, channel: channel, address: addr, value: value)
    }

    /// Parses a Universal MIDI Packet into an RPN message.
    /// Throws ``MIDIError.malformedPacket`` if the packet is not valid.
    public init(parsingUMP ump: UmpPacket64) throws {
        guard (ump.word0 >> 28) & 0xF == 0x4 else {
            throw MIDIError.malformedPacket("expected mt 0x4 but got \(((ump.word0 >> 28) & 0xF))")
        }
        guard ((ump.word0 >> 20) & 0xF) == 0x2 else {
            throw MIDIError.malformedPacket("expected status 0x2 but got \(((ump.word0 >> 20) & 0xF))")
        }
        let bankByte = Swift.UInt8((ump.word0 >> 8) & 0xFF)
        let indexByte = Swift.UInt8(ump.word0 & 0xFF)
        guard bankByte < 0x80 else {
            throw MIDIError.malformedPacket("bank byte msb set")
        }
        guard indexByte < 0x80 else {
            throw MIDIError.malformedPacket("index byte msb set")
        }
        let group = try Uint4(validating: Swift.UInt8((ump.word0 >> 24) & 0xF))
        let channel = try Uint4(validating: Swift.UInt8((ump.word0 >> 16) & 0xF))
        let addrValue = Swift.UInt16(bankByte) << 7 | Swift.UInt16(indexByte)
        guard let addr = Midi2RPNAddress(rawValue: addrValue) else {
            throw MIDIError.malformedPacket("invalid address")
        }
        let value = ump.word1
        self.init(group: group, channel: channel, address: addr, value: value)
    }
}
