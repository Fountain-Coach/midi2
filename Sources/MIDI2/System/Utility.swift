import Foundation

/// UMP Type 0x0 Utility messages (groupless).
public enum Utility: Equatable {
    /// No operation. Used for padding.
    case noop
    /// Jitter reduction clock. 16-bit timestamp.
    case jrClock(UInt16)
    /// Jitter reduction timestamp. 16-bit timestamp.
    case jrTimestamp(UInt16)

    /// Encodes the message into a 32-bit UMP packet.
    public func ump() -> UmpPacket32 {
        let status: UInt8
        let data: UInt16
        switch self {
        case .noop:
            status = 0x00
            data = 0
        case .jrClock(let value):
            status = 0x01
            data = value
        case .jrTimestamp(let value):
            status = 0x02
            data = value
        }
        let byte0 = UInt32(0x0 << 4) // message type 0x0, groupless
        let word = (byte0 << 24) | (UInt32(status) << 16) | UInt32(data)
        return UmpPacket32(word: word)
    }

    /// Decodes a 32-bit UMP packet.
    public init?(ump: UmpPacket32) {
        let mt = UInt8((ump.word >> 28) & 0xF)
        guard mt == 0x0 else { return nil }
        let byte0 = UInt8((ump.word >> 24) & 0xFF)
        guard (byte0 & 0x0F) == 0 else { return nil } // groupless
        let status = UInt8((ump.word >> 16) & 0xFF)
        let data = UInt16(ump.word & 0xFFFF)
        switch status {
        case 0x00:
            self = .noop
        case 0x01:
            self = .jrClock(data)
        case 0x02:
            self = .jrTimestamp(data)
        default:
            return nil
        }
    }
}
