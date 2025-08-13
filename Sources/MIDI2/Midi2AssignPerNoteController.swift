/// Assignable Per-Note Controller address.
///
/// These addresses correspond to per-note controller numbers that can be
/// freely assigned. Valid values are in the 7-bit range `0...127`.
public enum Midi2AssignableControllerAddress: Equatable {
    /// Raw controller number.
    case number(Swift.UInt8)

    /// Creates an address from a raw 7-bit value. Returns `nil` if the value
    /// exceeds the permitted range.
    public init?(rawValue: Swift.UInt8) {
        guard rawValue <= 0x7F else { return nil }
        self = .number(rawValue)
    }

    /// The raw controller number.
    public var rawValue: Swift.UInt8 {
        switch self {
            case .number(let v): return v
        }
    }
}
