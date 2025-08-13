/// 0=NOOP,1=JR Clock,2=JR Timestamp
public enum UtilityOpcode: UInt8, Equatable {
    /// No operation.  Used for padding.
    case noop        = 0x00
    /// Jitter Reduction Clock – carries a 16-bit timestamp value.
    case jrClock     = 0x01
    /// Jitter Reduction Timestamp – carries a 16-bit timestamp value.
    case jrTimestamp = 0x02
}

