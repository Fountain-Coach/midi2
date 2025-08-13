/// Variants of MIDI 2.0 Channel Voice messages.
public enum Midi2ChannelVoiceVariants: Equatable {
    case noteOff(NoteOff)
    case noteOn(Midi2NoteOn)
    case polyPressure(PolyPressure)
    case controlChange(ControlChange)
    case programChange(ProgramChange)
    case channelPressure(Midi2ChannelPressure)
    case pitchBend(PitchBend)
    case perNoteManagement(Midi2PerNoteManagement)
    case regPerNoteController(Midi2RegPerNoteController)
    case assignPerNoteController(Midi2AssignPerNoteController)
}

public extension Midi2ChannelVoiceVariants {
    /// Encodes the variant to a 64-bit UMP packet.
    func ump() -> UmpPacket64 {
        switch self {
        case let .noteOff(msg):
            let p = msg.ump()
            return UmpPacket64(word0: p.word0, word1: p.word1)
        case let .noteOn(msg):
            return msg.ump()
        case let .polyPressure(msg):
            let p = msg.ump()
            return UmpPacket64(word0: p.word0, word1: p.word1)
        case let .controlChange(msg):
            let p = msg.ump()
            return UmpPacket64(word0: p.word0, word1: p.word1)
        case let .programChange(msg):
            let p = msg.ump()
            return UmpPacket64(word0: p.word0, word1: p.word1)
        case let .channelPressure(msg):
            return msg.ump()
        case let .pitchBend(msg):
            let p = msg.ump()
            return UmpPacket64(word0: p.word0, word1: p.word1)
        case let .perNoteManagement(msg):
            return msg.ump()
        case let .regPerNoteController(msg):
            return msg.ump()
        case let .assignPerNoteController(msg):
            return msg.ump()
        }
    }

    /// Decodes a variant from a UMP packet.
    init?(ump: UmpPacket64) {
        let status = UInt8((ump.word0 >> 20) & 0xF)
        switch status {
        case 0x8:
            guard let pkt = NoteOff(ump: Ump64(word0: ump.word0, word1: ump.word1)!) else { return nil }
            self = .noteOff(pkt)
        case 0x9:
            guard let pkt = Midi2NoteOn(ump: ump) else { return nil }
            self = .noteOn(pkt)
        case 0xA:
            guard let pkt = PolyPressure(ump: Ump64(word0: ump.word0, word1: ump.word1)!) else { return nil }
            self = .polyPressure(pkt)
        case 0xB:
            guard let pkt = ControlChange(ump: Ump64(word0: ump.word0, word1: ump.word1)!) else { return nil }
            self = .controlChange(pkt)
        case 0xC:
            guard let pkt = ProgramChange(ump: Ump64(word0: ump.word0, word1: ump.word1)!) else { return nil }
            self = .programChange(pkt)
        case 0xD:
            guard let pkt = Midi2ChannelPressure(ump: ump) else { return nil }
            self = .channelPressure(pkt)
        case 0xE:
            guard let pkt = PitchBend(ump: Ump64(word0: ump.word0, word1: ump.word1)!) else { return nil }
            self = .pitchBend(pkt)
        case 0xF:
            if let msg = Midi2PerNoteManagement(ump: ump) { self = .perNoteManagement(msg); return }
            if let msg = Midi2RegPerNoteController(ump: ump) { self = .regPerNoteController(msg); return }
            if let msg = Midi2AssignPerNoteController(ump: ump) { self = .assignPerNoteController(msg); return }
            return nil
        default:
            return nil
        }
    }
}
