/// 64-bit Universal MIDI Packet consisting of two 32-bit words.
public struct UmpPacket64: Equatable, UniversalPacket {
    /// The first 32-bit word of the packet.
    public let word0: UInt32
    /// The second 32-bit word of the packet.
    public let word1: UInt32

    /// Number of 32-bit words in this packet.
    public static let wordCount: Int = 2

    /// Creates a packet from two raw 32-bit words.
    public init(word0: UInt32, word1: UInt32) {
        self.word0 = word0
        self.word1 = word1
    }

    /// Creates a packet from an array of two 32-bit words.
    public init?(words: [UInt32]) {
        guard words.count == 2 else { return nil }
        self.init(word0: words[0], word1: words[1])
    }

    /// Returns the raw 32-bit words making up this packet.
    public var words: [UInt32] { [word0, word1] }
}
