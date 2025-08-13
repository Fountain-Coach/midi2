public struct Uint7: Equatable, Hashable {
    public let rawValue: UInt8

    public init?(_ rawValue: UInt8) {
        guard rawValue < 0x80 else { return nil }
        self.rawValue = rawValue
    }

    public init(validating rawValue: UInt8) throws {
        guard rawValue < 0x80 else {
            throw MIDIError.valueOutOfRange(name: "Uint7", value: UInt64(rawValue), range: 0...0x7F)
        }
        self.rawValue = rawValue
    }
}
