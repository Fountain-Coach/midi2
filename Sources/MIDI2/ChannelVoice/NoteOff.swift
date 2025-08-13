/// Status 0x8 (Note Off) message.
public struct NoteOff: Equatable {
    public let group: Uint4
    public let channel: Uint4
    public let noteNumber: Uint7
    public let velocity: UInt16
    public let attributeType: NoteAttributeType
    public let attributeData: UInt16

    public init(group: Uint4, channel: Uint4, noteNumber: Uint7, velocity: UInt16, attributeType: NoteAttributeType = .none, attributeData: UInt16 = 0) {
        self.group = group
        self.channel = channel
        self.noteNumber = noteNumber
        self.velocity = velocity
        self.attributeType = attributeType
        self.attributeData = attributeData
    }

    public func ump() -> Ump64 {
        let byte0 = UInt32(0x4 << 4 | group.rawValue)
        let byte1 = UInt32(0x8 << 4 | channel.rawValue)
        let byte2 = UInt32(noteNumber.rawValue)
        let byte3 = UInt32(attributeType.rawValue)
        let word0 = (byte0 << 24) | (byte1 << 16) | (byte2 << 8) | byte3
        let byte4 = UInt32(velocity >> 8)
        let byte5 = UInt32(velocity & 0xFF)
        let byte6 = UInt32(attributeData >> 8)
        let byte7 = UInt32(attributeData & 0xFF)
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
        guard status == 0x8, let channel = Uint4(byte1 & 0x0F) else { return nil }
        let byte2 = UInt8((ump.word0 >> 8) & 0xFF)
        guard let noteNumber = Uint7(byte2) else { return nil }
        let byte3 = UInt8(ump.word0 & 0xFF)
        let attributeType = NoteAttributeType(byte3)
        let byte4 = UInt8((ump.word1 >> 24) & 0xFF)
        let byte5 = UInt8((ump.word1 >> 16) & 0xFF)
        let byte6 = UInt8((ump.word1 >> 8) & 0xFF)
        let byte7 = UInt8(ump.word1 & 0xFF)
        let velocity = UInt16(byte4) << 8 | UInt16(byte5)
        let attributeData = UInt16(byte6) << 8 | UInt16(byte7)
        self.init(group: group, channel: channel, noteNumber: noteNumber, velocity: velocity, attributeType: attributeType, attributeData: attributeData)
    }
}
