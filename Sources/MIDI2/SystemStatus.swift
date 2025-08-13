/// MIDI System Common/Real-Time per UMP.
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

