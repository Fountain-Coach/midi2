/// Convenience wrapper for an array of bytes.
public struct ByteArray: Equatable, Hashable {
    public let rawValue: [Swift.UInt8]

    public init(_ rawValue: [Swift.UInt8]) {
        self.rawValue = rawValue
    }

    public init?(_ rawValue: [Swift.UInt16]) {
        var bytes: [Swift.UInt8] = []
        bytes.reserveCapacity(rawValue.count)
        for b in rawValue {
            guard b <= 0xFF else { return nil }
            bytes.append(Swift.UInt8(b))
        }
        self.rawValue = bytes
    }

    public init(validating rawValue: [Swift.UInt16]) throws {
        var bytes: [Swift.UInt8] = []
        bytes.reserveCapacity(rawValue.count)
        for b in rawValue {
            guard b <= 0xFF else {
                throw MIDIError.valueOutOfRange(name: "ByteArray", value: Swift.UInt64(b), range: 0...0xFF)
            }
            bytes.append(Swift.UInt8(b))
        }
        self.rawValue = bytes
    }
}
