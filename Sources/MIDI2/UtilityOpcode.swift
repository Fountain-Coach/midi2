/// Utility opcodes (4-bit) for UMP Utility messages.
public enum UtilityOpcode: UInt8, Equatable {
    /// No operation.  Used for padding.
    case noop        = 0x0
    /// Jitter Reduction Clock – carries a 20-bit timestamp value.
    case jrClock     = 0x1
    /// Jitter Reduction Timestamp – carries a 20-bit timestamp value.
    case jrTimestamp = 0x2
    /// Delta Clockstamp Ticks Per Quarter Note (DCTPQ).
    case dctpq       = 0x3
    /// Delta Clockstamp (ticks since last event).
    case deltaClockstamp = 0x4
}
