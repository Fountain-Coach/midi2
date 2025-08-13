/// A 64-bit Universal MIDI Packet (two 32-bit words).
public struct Ump64: UniversalPacket {
    public static let wordCount = 2

    public var word0: UInt32
    public var word1: UInt32

    /// Creates a packet from two 32-bit words.
    public init?(word0: UInt32, word1: UInt32) {
        self.word0 = word0
        self.word1 = word1
    }

    /// Creates a packet from an array of words. Fails if count is not 2.
    public init?(words: [UInt32]) {
        guard words.count == Self.wordCount else { return nil }
        self.word0 = words[0]
        self.word1 = words[1]
    }

    /// The raw words composing the packet.
    public var words: [UInt32] { [word0, word1] }
}

public extension Ump64 {
    /// Status from the first word (bits 23-16).
    var status: UInt8 { UInt8((word0 >> 16) & 0xFF) }
    /// Remaining bytes in order (byte3..byte8).
    var payloadBytes: [UInt8] {
        [UInt8((word0 >> 8) & 0xFF),
         UInt8(word0 & 0xFF),
         UInt8((word1 >> 24) & 0xFF),
         UInt8((word1 >> 16) & 0xFF),
         UInt8((word1 >> 8) & 0xFF),
         UInt8(word1 & 0xFF)]
    }
}
