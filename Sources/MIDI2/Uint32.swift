/// Unsigned 32-bit integer value (0-4_294_967_295) as defined in the MIDI 2.0 schema.
public struct Uint32: Equatable, Hashable {
    public let rawValue: Swift.UInt32

    public init?(_ rawValue: Swift.UInt64) {
        guard rawValue <= 0xFFFF_FFFF else { return nil }
        self.rawValue = Swift.UInt32(rawValue)
    }

    public init(validating rawValue: Swift.UInt64) throws {
        guard rawValue <= 0xFFFF_FFFF else {
            throw MIDIError.valueOutOfRange(name: "Uint32", value: rawValue, range: 0...0xFFFF_FFFF)
        }
        self.rawValue = Swift.UInt32(rawValue)
    }
}
