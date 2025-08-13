/// Signed 32-bit integer value as defined in the MIDI 2.0 schema.
public struct Int32: Equatable, Hashable {
    public let rawValue: Swift.Int32

    public init?(_ rawValue: Swift.Int64) {
        guard rawValue >= Swift.Int64(Swift.Int32.min) && rawValue <= Swift.Int64(Swift.Int32.max) else { return nil }
        self.rawValue = Swift.Int32(rawValue)
    }

    public init(validating rawValue: Swift.Int64) throws {
        let min = Swift.Int64(Swift.Int32.min)
        let max = Swift.Int64(Swift.Int32.max)
        guard rawValue >= min && rawValue <= max else {
            let range: ClosedRange<Swift.UInt64> = 0...0xFFFF_FFFF
            throw MIDIError.valueOutOfRange(name: "Int32", value: Swift.UInt64(bitPattern: rawValue), range: range)
        }
        self.rawValue = Swift.Int32(rawValue)
    }
}

