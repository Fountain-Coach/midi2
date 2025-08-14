/// Note attribute type value (0-127) from the MIDI 2.0 specification.
public struct NoteAttributeType: Equatable, Hashable, Sendable {
    public let rawValue: UInt8

    /// Creates a new `NoteAttributeType` if `rawValue` is in the range `0...0x7F`.
    /// Returns `nil` for out-of-range values.
    public init?(_ rawValue: UInt8) {
        guard rawValue < 0x80 else { return nil }
        self.rawValue = rawValue
    }

    /// Creates a new `NoteAttributeType`, throwing an error if `rawValue` is out of range.
    public init(validating rawValue: UInt8) throws {
        guard rawValue < 0x80 else {
            throw MIDIError.valueOutOfRange(name: "NoteAttributeType", value: UInt64(rawValue), range: 0...0x7F)
        }
        self.rawValue = rawValue
    }

    public static let none = NoteAttributeType(0)!
}
