import Foundation

/// UMP Type 0x1 System Common messages.
public enum SystemCommon: Equatable {
    case mtcQuarterFrame(group: Uint4, message: Uint7)
    case songPositionPointer(group: Uint4, position: Uint14)
    case songSelect(group: Uint4, song: Uint7)
    case tuneRequest(group: Uint4)

    public var group: Uint4 {
        switch self {
        case .mtcQuarterFrame(let g, _), .songPositionPointer(let g, _), .songSelect(let g, _), .tuneRequest(let g):
            return g
        }
    }

    private var status: UInt8 {
        switch self {
        case .mtcQuarterFrame: return 0xF1
        case .songPositionPointer: return 0xF2
        case .songSelect: return 0xF3
        case .tuneRequest: return 0xF6
        }
    }

    /// Encodes the message into a 32-bit UMP packet.
    public func ump() -> UmpPacket32 {
        let byte0 = UInt32(0x1 << 4 | group.rawValue)
        let status = UInt32(self.status)
        let data1: UInt32
        let data2: UInt32
        switch self {
        case .mtcQuarterFrame(_, let message):
            data1 = UInt32(message.rawValue)
            data2 = 0
        case .songPositionPointer(_, let position):
            data1 = UInt32(position.rawValue & 0x7F)
            data2 = UInt32((position.rawValue >> 7) & 0x7F)
        case .songSelect(_, let song):
            data1 = UInt32(song.rawValue)
            data2 = 0
        case .tuneRequest:
            data1 = 0
            data2 = 0
        }
        let word = (byte0 << 24) | (status << 16) | (data1 << 8) | data2
        return UmpPacket32(word: word)
    }

    /// Decodes a 32-bit UMP packet.
    public init?(ump: UmpPacket32) {
        let mt = UInt8((ump.word >> 28) & 0xF)
        guard mt == 0x1 else { return nil }
        let byte0 = UInt8((ump.word >> 24) & 0xFF)
        guard let group = Uint4(byte0 & 0x0F) else { return nil }
        let status = UInt8((ump.word >> 16) & 0xFF)
        guard status >> 4 == 0xF else { return nil }
        let data1 = UInt8((ump.word >> 8) & 0xFF)
        let data2 = UInt8(ump.word & 0xFF)
        switch status {
        case 0xF1:
            guard let msg = Uint7(data1) else { return nil }
            self = .mtcQuarterFrame(group: group, message: msg)
        case 0xF2:
            let value = UInt16(data1 & 0x7F) | (UInt16(data2 & 0x7F) << 7)
            guard let pos = Uint14(value) else { return nil }
            self = .songPositionPointer(group: group, position: pos)
        case 0xF3:
            guard let song = Uint7(data1) else { return nil }
            self = .songSelect(group: group, song: song)
        case 0xF6:
            self = .tuneRequest(group: group)
        default:
            return nil
        }
    }

    public init(parsingUMP ump: UmpPacket32) throws {
        let mt = UInt8((ump.word >> 28) & 0xF)
        guard mt == 0x1 else {
            throw MIDIError.malformedPacket("expected mt 0x1 but got \(mt)")
        }
        let byte0 = UInt8((ump.word >> 24) & 0xFF)
        let group = try Uint4(validating: byte0 & 0x0F)
        let status = UInt8((ump.word >> 16) & 0xFF)
        guard status >> 4 == 0xF else {
            throw MIDIError.malformedPacket("invalid system common status 0x\(String(status, radix: 16))")
        }
        let data1 = UInt8((ump.word >> 8) & 0xFF)
        let data2 = UInt8(ump.word & 0xFF)
        switch status {
        case 0xF1:
            let msg = try Uint7(validating: data1)
            self = .mtcQuarterFrame(group: group, message: msg)
        case 0xF2:
            let value = UInt16(data1 & 0x7F) | (UInt16(data2 & 0x7F) << 7)
            let pos = try Uint14(validating: value)
            self = .songPositionPointer(group: group, position: pos)
        case 0xF3:
            let song = try Uint7(validating: data1)
            self = .songSelect(group: group, song: song)
        case 0xF6:
            self = .tuneRequest(group: group)
        default:
            throw MIDIError.malformedPacket("unsupported system common status 0x\(String(status, radix: 16))")
        }
    }
}
