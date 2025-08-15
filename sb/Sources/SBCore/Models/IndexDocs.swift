public struct IndexOptions: Sendable {
    public var enabled: Bool
    public init(enabled: Bool = false) {
        self.enabled = enabled
    }
}

public struct IndexResult: Codable, Sendable {
    public init() {}
}
