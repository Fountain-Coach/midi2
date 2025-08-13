/// Non-Registered Parameter Number (NRPN) address.
///
/// NRPN addresses are 14-bit values representing assignable controller
/// numbers. All values in the range `0...0x3FFF` are valid.
public enum Midi2NRPNAddress: Equatable {
    /// The raw NRPN value.
    case number(Swift.UInt16)

    /// Creates an NRPN address from the raw 14-bit value. Returns `nil` if the
    /// value is outside the permitted range `0...0x3FFF`.
    public init?(rawValue: Swift.UInt16) {
        guard rawValue <= 0x3FFF else { return nil }
        self = .number(rawValue)
    }

    /// The raw 14-bit address value.
    public var rawValue: Swift.UInt16 {
        switch self {
            case .number(let v): return v
        }
    }
}
