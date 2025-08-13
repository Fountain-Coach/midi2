public struct Uint7: Equatable, Hashable {
    public let rawValue: UInt8

    public init?(_ rawValue: UInt8) {
        guard rawValue < 0x80 else { return nil }
        self.rawValue = rawValue
    }
}
