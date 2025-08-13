/// Unsigned 16-bit integer value (0-65_535) as defined in the MIDI 2.0 schema.
public struct Uint16: Equatable, Hashable {
    public let rawValue: Swift.UInt16

    public init?(_ rawValue: Swift.UInt32) {
        guard rawValue <= 0xFFFF else { return nil }
        self.rawValue = Swift.UInt16(rawValue)
    }

    public init(validating rawValue: Swift.UInt32) throws {
        guard rawValue <= 0xFFFF else {
            throw MIDIError.valueOutOfRange(name: "Uint16", value: Swift.UInt64(rawValue), range: 0...0xFFFF)
        }
        self.rawValue = Swift.UInt16(rawValue)
    }
}
