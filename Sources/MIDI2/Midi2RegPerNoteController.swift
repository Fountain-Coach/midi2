/// Registered Per-Note Controller message.
///
/// Carries a 32-bit value for a registered per-note controller index.  The
/// message uses status nibble `0xF` with the controller index encoded in the
/// fourth byte and the note number in the third byte.
public struct Midi2RegPerNoteController: Equatable {
    public let group: Uint4
    public let channel: Uint4
    public let noteNumber: Uint7
    public let controller: UInt8
    public let value: UInt32

    public init(group: Uint4, channel: Uint4, noteNumber: Uint7, controller: UInt8, value: UInt32) {
        self.group = group
        self.channel = channel
        self.noteNumber = noteNumber
        self.controller = controller
        self.value = value
    }

    /// Encodes the message to a UMP packet.
    public func ump() -> UmpPacket64 {
        let word0 = UInt32(0x4 << 28) |
                    UInt32(group.rawValue) << 24 |
                    UInt32(0xF) << 20 |
                    UInt32(channel.rawValue) << 16 |
                    UInt32(noteNumber.rawValue) << 8 |
                    UInt32(controller)
        return UmpPacket64(word0: word0, word1: value)
    }

    /// Decodes a message from a UMP packet.
    public init?(ump: UmpPacket64) {
        let mt = (ump.word0 >> 28) & 0xF
        guard mt == 0x4 else { return nil }
        let status = (ump.word0 >> 20) & 0xF
        guard status == 0xF else { return nil }
        guard let group = Uint4(UInt8((ump.word0 >> 24) & 0xF)) else { return nil }
        guard let channel = Uint4(UInt8((ump.word0 >> 16) & 0xF)) else { return nil }
        guard let note = Uint7(UInt8((ump.word0 >> 8) & 0xFF)) else { return nil }
        let controller = UInt8(ump.word0 & 0xFF)
        guard controller < 0x80 else { return nil }
        let value = ump.word1
        self.init(group: group, channel: channel, noteNumber: note, controller: controller, value: value)
    }
}
