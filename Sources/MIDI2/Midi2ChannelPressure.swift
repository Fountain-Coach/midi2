/// Status 0xD (Channel Pressure).
///
/// Represents a MIDI 2.0 Channel Voice "Channel Pressure" message. This
/// message is encoded as a 64-bit Universal MIDI Packet with the following
/// layout:
///
/// ```
/// Word0: [MT=0x4][Group][Status=0xD][Channel][Reserved=0][Reserved=0]
/// Word1: [Pressure (32 bits)]
/// ```
public struct Midi2ChannelPressure: Equatable {
    public let group: Uint4
    public let channel: Uint4
    public let pressure: UInt32

    /// Creates a new Channel Pressure message.
    public init(group: Uint4, channel: Uint4, pressure: UInt32) {
        self.group = group
        self.channel = channel
        self.pressure = pressure
    }

    /// Encodes this message into a 64-bit Universal MIDI Packet.
    public func ump() -> UmpPacket64 {
        let word0 = UInt32(0x4 << 28) |
                    UInt32(group.rawValue) << 24 |
                    UInt32(0xD) << 20 |
                    UInt32(channel.rawValue) << 16
        return UmpPacket64(word0: word0, word1: pressure)
    }

    /// Creates a Channel Pressure message from a Universal MIDI Packet.
    /// Returns `nil` if the packet does not encode a Channel Pressure message.
    public init?(ump: UmpPacket64) {
        guard (ump.word0 >> 28) & 0xF == 0x4 else { return nil }
        guard ((ump.word0 >> 20) & 0xF) == 0xD else { return nil }
        guard (ump.word0 & 0xFFFF) == 0 else { return nil }
        guard let group = Uint4(UInt8((ump.word0 >> 24) & 0xF)) else { return nil }
        guard let channel = Uint4(UInt8((ump.word0 >> 16) & 0xF)) else { return nil }
        let pressure = ump.word1
        self.init(group: group, channel: channel, pressure: pressure)
    }

    /// Parses a Universal MIDI Packet into a Channel Pressure message.
    /// Throws `MIDIError.malformedPacket` if the packet is not a Channel
    /// Pressure message.
    public init(parsingUMP ump: UmpPacket64) throws {
        guard (ump.word0 >> 28) & 0xF == 0x4 else {
            throw MIDIError.malformedPacket("expected mt 0x4 but got \(((ump.word0 >> 28) & 0xF))")
        }
        guard ((ump.word0 >> 20) & 0xF) == 0xD else {
            throw MIDIError.malformedPacket("expected status 0xD but got \(((ump.word0 >> 20) & 0xF))")
        }
        guard (ump.word0 & 0xFFFF) == 0 else {
            throw MIDIError.malformedPacket("reserved bits non-zero")
        }
        let group = try Uint4(validating: UInt8((ump.word0 >> 24) & 0xF))
        let channel = try Uint4(validating: UInt8((ump.word0 >> 16) & 0xF))
        let pressure = ump.word1
        self.init(group: group, channel: channel, pressure: pressure)
    }
}
