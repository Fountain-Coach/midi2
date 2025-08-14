/// Status 0x9 (Note On).
///
/// Represents a MIDI 2.0 Channel Voice "Note On" message. This message is
/// encoded as a 64-bit Universal MIDI Packet with the following layout:
///
/// ```
/// Word0: [MT=0x4][Group][Status=0x9][Channel][Note][Attribute Type]
/// Word1: [Velocity (16 bits)][Attribute Data (16 bits)]
/// ```
public struct Midi2NoteOn: Equatable {
    public let group: Uint4
    public let channel: Uint4
    public let note: Uint7
    public let velocity: UInt16
    public let attributeType: NoteAttributeType
    public let attributeData: UInt16

    /// Creates a new Note On message.
    public init(group: Uint4, channel: Uint4, note: Uint7, velocity: UInt16, attributeType: NoteAttributeType = .none, attributeData: UInt16 = 0) {
        self.group = group
        self.channel = channel
        self.note = note
        self.velocity = velocity
        self.attributeType = attributeType
        self.attributeData = attributeData
    }

    /// Encodes this message into a 64-bit Universal MIDI Packet.
    public func ump() -> UmpPacket64 {
        let word0 = UInt32(0x4 << 28) |
                    UInt32(group.rawValue) << 24 |
                    UInt32(0x9) << 20 |
                    UInt32(channel.rawValue) << 16 |
                    UInt32(note.rawValue) << 8 |
                    UInt32(attributeType.rawValue)
        let word1 = UInt32(velocity) << 16 | UInt32(attributeData)
        return UmpPacket64(word0: word0, word1: word1)
    }

    /// Creates a Note On message from a Universal MIDI Packet.
    /// Returns `nil` if the packet does not encode a Note On.
    public init?(ump: UmpPacket64) {
        guard (ump.word0 >> 28) & 0xF == 0x4 else { return nil }
        guard let group = Uint4(UInt8((ump.word0 >> 24) & 0xF)) else { return nil }
        guard ((ump.word0 >> 20) & 0xF) == 0x9 else { return nil }
        guard let channel = Uint4(UInt8((ump.word0 >> 16) & 0xF)) else { return nil }
        guard let note = Uint7(UInt8((ump.word0 >> 8) & 0xFF)) else { return nil }
        guard let attrType = NoteAttributeType(UInt8(ump.word0 & 0xFF)) else { return nil }
        let velocity = UInt16((ump.word1 >> 16) & 0xFFFF)
        let attrData = UInt16(ump.word1 & 0xFFFF)
        self.init(group: group, channel: channel, note: note, velocity: velocity, attributeType: attrType, attributeData: attrData)
    }

    /// Parses a Universal MIDI Packet into a Note On message.
    /// Throws `MIDIError.malformedPacket` if the packet is not a Note On message.
    public init(parsingUMP ump: UmpPacket64) throws {
        guard (ump.word0 >> 28) & 0xF == 0x4 else {
            throw MIDIError.malformedPacket("expected mt 0x4 but got \(((ump.word0 >> 28) & 0xF))")
        }
        guard ((ump.word0 >> 20) & 0xF) == 0x9 else {
            throw MIDIError.malformedPacket("expected status 0x9 but got \(((ump.word0 >> 20) & 0xF))")
        }
        let group = try Uint4(validating: UInt8((ump.word0 >> 24) & 0xF))
        let channel = try Uint4(validating: UInt8((ump.word0 >> 16) & 0xF))
        let note = try Uint7(validating: UInt8((ump.word0 >> 8) & 0xFF))
        let attrType = try NoteAttributeType(validating: UInt8(ump.word0 & 0xFF))
        let velocity = UInt16((ump.word1 >> 16) & 0xFFFF)
        let attrData = UInt16(ump.word1 & 0xFFFF)
        self.init(group: group, channel: channel, note: note, velocity: velocity, attributeType: attrType, attributeData: attrData)
    }
}
