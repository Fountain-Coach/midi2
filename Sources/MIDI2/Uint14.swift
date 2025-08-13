public struct Uint14: Equatable, Hashable {
    public let rawValue: UInt16

    public init?(_ rawValue: UInt16) {
        guard rawValue < 0x4000 else { return nil }
        self.rawValue = rawValue
    }
}
