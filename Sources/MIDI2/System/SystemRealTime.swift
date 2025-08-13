import Foundation

/// UMP Type 0x1 System Real-Time messages.
public enum SystemRealTime: Equatable {
    case timingClock(group: Uint4)
    case start(group: Uint4)
    case `continue`(group: Uint4)
    case stop(group: Uint4)
    case activeSensing(group: Uint4)
    case systemReset(group: Uint4)

    public var group: Uint4 {
        switch self {
        case .timingClock(let g), .start(let g), .continue(let g), .stop(let g), .activeSensing(let g), .systemReset(let g):
            return g
        }
    }

    private var status: SystemStatus {
        switch self {
        case .timingClock: return .timingClock
        case .start: return .start
        case .continue: return .continue
        case .stop: return .stop
        case .activeSensing: return .activeSensing
        case .systemReset: return .systemReset
        }
    }

    /// Encodes the message into a 32-bit UMP packet.
    public func ump() -> UmpPacket32 {
        let body = SystemCommonRealtimeBody(status: status)
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
        case .timingClock: self = .timingClock(group: group)
        case .start: self = .start(group: group)
        case .continue: self = .continue(group: group)
        case .stop: self = .stop(group: group)
        case .activeSensing: self = .activeSensing(group: group)
        case .systemReset: self = .systemReset(group: group)
        default: return nil
        }
    }

    /// Failable initialiser that performs validation and throws `MIDIError` on
    /// malformed packets.
    public init(parsingUMP ump: UmpPacket32) throws {
        let mt = UInt8((ump.word >> 28) & 0xF)
        guard mt == 0x1 else {
            throw MIDIError.malformedPacket("expected mt 0x1 but got \(mt)")
        }
        let byte0 = UInt8((ump.word >> 24) & 0xFF)
        let group = try Uint4(validating: byte0 & 0x0F)
        let body = try SystemCommonRealtimeBody(parsingUMP: ump)
        switch body.status {
        case .timingClock: self = .timingClock(group: group)
        case .start: self = .start(group: group)
        case .continue: self = .continue(group: group)
        case .stop: self = .stop(group: group)
        case .activeSensing: self = .activeSensing(group: group)
        case .systemReset: self = .systemReset(group: group)
        default:
            throw MIDIError.malformedPacket("unsupported system realtime status 0x\(String(body.status.rawValue, radix: 16))")
        }
    }
}
