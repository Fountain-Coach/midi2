/// Per-Note Management (D/S flags).
///
/// Encodes the detach (D) and reset (S) flags for a specific note number on a
/// MIDI channel.  The message is transported as a 64-bit UMP Channel Voice
/// packet with status nibble `0xF`.
public struct Midi2PerNoteManagement: Equatable {
    public let group: Uint4
    public let channel: Uint4
    public let noteNumber: Uint7
    public let detach: Bool
    public let reset: Bool

    /// Creates a new per-note management message.
    public init(group: Uint4, channel: Uint4, noteNumber: Uint7, detach: Bool, reset: Bool) {
        self.group = group
        self.channel = channel
        self.noteNumber = noteNumber
        self.detach = detach
        self.reset = reset
    }

    /// Encodes the message into a 64-bit Universal MIDI Packet.
    public func ump() -> UmpPacket64 {
        let flags = (detach ? UInt32(0x02) : 0) | (reset ? UInt32(0x01) : 0)
        let word0 = UInt32(0x4 << 28) |
                    UInt32(group.rawValue) << 24 |
                    UInt32(0xF) << 20 |
                    UInt32(channel.rawValue) << 16 |
                    UInt32(noteNumber.rawValue) << 8 |
                    flags
        return UmpPacket64(word0: word0, word1: 0)
    }

    /// Decodes a per-note management message from a UMP packet.
    /// Returns `nil` if the packet does not encode such a message.
    public init?(ump: UmpPacket64) {
        let mt = (ump.word0 >> 28) & 0xF
        guard mt == 0x4 else { return nil }
        let status = (ump.word0 >> 20) & 0xF
        guard status == 0xF else { return nil }
        guard ump.word1 == 0 else { return nil }
        guard let group = Uint4(UInt8((ump.word0 >> 24) & 0xF)) else { return nil }
        guard let channel = Uint4(UInt8((ump.word0 >> 16) & 0xF)) else { return nil }
        guard let note = Uint7(UInt8((ump.word0 >> 8) & 0xFF)) else { return nil }
        let flags = UInt8(ump.word0 & 0xFF)
        let detach = (flags & 0x02) != 0
        let reset = (flags & 0x01) != 0
        self.init(group: group, channel: channel, noteNumber: note, detach: detach, reset: reset)
    }
}
