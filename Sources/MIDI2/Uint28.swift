/// Unsigned 28-bit integer value (0-268_435_455) as defined in the MIDI 2.0 schema.
public struct Uint28: Equatable, Hashable {
    public let rawValue: Swift.UInt32

    public init?(_ rawValue: Swift.UInt32) {
        guard rawValue < 0x1_0000_000 else { return nil } // 0x10000000
        self.rawValue = rawValue
    }

    public init(validating rawValue: Swift.UInt32) throws {
        guard rawValue < 0x1_0000_000 else {
            throw MIDIError.valueOutOfRange(name: "Uint28", value: Swift.UInt64(rawValue), range: 0...0x0FFF_FFFF)
        }
        self.rawValue = rawValue
    }
}
