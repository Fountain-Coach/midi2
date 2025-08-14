/// Non-Registered Parameter Number (NRPN) address.
///
/// NRPN addresses are 14-bit values representing assignable controller
/// numbers. All values in the range `0...0x3FFF` are valid.
public enum Midi2NRPNAddress: Equatable {
    /// The raw NRPN value.
    case number(Swift.UInt16)

    /// Creates an NRPN address from the raw 14-bit value. Returns `nil` if the
    /// value is outside the permitted range `0...0x3FFF`.
    public init?(rawValue: Swift.UInt16) {
        guard rawValue <= 0x3FFF else { return nil }
        self = .number(rawValue)
    }

    /// The raw 14-bit address value.
    public var rawValue: Swift.UInt16 {
        switch self {
            case .number(let v): return v
        }
    }
}

/// Assignable Controller (absolute).
///
/// Carries a 32-bit value for a Non-Registered Parameter Number (NRPN)
/// address. The message is encoded as a 64-bit Universal MIDI Packet with
/// status nibble ``0x3``. The 14-bit address is split into a 7-bit bank and
/// 7-bit index within the first word. The parameter value is stored in the
/// second word.
public struct Midi2NRPN: Equatable {
    public let group: Uint4
    public let channel: Uint4
    public let address: Midi2NRPNAddress
    public let value: Swift.UInt32

    public init(group: Uint4, channel: Uint4, address: Midi2NRPNAddress, value: Swift.UInt32) {
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
                    UInt32(0x3) << 20 |
                    UInt32(channel.rawValue) << 16 |
                    UInt32(bank) << 8 |
                    UInt32(index)
        return UmpPacket64(word0: word0, word1: value)
    }

    /// Failable initializer from a Universal MIDI Packet.
    public init?(ump: UmpPacket64) {
        guard (ump.word0 >> 28) & 0xF == 0x4 else { return nil }
        guard ((ump.word0 >> 20) & 0xF) == 0x3 else { return nil }
        let bank = UInt8((ump.word0 >> 8) & 0xFF)
        let index = UInt8(ump.word0 & 0xFF)
        guard bank < 0x80, index < 0x80 else { return nil }
        guard let group = Uint4(UInt8((ump.word0 >> 24) & 0xF)) else { return nil }
        guard let channel = Uint4(UInt8((ump.word0 >> 16) & 0xF)) else { return nil }
        let addrValue = Swift.UInt16(bank) << 7 | Swift.UInt16(index)
        guard let addr = Midi2NRPNAddress(rawValue: addrValue) else { return nil }
        let value = ump.word1
        self.init(group: group, channel: channel, address: addr, value: value)
    }

    /// Parses a Universal MIDI Packet into an NRPN message.
    /// Throws ``MIDIError.malformedPacket`` if the packet is not valid.
    public init(parsingUMP ump: UmpPacket64) throws {
        guard (ump.word0 >> 28) & 0xF == 0x4 else {
            throw MIDIError.malformedPacket("expected mt 0x4 but got \(((ump.word0 >> 28) & 0xF))")
        }
        guard ((ump.word0 >> 20) & 0xF) == 0x3 else {
            throw MIDIError.malformedPacket("expected status 0x3 but got \(((ump.word0 >> 20) & 0xF))")
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
        guard let addr = Midi2NRPNAddress(rawValue: addrValue) else {
            throw MIDIError.malformedPacket("invalid address")
        }
        let value = ump.word1
        self.init(group: group, channel: channel, address: addr, value: value)
    }
}
