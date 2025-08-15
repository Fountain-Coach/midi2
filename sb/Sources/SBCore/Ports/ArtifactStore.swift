public protocol ArtifactStore: Sendable {
    func writeSnapshot(_ snap: Snapshot) async throws
    func writeAnalysis(_ analysis: Analysis) async throws
    func readSnapshot(id: String) async throws -> Snapshot?
}
