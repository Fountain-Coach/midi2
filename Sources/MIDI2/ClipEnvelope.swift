/// Envelope data for MIDI Clip messages.
public struct ClipEnvelope: Equatable {
    /// Indicates the start of a clip.
    public var startOfClip: Bool
    /// Indicates the end of a clip.
    public var endOfClip: Bool
    /// Number of pickup bars preceding the clip (16.16 fixed point).
    public var pickupBars: Double

    public init(startOfClip: Bool = false, endOfClip: Bool = false, pickupBars: Double = 0) {
        self.startOfClip = startOfClip
        self.endOfClip = endOfClip
        self.pickupBars = pickupBars
    }

    private static let scale: Double = 65536.0

    /// Encodes the envelope into a ``Ump128`` packet.
    public func encode(group: UInt8 = 0) -> Ump128 {
        let flags: UInt8 = (startOfClip ? 0x1 : 0) | (endOfClip ? 0x2 : 0)
        let word0 = UInt32(0xD << 28) |
                    UInt32(group & 0xF) << 24 |
                    UInt32(flags)
        let word1 = UInt32((pickupBars * Self.scale).rounded())
        return Ump128(word0: word0, word1: word1, word2: 0, word3: 0)!
    }

    /// Decodes an envelope from a ``Ump128`` packet.
    public static func decode(_ packet: Ump128) -> ClipEnvelope? {
        guard packet.messageType == 0xD else { return nil }
        let flags = UInt8(packet.word0 & 0xFF)
        let start = (flags & 0x1) != 0
        let end = (flags & 0x2) != 0
        let bars = Double(packet.word1) / scale
        return ClipEnvelope(startOfClip: start, endOfClip: end, pickupBars: bars)
    }
}

