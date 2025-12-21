import Foundation

/// UMP Type 0x0 Utility messages (groupless).
public enum Utility: Equatable {
    /// No operation. Used for padding.
    case noop
    /// Jitter reduction clock. 20-bit timestamp.
    case jrClock(UInt32)
    /// Jitter reduction timestamp. 20-bit timestamp.
    case jrTimestamp(UInt32)
    /// Delta Clockstamp Ticks Per Quarter Note (DCTPQ).
    case dctpq(UInt16)
    /// Delta Clockstamp (ticks since last event).
    case deltaClockstamp(UInt32)

    /// Encodes the message into a 32-bit UMP packet.
    public func ump() -> UmpPacket32 {
        switch self {
        case .noop:
            return UtilityBody(opcode: .noop, value: 0).ump()
        case .jrClock(let value):
            return UtilityBody(opcode: .jrClock, value: value).ump()
        case .jrTimestamp(let value):
            return UtilityBody(opcode: .jrTimestamp, value: value).ump()
        case .dctpq(let value):
            return UtilityBody(opcode: .dctpq, value: UInt32(value)).ump()
        case .deltaClockstamp(let value):
            return UtilityBody(opcode: .deltaClockstamp, value: value).ump()
        }
    }

    /// Decodes a 32-bit UMP packet.
    public init?(ump: UmpPacket32) {
        guard let body = UtilityBody(ump: ump) else { return nil }
        switch body.opcode {
        case .noop:
            self = .noop
        case .jrClock:
            self = .jrClock(body.value)
        case .jrTimestamp:
            self = .jrTimestamp(body.value)
        case .dctpq:
            guard body.value <= 0xFFFF else { return nil }
            self = .dctpq(UInt16(body.value))
        case .deltaClockstamp:
            self = .deltaClockstamp(body.value)
        }
    }

    public init(parsingUMP ump: UmpPacket32) throws {
        let body = try UtilityBody(parsingUMP: ump)
        switch body.opcode {
        case .noop:
            self = .noop
        case .jrClock:
            self = .jrClock(body.value)
        case .jrTimestamp:
            self = .jrTimestamp(body.value)
        case .dctpq:
            guard body.value <= 0xFFFF else {
                throw MIDIError.malformedPacket("utility dctpq must use a 16-bit payload")
            }
            self = .dctpq(UInt16(body.value))
        case .deltaClockstamp:
            self = .deltaClockstamp(body.value)
        }
    }
}
