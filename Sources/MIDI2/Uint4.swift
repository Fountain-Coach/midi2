public struct Uint4: Equatable, Hashable {
    public let rawValue: UInt8

    public init?(_ rawValue: UInt8) {
        guard rawValue < 0x10 else { return nil }
        self.rawValue = rawValue
    }
}
