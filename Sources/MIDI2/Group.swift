/// MIDI Group (0-15). Utility (0x0) and Stream (0xF) are groupless in v1.1+; set 0.
public struct Group: Equatable, Hashable {
    public let rawValue: Swift.UInt8

    public init?(_ rawValue: Swift.UInt8) {
        guard rawValue < 0x10 else { return nil }
        self.rawValue = rawValue
    }

    public init(validating rawValue: Swift.UInt8) throws {
        guard rawValue < 0x10 else {
            throw MIDIError.valueOutOfRange(name: "Group", value: Swift.UInt64(rawValue), range: 0...0xF)
        }
        self.rawValue = rawValue
    }
}
