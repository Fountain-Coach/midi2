/// Flex Ruby (furigana).
public struct FlexRuby: Equatable {
    /// Address scope for the ruby text.
    public enum Address: Equatable {
        case group(Uint4)
        case channel(group: Uint4, channel: Uint4)
    }

    /// Address indicating group or channel scope.
    public var address: Address

    /// Ruby text payload.
    public var ruby: String

    /// Creates a ruby message.
    public init(address: Address, ruby: String) throws {
        let length = ruby.utf8.count
        guard length <= 12 else {
            throw MIDIError.valueOutOfRange(name: "ruby", value: UInt64(length), range: 0...12)
        }
        self.address = address
        self.ruby = ruby
    }

    private static let statusClass: UInt8 = 0x11
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

        var bytes = Array(ruby.utf8.prefix(12))
        bytes += Array(repeating: 0, count: 12 - bytes.count)
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

    /// Decodes a ruby message from a UMP packet.
    public static func decode(_ packet: Ump128) -> FlexRuby? {
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

        let strBytes = bytes.prefix { $0 != 0 }
        let ruby = String(bytes: strBytes, encoding: .utf8) ?? ""
        return try? FlexRuby(address: address, ruby: ruby)
    }
}
