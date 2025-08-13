/// A 96-bit Universal MIDI Packet (three 32-bit words).
public struct Ump96: UniversalPacket {
    public static let wordCount = 3

    public var word0: UInt32
    public var word1: UInt32
    public var word2: UInt32

    /// Creates a packet from three 32-bit words.
    public init?(word0: UInt32, word1: UInt32, word2: UInt32) {
        self.word0 = word0
        self.word1 = word1
        self.word2 = word2
    }

    /// Creates a packet from an array of words. Fails if count is not 3.
    public init?(words: [UInt32]) {
        guard words.count == Self.wordCount else { return nil }
        self.word0 = words[0]
        self.word1 = words[1]
        self.word2 = words[2]
    }

    /// The raw words composing the packet.
    public var words: [UInt32] { [word0, word1, word2] }
}

public extension Ump96 {
    /// Status from the first word (bits 23-16).
    var status: UInt8 { UInt8((word0 >> 16) & 0xFF) }
    /// Remaining bytes in order (byte3..byte12).
    var payloadBytes: [UInt8] {
        [UInt8((word0 >> 8) & 0xFF),
         UInt8(word0 & 0xFF),
         UInt8((word1 >> 24) & 0xFF),
         UInt8((word1 >> 16) & 0xFF),
         UInt8((word1 >> 8) & 0xFF),
         UInt8(word1 & 0xFF),
         UInt8((word2 >> 24) & 0xFF),
         UInt8((word2 >> 16) & 0xFF),
         UInt8((word2 >> 8) & 0xFF),
         UInt8(word2 & 0xFF)]
    }
}
