/// Per-Note Pitch value.
///
/// Stored as a signed 32-bit integer. The full `Int32` range is
/// available which allows representing pitch offsets using the
/// 16.16 fixed-point format defined by the MIDI 2.0 specification.
public struct PerNotePitch: Equatable {
    /// Raw pitch value.
    public let value: Swift.Int32

    /// Creates a pitch value. Returns `nil` if the value is outside the
    /// valid 32-bit signed integer range.
    public init?(_ value: Swift.Int64) {
        guard value >= Swift.Int64(Swift.Int32.min) && value <= Swift.Int64(Swift.Int32.max) else {
            return nil
        }
        self.value = Swift.Int32(value)
    }

    /// Encodes the pitch to its 32-bit representation.
    public func encode() -> Swift.UInt32 {
        Swift.UInt32(bitPattern: value)
    }

    /// Decodes a 32-bit representation into a `PerNotePitch`.
    public static func decode(_ rawValue: Swift.UInt32) -> PerNotePitch {
        // Decoding always succeeds because all 32-bit patterns are valid.
        PerNotePitch(Swift.Int64(Swift.Int32(bitPattern: rawValue)))!
    }
}
