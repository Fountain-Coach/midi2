public protocol Indexing: Sendable {
    func upsert(analysis: Analysis, options: IndexOptions) async throws -> IndexResult
}
