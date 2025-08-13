/// Note attribute type value (0-127) from the MIDI 2.0 specification.
public struct NoteAttributeType: Equatable, Hashable, Sendable {
    public let rawValue: UInt8

    public init(_ rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let none = NoteAttributeType(0)
}
