/// Flex: Set Time Signature (n / 2^d).
public struct FlexTimeSignature: Equatable {
    /// Address scope for the time signature.
    public enum Address: Equatable {
        case group(Uint4)
        case channel(group: Uint4, channel: Uint4)
    }

    /// Address indicating group or channel scope.
    public var address: Address

    /// Numerator of the time signature.
    public var numerator: UInt8

    /// Denominator expressed as power of two (i.e. denominator = 2^d).
    public var denominatorPow2: UInt8

    /// Creates a time signature message.
    public init(address: Address, numerator: UInt8, denominatorPow2: UInt8) {
        precondition(numerator >= 1, "numerator must be at least 1")
        self.address = address
        self.numerator = numerator
        self.denominatorPow2 = denominatorPow2
    }

    private static let statusClass: UInt8 = 0x10
    private static let status: UInt8 = 0x02

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

        let word1 = UInt32(numerator) << 24 |
                    UInt32(denominatorPow2) << 16

        let word0 = UInt32(0xD << 28) |
                    UInt32(group & 0xF) << 24 |
                    UInt32(Self.statusClass) << 16 |
                    UInt32(Self.status) << 8 |
                    UInt32(addrByte)

        return Ump128(word0: word0, word1: word1, word2: 0, word3: 0)!
    }

    /// Decodes a time signature message from a UMP packet.
    public static func decode(_ packet: Ump128) -> FlexTimeSignature? {
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

        let numerator = UInt8((packet.word1 >> 24) & 0xFF)
        let denom = UInt8((packet.word1 >> 16) & 0xFF)
        guard numerator >= 1 else { return nil }
        return FlexTimeSignature(address: address, numerator: numerator, denominatorPow2: denom)
    }
}

