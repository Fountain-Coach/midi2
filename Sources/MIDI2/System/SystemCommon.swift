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

    private var status: SystemStatus {
        switch self {
        case .mtcQuarterFrame: return .mtcQuarterFrame
        case .songPositionPointer: return .songPositionPointer
        case .songSelect: return .songSelect
        case .tuneRequest: return .tuneRequest
        }
    }

    /// Encodes the message into a 32-bit UMP packet.
    public func ump() -> UmpPacket32 {
        let body: SystemCommonRealtimeBody
        switch self {
        case .mtcQuarterFrame(_, let message):
            body = SystemCommonRealtimeBody(status: status, data1: message.rawValue)
        case .songPositionPointer(_, let position):
            let lsb = UInt8(position.rawValue & 0x7F)
            let msb = UInt8((position.rawValue >> 7) & 0x7F)
            body = SystemCommonRealtimeBody(status: status, data1: lsb, data2: msb)
        case .songSelect(_, let song):
            body = SystemCommonRealtimeBody(status: status, data1: song.rawValue)
        case .tuneRequest:
            body = SystemCommonRealtimeBody(status: status)
        }
        return body.ump(group: group)
    }

    /// Decodes a 32-bit UMP packet.
    public init?(ump: UmpPacket32) {
        let mt = UInt8((ump.word >> 28) & 0xF)
        guard mt == 0x1 else { return nil }
        let byte0 = UInt8((ump.word >> 24) & 0xFF)
        guard let group = Uint4(byte0 & 0x0F) else { return nil }
        guard let body = SystemCommonRealtimeBody(ump: ump) else { return nil }
        switch body.status {
        case .mtcQuarterFrame:
            guard let msg = Uint7(body.data1) else { return nil }
            self = .mtcQuarterFrame(group: group, message: msg)
        case .songPositionPointer:
            let value = UInt16(body.data1 & 0x7F) | (UInt16(body.data2 & 0x7F) << 7)
            guard let pos = Uint14(value) else { return nil }
            self = .songPositionPointer(group: group, position: pos)
        case .songSelect:
            guard let song = Uint7(body.data1) else { return nil }
            self = .songSelect(group: group, song: song)
        case .tuneRequest:
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
        let body = try SystemCommonRealtimeBody(parsingUMP: ump)
        switch body.status {
        case .mtcQuarterFrame:
            let msg = try Uint7(validating: body.data1)
            self = .mtcQuarterFrame(group: group, message: msg)
        case .songPositionPointer:
            let value = UInt16(body.data1 & 0x7F) | (UInt16(body.data2 & 0x7F) << 7)
            let pos = try Uint14(validating: value)
            self = .songPositionPointer(group: group, position: pos)
        case .songSelect:
            let song = try Uint7(validating: body.data1)
            self = .songSelect(group: group, song: song)
        case .tuneRequest:
            self = .tuneRequest(group: group)
        default:
            throw MIDIError.malformedPacket("unsupported system common status 0x\(String(body.status.rawValue, radix: 16))")
        }
    }
}
