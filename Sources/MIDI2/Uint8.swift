/// Unsigned 8-bit integer value (0-255) as defined in the MIDI 2.0 schema.
public struct Uint8: Equatable, Hashable {
    public let rawValue: Swift.UInt8

    public init?(_ rawValue: Swift.UInt16) {
        guard rawValue <= 0xFF else { return nil }
        self.rawValue = Swift.UInt8(rawValue)
    }

    public init(validating rawValue: Swift.UInt16) throws {
        guard rawValue <= 0xFF else {
            throw MIDIError.valueOutOfRange(name: "Uint8", value: Swift.UInt64(rawValue), range: 0...0xFF)
        }
        self.rawValue = Swift.UInt8(rawValue)
    }
}
