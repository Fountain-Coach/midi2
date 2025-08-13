/// Unsigned 4-bit integer value (0-15) as defined in the MIDI 2.0 schema.
public struct Uint4: Equatable, Hashable {
    public let rawValue: UInt8

    public init?(_ rawValue: UInt8) {
        guard rawValue < 0x10 else { return nil }
        self.rawValue = rawValue
    }

    public init(validating rawValue: UInt8) throws {
        guard rawValue < 0x10 else {
            throw MIDIError.valueOutOfRange(name: "Uint4", value: UInt64(rawValue), range: 0...0xF)
        }
        self.rawValue = rawValue
    }
}
