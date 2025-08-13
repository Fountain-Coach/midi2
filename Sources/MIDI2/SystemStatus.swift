/// All status bytes that are considered valid for UMP System Common and
/// System Real‑Time messages.
///
/// The values correspond directly to the 8‑bit status byte found in the
/// second byte of a message type ``0x1`` UMP packet.  Both System Common and
/// System Real‑Time messages share this enumeration.
public enum SystemStatus: UInt8, Equatable {
    // System Common
    case mtcQuarterFrame     = 0xF1
    case songPositionPointer = 0xF2
    case songSelect          = 0xF3
    case tuneRequest         = 0xF6

    // System Real‑Time
    case timingClock  = 0xF8
    case start        = 0xFA
    case `continue`   = 0xFB
    case stop         = 0xFC
    case activeSensing = 0xFE
    case systemReset   = 0xFF
}

