/// Unsigned 21-bit integer value (0-2_097_151) as defined in the MIDI 2.0 schema.
public struct Uint21: Equatable, Hashable {
    public let rawValue: Swift.UInt32

    public init?(_ rawValue: Swift.UInt32) {
        guard rawValue < 0x20_0000 else { return nil }
        self.rawValue = rawValue
    }

    public init(validating rawValue: Swift.UInt32) throws {
        guard rawValue < 0x20_0000 else {
            throw MIDIError.valueOutOfRange(name: "Uint21", value: Swift.UInt64(rawValue), range: 0...0x1F_FFFF)
        }
        self.rawValue = rawValue
    }
}
