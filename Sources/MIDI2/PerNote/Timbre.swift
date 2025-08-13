/// Per-Note Timbre value.
///
/// Stored as an unsigned 32-bit integer spanning the full range
/// `0...UInt32.max`.
public struct PerNoteTimbre: Equatable {
    /// Raw timbre value.
    public let value: Swift.UInt32

    /// Creates a timbre value. Returns `nil` if the supplied value is
    /// outside the valid unsigned 32-bit range.
    public init?(_ value: Swift.UInt64) {
        guard value <= Swift.UInt64(Swift.UInt32.max) else { return nil }
        self.value = Swift.UInt32(value)
    }

    /// Encodes the timbre to its raw 32-bit representation.
    public func encode() -> Swift.UInt32 { value }

    /// Decodes a 32-bit representation into a `PerNoteTimbre`.
    public static func decode(_ rawValue: Swift.UInt32) -> PerNoteTimbre {
        PerNoteTimbre(Swift.UInt64(rawValue))!
    }
}
