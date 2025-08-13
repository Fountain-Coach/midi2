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

    private var status: UInt8 {
        switch self {
        case .timingClock: return 0xF8
        case .start: return 0xFA
        case .continue: return 0xFB
        case .stop: return 0xFC
        case .activeSensing: return 0xFE
        case .systemReset: return 0xFF
        }
    }

    /// Encodes the message into a 32-bit UMP packet.
    public func ump() -> UmpPacket32 {
        let byte0 = UInt32(0x1 << 4 | group.rawValue)
        let word = (byte0 << 24) | (UInt32(status) << 16)
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
        switch status {
        case 0xF8: self = .timingClock(group: group)
        case 0xFA: self = .start(group: group)
        case 0xFB: self = .continue(group: group)
        case 0xFC: self = .stop(group: group)
        case 0xFE: self = .activeSensing(group: group)
        case 0xFF: self = .systemReset(group: group)
        default: return nil
        }
    }
}
