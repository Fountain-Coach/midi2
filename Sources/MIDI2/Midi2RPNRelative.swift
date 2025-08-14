/// Registered Controller (relative).
///
/// Encodes a relative delta for a Registered Parameter Number (RPN)
/// address. The message is transported as a 64-bit UMP Channel Voice packet
/// with status nibble ``0x4``. The 14-bit address is split into a 7-bit bank
/// and 7-bit index, each occupying one byte in the first word. The 32-bit
/// delta is encoded as a two's complement value in the second word.
public struct Midi2RPNRelative: Equatable {
    public let group: Uint4
    public let channel: Uint4
    public let address: Midi2RPNAddress
    public let delta: Swift.Int32

    public init(group: Uint4, channel: Uint4, address: Midi2RPNAddress, delta: Swift.Int32) {
        self.group = group
        self.channel = channel
        self.address = address
        self.delta = delta
    }

    /// Encodes the message into a Universal MIDI Packet.
    public func ump() -> UmpPacket64 {
        let raw = address.rawValue
        let bank = UInt8((raw >> 7) & 0x7F)
        let index = UInt8(raw & 0x7F)
        let word0 = UInt32(0x4 << 28) |
                    UInt32(group.rawValue) << 24 |
                    UInt32(0x4) << 20 |
                    UInt32(channel.rawValue) << 16 |
                    UInt32(bank) << 8 |
                    UInt32(index)
        return UmpPacket64(word0: word0, word1: UInt32(bitPattern: delta))
    }

    /// Failable initializer from a Universal MIDI Packet.
    public init?(ump: UmpPacket64) {
        guard (ump.word0 >> 28) & 0xF == 0x4 else { return nil }
        guard ((ump.word0 >> 20) & 0xF) == 0x4 else { return nil }
        let bank = UInt8((ump.word0 >> 8) & 0xFF)
        let index = UInt8(ump.word0 & 0xFF)
        guard bank < 0x80, index < 0x80 else { return nil }
        guard let group = Uint4(UInt8((ump.word0 >> 24) & 0xF)) else { return nil }
        guard let channel = Uint4(UInt8((ump.word0 >> 16) & 0xF)) else { return nil }
        let addrValue = UInt16(bank) << 7 | UInt16(index)
        guard let addr = Midi2RPNAddress(rawValue: addrValue) else { return nil }
        let delta = Swift.Int32(bitPattern: ump.word1)
        self.init(group: group, channel: channel, address: addr, delta: delta)
    }

    /// Parses a Universal MIDI Packet into a RPN relative message.
    /// Throws ``MIDIError.malformedPacket`` if the packet is not a valid
    /// RPN relative message.
    public init(parsingUMP ump: UmpPacket64) throws {
        guard (ump.word0 >> 28) & 0xF == 0x4 else {
            throw MIDIError.malformedPacket("expected mt 0x4 but got \(((ump.word0 >> 28) & 0xF))")
        }
        guard ((ump.word0 >> 20) & 0xF) == 0x4 else {
            throw MIDIError.malformedPacket("expected status 0x4 but got \(((ump.word0 >> 20) & 0xF))")
        }
        let bankByte = UInt8((ump.word0 >> 8) & 0xFF)
        let indexByte = UInt8(ump.word0 & 0xFF)
        guard bankByte < 0x80 else {
            throw MIDIError.malformedPacket("bank byte msb set")
        }
        guard indexByte < 0x80 else {
            throw MIDIError.malformedPacket("index byte msb set")
        }
        let group = try Uint4(validating: UInt8((ump.word0 >> 24) & 0xF))
        let channel = try Uint4(validating: UInt8((ump.word0 >> 16) & 0xF))
        let addrValue = UInt16(bankByte) << 7 | UInt16(indexByte)
        guard let addr = Midi2RPNAddress(rawValue: addrValue) else {
            throw MIDIError.malformedPacket("invalid address")
        }
        let delta = Swift.Int32(bitPattern: ump.word1)
        self.init(group: group, channel: channel, address: addr, delta: delta)
    }
}
