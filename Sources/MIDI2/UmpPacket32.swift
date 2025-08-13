/// Single 32-bit Universal MIDI Packet.
public struct UmpPacket32: Equatable {
    public let word: UInt32

    /// Creates a packet from a raw 32-bit word.
    public init(word: UInt32) {
        self.word = word
    }

    /// Creates a packet from a header.
    public init(header: UmpHeader32) {
        self.word = header.word
    }

    /// Convenience initializer using individual fields.
    public init(mt: UInt8, group: Uint4, status: UInt8, data1: UInt8, data2: UInt8) {
        let header = UmpHeader32(
            messageType: mt,
            group: group,
            status: status,
            byte1: data1,
            byte2: data2
        )!
        self.init(header: header)
    }

    public init?(midi1Bytes bytes: [UInt8], group: Uint4) {
        guard bytes.count >= 2 else { return nil }
        let status = bytes[0]
        let data1 = bytes[1]
        let data2: UInt8 = bytes.count > 2 ? bytes[2] : 0
        self.init(mt: 0x2, group: group, status: status, data1: data1, data2: data2)
    }

    /// Header view of the packet.
    public var header: UmpHeader32 { UmpHeader32(word: word)! }

    public func midi1Bytes() -> [UInt8]? {
        let mt = UInt8((word >> 28) & 0xF)
        guard mt == 0x2 else { return nil }
        let status = UInt8((word >> 16) & 0xFF)
        let data1 = UInt8((word >> 8) & 0xFF)
        let data2 = UInt8(word & 0xFF)
        let statusNibble = status >> 4
        if statusNibble == 0xC || statusNibble == 0xD {
            return [status, data1]
        } else {
            return [status, data1, data2]
        }
    }
}
