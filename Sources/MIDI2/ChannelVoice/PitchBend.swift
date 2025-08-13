public struct PitchBend: Equatable {
    public let group: Uint4
    public let channel: Uint4
    public let value: UInt32

    public init(group: Uint4, channel: Uint4, value: UInt32) {
        self.group = group
        self.channel = channel
        self.value = value
    }

    public func ump() -> Ump64 {
        let byte0 = UInt32(0x4 << 4 | group.rawValue)
        let byte1 = UInt32(0xE << 4 | channel.rawValue)
        let byte2: UInt32 = 0
        let byte3: UInt32 = 0
        let word0 = (byte0 << 24) | (byte1 << 16) | (byte2 << 8) | byte3
        let byte4 = UInt32((value >> 24) & 0xFF)
        let byte5 = UInt32((value >> 16) & 0xFF)
        let byte6 = UInt32((value >> 8) & 0xFF)
        let byte7 = UInt32(value & 0xFF)
        let word1 = (byte4 << 24) | (byte5 << 16) | (byte6 << 8) | byte7
        return Ump64(word0: word0, word1: word1)!
    }

    public init?(ump: Ump64) {
        let mt = UInt8((ump.word0 >> 28) & 0xF)
        guard mt == 0x4 else { return nil }
        let byte0 = UInt8((ump.word0 >> 24) & 0xFF)
        guard let group = Uint4(byte0 & 0x0F) else { return nil }
        let byte1 = UInt8((ump.word0 >> 16) & 0xFF)
        let status = byte1 >> 4
        guard status == 0xE, let channel = Uint4(byte1 & 0x0F) else { return nil }
        let value = ump.word1
        self.init(group: group, channel: channel, value: value)
    }
}
