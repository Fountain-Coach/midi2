/// 128-bit UMP header for Data (SysEx8/MDS) and Flex Data messages.
///
/// The first word encodes the message type (``0x5`` for SysEx8 or ``0xD`` for
/// Flex Data), an optional group, an 8-bit status field and two data bytes that
/// commonly represent byte counts.
public struct UmpHeader128: Equatable {
    /// Raw 32-bit word representing the header.
    public let word: UInt32

    /// Creates a header from a raw word.  Fails if the message type is not
    /// ``0x5`` or ``0xD``.
    public init?(word: UInt32) {
        let mt = UInt8((word >> 28) & 0xF)
        guard mt == 0x5 || mt == 0xD else { return nil }
        self.word = word
    }

    /// Creates a header from individual fields.
    public init?(
        messageType: UInt8,
        group: Uint4,
        status: UInt8,
        byte3: UInt8,
        byte4: UInt8
    ) {
        guard messageType == 0x5 || messageType == 0xD else { return nil }

        let word =
            (UInt32(messageType) << 28) |
            (UInt32(group.rawValue) << 24) |
            (UInt32(status) << 16) |
            (UInt32(byte3) << 8) |
            UInt32(byte4)

        self.word = word
    }

    /// Message type nibble (``0x5`` or ``0xD``).
    public var messageType: UInt8 { UInt8((word >> 28) & 0xF) }

    /// Group nibble.
    public var group: Uint4 { Uint4(UInt8((word >> 24) & 0xF))! }

    /// Status byte (bits 23-16).
    public var status: UInt8 { UInt8((word >> 16) & 0xFF) }

    /// Byte 3 (bits 15-8) – often the MSB of a byte count.
    public var byte3: UInt8 { UInt8((word >> 8) & 0xFF) }

    /// Byte 4 (bits 7-0) – often the LSB of a byte count.
    public var byte4: UInt8 { UInt8(word & 0xFF) }

    /// Number of following 32-bit words in the packet.
    public var dataWordCount: Int { 3 }

    /// Total number of data bytes in the packet following the status byte.
    public var dataByteCount: Int { 14 }
}

