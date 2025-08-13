/// MIDI 1.0 Channel Voice messages translated to 32-bit UMP packets.
public enum Midi1ChannelVoiceMessage: Equatable {
    case noteOff(group: Uint4, channel: Uint4, note: Uint7, velocity: Uint7)
    case noteOn(group: Uint4, channel: Uint4, note: Uint7, velocity: Uint7)
    case polyPressure(group: Uint4, channel: Uint4, note: Uint7, pressure: Uint7)
    case controlChange(group: Uint4, channel: Uint4, control: Uint7, value: Uint7)
    case programChange(group: Uint4, channel: Uint4, program: Uint7)
    case channelPressure(group: Uint4, channel: Uint4, pressure: Uint7)
    case pitchBend(group: Uint4, channel: Uint4, value: Uint14)
}

public extension Midi1ChannelVoiceMessage {
    func ump() -> UmpPacket32 {
        switch self {
        case let .noteOff(group, channel, note, velocity):
            return pack(group: group, status: 0x8, channel: channel, data1: note.rawValue, data2: velocity.rawValue)
        case let .noteOn(group, channel, note, velocity):
            return pack(group: group, status: 0x9, channel: channel, data1: note.rawValue, data2: velocity.rawValue)
        case let .polyPressure(group, channel, note, pressure):
            return pack(group: group, status: 0xA, channel: channel, data1: note.rawValue, data2: pressure.rawValue)
        case let .controlChange(group, channel, control, value):
            return pack(group: group, status: 0xB, channel: channel, data1: control.rawValue, data2: value.rawValue)
        case let .programChange(group, channel, program):
            return pack(group: group, status: 0xC, channel: channel, data1: program.rawValue, data2: 0)
        case let .channelPressure(group, channel, pressure):
            return pack(group: group, status: 0xD, channel: channel, data1: pressure.rawValue, data2: 0)
        case let .pitchBend(group, channel, value):
            let lsb = UInt8(value.rawValue & 0x7F)
            let msb = UInt8((value.rawValue >> 7) & 0x7F)
            return pack(group: group, status: 0xE, channel: channel, data1: lsb, data2: msb)
        }
    }

    private func pack(group: Uint4, status: UInt8, channel: Uint4, data1: UInt8, data2: UInt8) -> UmpPacket32 {
        let statusByte = status << 4 | channel.rawValue
        return UmpPacket32(mt: 0x2, group: group, status: statusByte, data1: data1, data2: data2)
    }

    init?(ump: UmpPacket32) {
        let mt = UInt8((ump.word >> 28) & 0xF)
        guard mt == 0x2 else { return nil }
        guard let group = Uint4(UInt8((ump.word >> 24) & 0xF)) else { return nil }
        let statusByte = UInt8((ump.word >> 16) & 0xFF)
        let statusNibble = statusByte >> 4
        guard let status = Midi1StatusNibble(statusNibble) else { return nil }
        guard let channel = Uint4(statusByte & 0x0F) else { return nil }
        let data1 = UInt8((ump.word >> 8) & 0xFF)
        let data2 = UInt8(ump.word & 0xFF)

        switch status {
        case .noteOff:
            guard let note = Uint7(data1), let velocity = Uint7(data2) else { return nil }
            self = .noteOff(group: group, channel: channel, note: note, velocity: velocity)
        case .noteOn:
            guard let note = Uint7(data1), let velocity = Uint7(data2) else { return nil }
            self = .noteOn(group: group, channel: channel, note: note, velocity: velocity)
        case .polyPressure:
            guard let note = Uint7(data1), let pressure = Uint7(data2) else { return nil }
            self = .polyPressure(group: group, channel: channel, note: note, pressure: pressure)
        case .controlChange:
            guard let control = Uint7(data1), let value = Uint7(data2) else { return nil }
            self = .controlChange(group: group, channel: channel, control: control, value: value)
        case .programChange:
            guard let program = Uint7(data1) else { return nil }
            self = .programChange(group: group, channel: channel, program: program)
        case .channelPressure:
            guard let pressure = Uint7(data1) else { return nil }
            self = .channelPressure(group: group, channel: channel, pressure: pressure)
        case .pitchBend:
            let value14 = UInt16(data2) << 7 | UInt16(data1)
            guard let bend = Uint14(value14) else { return nil }
            self = .pitchBend(group: group, channel: channel, value: bend)
        }
    }

    func midi1Bytes() -> [UInt8] {
        switch self {
        case let .noteOff(_, channel, note, velocity):
            return [0x80 | channel.rawValue, note.rawValue, velocity.rawValue]
        case let .noteOn(_, channel, note, velocity):
            return [0x90 | channel.rawValue, note.rawValue, velocity.rawValue]
        case let .polyPressure(_, channel, note, pressure):
            return [0xA0 | channel.rawValue, note.rawValue, pressure.rawValue]
        case let .controlChange(_, channel, control, value):
            return [0xB0 | channel.rawValue, control.rawValue, value.rawValue]
        case let .programChange(_, channel, program):
            return [0xC0 | channel.rawValue, program.rawValue]
        case let .channelPressure(_, channel, pressure):
            return [0xD0 | channel.rawValue, pressure.rawValue]
        case let .pitchBend(_, channel, value):
            let lsb = UInt8(value.rawValue & 0x7F)
            let msb = UInt8((value.rawValue >> 7) & 0x7F)
            return [0xE0 | channel.rawValue, lsb, msb]
        }
    }

    init?(midi1Bytes bytes: [UInt8], group: Uint4) {
        guard bytes.count >= 2 else { return nil }
        let statusByte = bytes[0]
        let statusNibble = statusByte >> 4
        guard let status = Midi1StatusNibble(statusNibble) else { return nil }
        guard let channel = Uint4(statusByte & 0x0F) else { return nil }
        let data1 = bytes[1]
        let data2: UInt8 = bytes.count > 2 ? bytes[2] : 0

        switch status {
        case .noteOff:
            guard let note = Uint7(data1), let velocity = Uint7(data2) else { return nil }
            self = .noteOff(group: group, channel: channel, note: note, velocity: velocity)
        case .noteOn:
            guard let note = Uint7(data1), let velocity = Uint7(data2) else { return nil }
            self = .noteOn(group: group, channel: channel, note: note, velocity: velocity)
        case .polyPressure:
            guard let note = Uint7(data1), let pressure = Uint7(data2) else { return nil }
            self = .polyPressure(group: group, channel: channel, note: note, pressure: pressure)
        case .controlChange:
            guard let control = Uint7(data1), let value = Uint7(data2) else { return nil }
            self = .controlChange(group: group, channel: channel, control: control, value: value)
        case .programChange:
            guard let program = Uint7(data1) else { return nil }
            self = .programChange(group: group, channel: channel, program: program)
        case .channelPressure:
            guard let pressure = Uint7(data1) else { return nil }
            self = .channelPressure(group: group, channel: channel, pressure: pressure)
        case .pitchBend:
            let value14 = UInt16(data2) << 7 | UInt16(data1)
            guard let bend = Uint14(value14) else { return nil }
            self = .pitchBend(group: group, channel: channel, value: bend)
        }
    }
}
