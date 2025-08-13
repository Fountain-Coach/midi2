/// A 128-bit Universal MIDI Packet (four 32-bit words).
public struct Ump128: UniversalPacket {
    public static let wordCount = 4

    public var word0: UInt32
    public var word1: UInt32
    public var word2: UInt32
    public var word3: UInt32

    /// Creates a packet from four 32-bit words.
    public init?(word0: UInt32, word1: UInt32, word2: UInt32, word3: UInt32) {
        self.word0 = word0
        self.word1 = word1
        self.word2 = word2
        self.word3 = word3
    }

    /// Creates a packet from an array of words. Fails if count is not 4.
    public init?(words: [UInt32]) {
        guard words.count == Self.wordCount else { return nil }
        self.word0 = words[0]
        self.word1 = words[1]
        self.word2 = words[2]
        self.word3 = words[3]
    }

    /// The raw words composing the packet.
    public var words: [UInt32] { [word0, word1, word2, word3] }
}

public extension Ump128 {
    /// Status from the first word (bits 23-16).
    var status: UInt8 { UInt8((word0 >> 16) & 0xFF) }
    /// Remaining bytes in order (byte3..byte16).
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
         UInt8(word2 & 0xFF),
         UInt8((word3 >> 24) & 0xFF),
         UInt8((word3 >> 16) & 0xFF),
         UInt8((word3 >> 8) & 0xFF),
         UInt8(word3 & 0xFF)]
    }
}
