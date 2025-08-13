/// 64-bit UMP header for MIDI 2.0 Channel Voice.
public struct UmpHeader64: Equatable {
    /// Raw 32-bit word representing the header.
    public let word: UInt32

    /// Creates a header from a raw word.  Fails if the message type nibble is
    /// not ``0x4``.
    public init?(word: UInt32) {
        guard UInt8((word >> 28) & 0xF) == 0x4 else { return nil }
        self.word = word
    }

    /// Creates a header from individual fields.
    public init?(
        group: Uint4,
        status: Uint4,
        channel: Uint4,
        byte3: UInt8,
        byte4: UInt8
    ) {
        // Channel voice status nibbles range 8-F.
        guard status.rawValue >= 0x8 else { return nil }

        let word =
            (UInt32(0x4) << 28) |
            (UInt32(group.rawValue) << 24) |
            (UInt32(status.rawValue) << 20) |
            (UInt32(channel.rawValue) << 16) |
            (UInt32(byte3) << 8) |
            UInt32(byte4)

        self.word = word
    }

    /// Message type nibble (always ``0x4``).
    public var messageType: UInt8 { UInt8((word >> 28) & 0xF) }

    /// Group nibble.
    public var group: Uint4 { Uint4(UInt8((word >> 24) & 0xF))! }

    /// Status nibble (bits 23-20).
    public var status: Uint4 { Uint4(UInt8((word >> 20) & 0xF))! }

    /// Channel nibble (bits 19-16).
    public var channel: Uint4 { Uint4(UInt8((word >> 16) & 0xF))! }

    /// Byte 3 (bits 15-8).
    public var byte3: UInt8 { UInt8((word >> 8) & 0xFF) }

    /// Byte 4 (bits 7-0).
    public var byte4: UInt8 { UInt8(word & 0xFF) }

    /// Number of following 32-bit words in the packet.
    public var dataWordCount: Int { 1 }

    /// Total number of data bytes in the packet following the status nibble.
    public var dataByteCount: Int { 6 }
}

