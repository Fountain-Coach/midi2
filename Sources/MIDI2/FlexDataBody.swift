/// Body payload for Flex Data messages.
public enum FlexDataBody: Equatable {
    case tempo(FlexDataTempo)
    case chordName(FlexChordName)
    case text(FlexText)
    case lyric(FlexLyric)

    /// Encodes the body into a single ``Ump128`` packet.
    public func encode() -> Ump128 {
        switch self {
        case .tempo(let t): return t.encode()
        case .chordName(let c): return c.encode()
        case .text(let t): return t.encode()
        case .lyric(let l): return l.encode()
        }
    }

    /// Decodes a body from a ``Ump128`` packet.
    public init?(packet: Ump128) {
        let sc = UInt8((packet.word0 >> 16) & 0xFF)
        let st = UInt8((packet.word0 >> 8) & 0xFF)
        switch (sc, st) {
        case (0x10, 0x01):
            guard let t = FlexDataTempo.decode(packet) else { return nil }
            self = .tempo(t)
        case (0x10, 0x05):
            guard let c = FlexChordName.decode(packet) else { return nil }
            self = .chordName(c)
        case (0x11, 0x01):
            guard let t = FlexText.decode(packet) else { return nil }
            self = .text(t)
        case (0x11, 0x02):
            guard let l = FlexLyric.decode(packet) else { return nil }
            self = .lyric(l)
        default:
            return nil
        }
    }
}

