public protocol UniversalPacket {
    /// Number of 32-bit words in this packet.
    static var wordCount: Int { get }
    /// Initialize from raw 32-bit words. Fails if word count is incorrect.
    init?(words: [UInt32])
    /// Raw 32-bit words representing the packet.
    var words: [UInt32] { get }
}

public extension UniversalPacket {
    /// Number of bytes in this packet.
    static var byteCount: Int { wordCount * 4 }

    /// Initialize from raw bytes. Fails if byte count is incorrect.
    init?(rawBytes: [UInt8]) {
        guard rawBytes.count == Self.byteCount else { return nil }
        var words: [UInt32] = []
        words.reserveCapacity(Self.wordCount)
        for i in stride(from: 0, to: rawBytes.count, by: 4) {
            let word = UInt32(rawBytes[i]) << 24 |
                       UInt32(rawBytes[i+1]) << 16 |
                       UInt32(rawBytes[i+2]) << 8 |
                       UInt32(rawBytes[i+3])
            words.append(word)
        }
        self.init(words: words)
    }

    /// Raw bytes of the packet in big-endian order.
    var rawBytes: [UInt8] {
        words.flatMap { word in
            [UInt8((word >> 24) & 0xFF),
             UInt8((word >> 16) & 0xFF),
             UInt8((word >> 8) & 0xFF),
             UInt8(word & 0xFF)]
        }
    }

    /// Message Type from the first 32-bit word (bits 31-28).
    var messageType: UInt8 {
        UInt8((words[0] >> 28) & 0xF)
    }

    /// Group from the first 32-bit word (bits 27-24).
    var group: UInt8 {
        UInt8((words[0] >> 24) & 0xF)
    }
}
