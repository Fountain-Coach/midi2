/// Registered Parameter Number (RPN) address.
///
/// RPN addresses are 14-bit values. This enum models well-known
/// addresses and allows representing any other address within the
/// valid range.
public enum Midi2RPNAddress: Equatable {
    /// Per-Note Pitch controller (RPN 0).
    case perNotePitch
    /// Per-Note Pressure controller (RPN 1).
    case perNotePressure
    /// Per-Note Timbre controller (RPN 2).
    case perNoteTimbre
    /// Any other RPN address within the 14-bit range.
    case other(Swift.UInt16)

    /// Creates an RPN address from the raw 14-bit value. Returns `nil` if the
    /// value is outside the permitted range `0...0x3FFF`.
    public init?(rawValue: Swift.UInt16) {
        guard rawValue <= 0x3FFF else { return nil }
        switch rawValue {
            case 0x0000: self = .perNotePitch
            case 0x0001: self = .perNotePressure
            case 0x0002: self = .perNoteTimbre
            default: self = .other(rawValue)
        }
    }

    /// The raw 14-bit address value.
    public var rawValue: Swift.UInt16 {
        switch self {
            case .perNotePitch: return 0x0000
            case .perNotePressure: return 0x0001
            case .perNoteTimbre: return 0x0002
            case .other(let v): return v
        }
    }
}
