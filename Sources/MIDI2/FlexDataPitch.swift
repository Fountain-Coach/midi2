/// Flex: Set Pitch (fractional semitone value).
public struct FlexDataPitch {
    public var semitones: Double

    public init(semitones: Double) {
        self.semitones = semitones
    }

    private static let statusClass: UInt8 = 0x10
    private static let status: UInt8 = 0x02
    private static let scale: Double = 65536.0 // 16.16 fixed point

    private var fixedPointValue: UInt32 {
        UInt32((semitones * Self.scale).rounded())
    }

    public func encode(group: UInt8 = 0) -> Ump128 {
        let word0 = UInt32(0xD << 28) |
                    UInt32(group & 0xF) << 24 |
                    UInt32(Self.statusClass) << 16 |
                    UInt32(Self.status) << 8
        let word1 = fixedPointValue
        return Ump128(word0: word0, word1: word1, word2: 0, word3: 0)!
    }

    public static func decode(_ packet: Ump128) -> FlexDataPitch? {
        guard packet.messageType == 0xD,
              UInt8((packet.word0 >> 16) & 0xFF) == statusClass,
              UInt8((packet.word0 >> 8) & 0xFF) == status else { return nil }
        let semitones = Double(packet.word1) / scale
        return FlexDataPitch(semitones: semitones)
    }
}
