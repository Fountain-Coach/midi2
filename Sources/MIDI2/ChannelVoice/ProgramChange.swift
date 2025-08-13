/// Status 0xC (Program Change).
public struct ProgramChange: Equatable {
    public let group: Uint4
    public let channel: Uint4
    public let program: Uint7
    public let bankMsb: Uint7?
    public let bankLsb: Uint7?
    public let bankValid: Bool

    public init(group: Uint4, channel: Uint4, program: Uint7, bankMsb: Uint7? = nil, bankLsb: Uint7? = nil) {
        self.group = group
        self.channel = channel
        self.program = program
        self.bankMsb = bankMsb
        self.bankLsb = bankLsb
        self.bankValid = bankMsb != nil || bankLsb != nil
    }

    public func ump() -> Ump64 {
        let byte0 = UInt32(0x4 << 4 | group.rawValue)
        let byte1 = UInt32(0xC << 4 | channel.rawValue)
        let byte2 = UInt32(program.rawValue)
        let byte3 = UInt32(bankValid ? 0x80 : 0x00)
        let word0 = (byte0 << 24) | (byte1 << 16) | (byte2 << 8) | byte3
        let byte4 = UInt32(bankMsb?.rawValue ?? 0)
        let byte5 = UInt32(bankLsb?.rawValue ?? 0)
        let byte6: UInt32 = 0
        let byte7: UInt32 = 0
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
        guard status == 0xC, let channel = Uint4(byte1 & 0x0F) else { return nil }
        let byte2 = UInt8((ump.word0 >> 8) & 0xFF)
        guard let program = Uint7(byte2) else { return nil }
        let byte3 = UInt8(ump.word0 & 0xFF)
        let bankValid = (byte3 & 0x80) != 0
        let byte4 = UInt8((ump.word1 >> 24) & 0xFF)
        let byte5 = UInt8((ump.word1 >> 16) & 0xFF)
        let bankMsb = bankValid ? Uint7(byte4) : nil
        let bankLsb = bankValid ? Uint7(byte5) : nil
        self.init(group: group, channel: channel, program: program, bankMsb: bankMsb, bankLsb: bankLsb)
    }
}
