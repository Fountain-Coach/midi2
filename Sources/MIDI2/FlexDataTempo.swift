/// Flex: Set Tempo (heuristic mapping to BPM).
public struct FlexDataTempo: Equatable {
    public var beatsPerMinute: Double

    public init(beatsPerMinute: Double) throws {
        guard beatsPerMinute >= 1 else {
            throw MIDIError.valueOutOfRange(name: "beatsPerMinute", value: UInt64(beatsPerMinute), range: 1...UInt64.max)
        }
        guard beatsPerMinute <= Self.maxBeatsPerMinute else {
            throw MIDIError.valueOutOfRange(name: "beatsPerMinute", value: UInt64(beatsPerMinute), range: 1...UInt64(Self.maxBeatsPerMinute))
        }
        self.beatsPerMinute = beatsPerMinute
    }

    private static let statusClass: UInt8 = 0x10
    private static let status: UInt8 = 0x01
    private static let scale: Double = 65536.0 // 16.16 fixed point
    private static let maxBeatsPerMinute: Double = Double(UInt32.max) / scale

    private var fixedPointValue: UInt32 {
        UInt32((beatsPerMinute * Self.scale).rounded())
    }

    public func encode(group: UInt8 = 0) -> Ump128 {
        let word0 = UInt32(0xD << 28) |
                    UInt32(group & 0xF) << 24 |
                    UInt32(Self.statusClass) << 16 |
                    UInt32(Self.status) << 8
        let word1 = fixedPointValue
        return Ump128(word0: word0, word1: word1, word2: 0, word3: 0)!
    }

    public static func decode(_ packet: Ump128) -> FlexDataTempo? {
        guard packet.messageType == 0xD,
              UInt8((packet.word0 >> 16) & 0xFF) == statusClass,
              UInt8((packet.word0 >> 8) & 0xFF) == status else { return nil }
        let bpm = Double(packet.word1) / scale
        guard bpm >= 1, bpm <= maxBeatsPerMinute else { return nil }
        return try? FlexDataTempo(beatsPerMinute: bpm)
    }
}
