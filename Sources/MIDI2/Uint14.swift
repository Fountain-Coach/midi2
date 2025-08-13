public struct Uint14: Equatable, Hashable {
    public let rawValue: UInt16

    public init?(_ rawValue: UInt16) {
        guard rawValue < 0x4000 else { return nil }
        self.rawValue = rawValue
    }

    public init(validating rawValue: UInt16) throws {
        guard rawValue < 0x4000 else {
            throw MIDIError.valueOutOfRange(name: "Uint14", value: UInt64(rawValue), range: 0...0x3FFF)
        }
        self.rawValue = rawValue
    }
}
