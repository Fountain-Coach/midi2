/// High 4 bits of a MIDI 2.0 status byte (0x8-0xF).
public struct Midi2StatusNibble: Equatable, Hashable {
    public let rawValue: UInt8

    public init?(_ rawValue: UInt8) {
        guard (0x8...0xF).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }

    public init(validating rawValue: UInt8) throws {
        guard (0x8...0xF).contains(rawValue) else {
            throw MIDIError.valueOutOfRange(name: "Midi2StatusNibble", value: UInt64(rawValue), range: 0x8...0xF)
        }
        self.rawValue = rawValue
    }
}
