/// Flex: Set Metronome parameters.
public struct FlexMetronome: Equatable {
    /// Address scope for the metronome message.
    public enum Address: Equatable {
        case group(Uint4)
        case channel(group: Uint4, channel: Uint4)
    }

    /// Address indicating group or channel scope.
    public var address: Address

    /// Number of metronome clicks per beat.
    public var clicksPerBeat: UInt16

    /// Accent pattern string.
    public var accentPattern: String

    /// Creates a metronome message.
    public init(address: Address, clicksPerBeat: UInt16, accentPattern: String) throws {
        guard clicksPerBeat >= 1 else {
            throw MIDIError.valueOutOfRange(name: "clicksPerBeat", value: UInt64(clicksPerBeat), range: 1...UInt64.max)
        }
        let patternLength = accentPattern.utf8.count
        guard patternLength <= 10 else {
            throw MIDIError.valueOutOfRange(name: "accentPattern", value: UInt64(patternLength), range: 0...10)
        }
        self.address = address
        self.clicksPerBeat = clicksPerBeat
        self.accentPattern = accentPattern
    }

    private static let statusClass: UInt8 = 0x10
    private static let status: UInt8 = 0x03

    /// Encodes the message into a 128-bit UMP packet.
    public func encode() -> Ump128 {
        let (group, addrByte): (UInt8, UInt8)
        switch address {
        case .group(let g):
            group = g.rawValue
            addrByte = 0x00
        case .channel(let g, let c):
            group = g.rawValue
            addrByte = 0x10 | c.rawValue
        }

        var patternBytes = Array(accentPattern.utf8.prefix(10))
        patternBytes += Array(repeating: 0, count: 10 - patternBytes.count)
        let bytes: [UInt8] = [
            UInt8((clicksPerBeat >> 8) & 0xFF),
            UInt8(clicksPerBeat & 0xFF)
        ] + patternBytes

        let word1 = UInt32(bytes[0]) << 24 |
                    UInt32(bytes[1]) << 16 |
                    UInt32(bytes[2]) << 8  |
                    UInt32(bytes[3])
        let word2 = UInt32(bytes[4]) << 24 |
                    UInt32(bytes[5]) << 16 |
                    UInt32(bytes[6]) << 8  |
                    UInt32(bytes[7])
        let word3 = UInt32(bytes[8]) << 24 |
                    UInt32(bytes[9]) << 16 |
                    UInt32(bytes[10]) << 8 |
                    UInt32(bytes[11])

        let word0 = UInt32(0xD << 28) |
                    UInt32(group & 0xF) << 24 |
                    UInt32(Self.statusClass) << 16 |
                    UInt32(Self.status) << 8 |
                    UInt32(addrByte)

        return Ump128(word0: word0, word1: word1, word2: word2, word3: word3)!
    }

    /// Decodes a metronome message from a UMP packet.
    public static func decode(_ packet: Ump128) -> FlexMetronome? {
        guard packet.messageType == 0xD else { return nil }
        let sc = UInt8((packet.word0 >> 16) & 0xFF)
        let st = UInt8((packet.word0 >> 8) & 0xFF)
        guard sc == statusClass, st == status else { return nil }

        guard let group = Uint4(UInt8((packet.word0 >> 24) & 0xF)) else { return nil }
        let addrByte = UInt8(packet.word0 & 0xFF)
        let address: Address
        if addrByte & 0x10 != 0 {
            guard let ch = Uint4(addrByte & 0xF) else { return nil }
            address = .channel(group: group, channel: ch)
        } else {
            address = .group(group)
        }

        let bytes: [UInt8] = [
            UInt8((packet.word1 >> 24) & 0xFF),
            UInt8((packet.word1 >> 16) & 0xFF),
            UInt8((packet.word1 >> 8) & 0xFF),
            UInt8(packet.word1 & 0xFF),
            UInt8((packet.word2 >> 24) & 0xFF),
            UInt8((packet.word2 >> 16) & 0xFF),
            UInt8((packet.word2 >> 8) & 0xFF),
            UInt8(packet.word2 & 0xFF),
            UInt8((packet.word3 >> 24) & 0xFF),
            UInt8((packet.word3 >> 16) & 0xFF),
            UInt8((packet.word3 >> 8) & 0xFF),
            UInt8(packet.word3 & 0xFF)
        ]

        let clicks = UInt16(bytes[0]) << 8 | UInt16(bytes[1])
        guard clicks >= 1 else { return nil }
        let patternBytes = bytes[2...].prefix { $0 != 0 }
        let pattern = String(bytes: patternBytes, encoding: .utf8) ?? ""
        return try? FlexMetronome(address: address, clicksPerBeat: clicks, accentPattern: pattern)
    }
}
