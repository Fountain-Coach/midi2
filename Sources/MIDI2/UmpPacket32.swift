/// Single 32-bit Universal MIDI Packet.
public struct UmpPacket32: Equatable {
    public let word: UInt32

    public init(word: UInt32) {
        self.word = word
    }

    public init(mt: UInt8, group: Uint4, status: UInt8, data1: UInt8, data2: UInt8) {
        let byte0 = UInt32(mt << 4 | group.rawValue)
        let word = (byte0 << 24) | (UInt32(status) << 16) | (UInt32(data1) << 8) | UInt32(data2)
        self.word = word
    }

    public init?(midi1Bytes bytes: [UInt8], group: Uint4) {
        guard bytes.count >= 2 else { return nil }
        let status = bytes[0]
        let data1 = bytes[1]
        let data2: UInt8 = bytes.count > 2 ? bytes[2] : 0
        self.init(mt: 0x2, group: group, status: status, data1: data1, data2: data2)
    }

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
