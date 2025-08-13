/// Common 64-bit layout for MIDI 2.0 Channel Voice messages.
///
/// Provides access to the generic fields shared by all channel voice messages
/// and convenience decoding into strongly typed variants.
public struct Midi2ChannelVoiceBody: Equatable {
    public let group: Uint4
    public let status: UInt8
    public let channel: Uint4
    public let dataByte1: UInt8
    public let dataByte2: UInt8
    public let word1: UInt32

    /// Creates a body from individual components.
    public init(group: Uint4, status: UInt8, channel: Uint4, dataByte1: UInt8, dataByte2: UInt8, word1: UInt32) {
        self.group = group
        self.status = status
        self.channel = channel
        self.dataByte1 = dataByte1
        self.dataByte2 = dataByte2
        self.word1 = word1
    }

    /// Encodes the body into a UMP packet.
    public func ump() -> UmpPacket64 {
        let word0 = UInt32(0x4 << 28) |
                    UInt32(group.rawValue) << 24 |
                    UInt32(status & 0xF) << 20 |
                    UInt32(channel.rawValue) << 16 |
                    UInt32(dataByte1) << 8 |
                    UInt32(dataByte2)
        return UmpPacket64(word0: word0, word1: word1)
    }

    /// Creates a body by parsing a UMP packet.
    public init?(ump: UmpPacket64) {
        let mt = (ump.word0 >> 28) & 0xF
        guard mt == 0x4 else { return nil }
        guard let group = Uint4(UInt8((ump.word0 >> 24) & 0xF)) else { return nil }
        let status = UInt8((ump.word0 >> 20) & 0xF)
        guard let channel = Uint4(UInt8((ump.word0 >> 16) & 0xF)) else { return nil }
        let byte1 = UInt8((ump.word0 >> 8) & 0xFF)
        let byte2 = UInt8(ump.word0 & 0xFF)
        self.init(group: group, status: status, channel: channel, dataByte1: byte1, dataByte2: byte2, word1: ump.word1)
    }

    /// Attempts to decode the body into a strongly typed variant.
    public func variant() -> Midi2ChannelVoiceVariants? {
        Midi2ChannelVoiceVariants(ump: ump())
    }
}
