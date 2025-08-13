/// 128-bit Universal MIDI Packet consisting of four 32-bit words.
public struct UmpPacket128: Equatable, UniversalPacket {
    /// The four 32-bit words of the packet.
    public let word0: UInt32
    public let word1: UInt32
    public let word2: UInt32
    public let word3: UInt32

    /// Number of 32-bit words.
    public static let wordCount: Int = 4

    /// Creates a packet from four words.
    public init(word0: UInt32, word1: UInt32, word2: UInt32, word3: UInt32) {
        self.word0 = word0
        self.word1 = word1
        self.word2 = word2
        self.word3 = word3
    }

    /// Creates a packet from an array of words.
    public init?(words: [UInt32]) {
        guard words.count == 4 else { return nil }
        self.init(word0: words[0], word1: words[1], word2: words[2], word3: words[3])
    }

    /// Returns the words making up the packet.
    public var words: [UInt32] { [word0, word1, word2, word3] }

    /// Header view of the packet.
    public var header: UmpHeader128 { UmpHeader128(word: word0)! }
}

