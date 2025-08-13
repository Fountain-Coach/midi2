/// Opcode values for UMP Utility messages.
///
/// These opcodes occupy the status byte of a message type ``0x0`` packet and
/// determine how the remaining 16 bits of the packet should be interpreted.
/// The library only defines the three opcodes currently specified by the
/// standard.
public enum UtilityOpcode: UInt8, Equatable {
    /// No operation.  Used for padding.
    case noop        = 0x00
    /// Jitter Reduction Clock – carries a 16-bit timestamp value.
    case jrClock     = 0x01
    /// Jitter Reduction Timestamp – carries a 16-bit timestamp value.
    case jrTimestamp = 0x02
}

