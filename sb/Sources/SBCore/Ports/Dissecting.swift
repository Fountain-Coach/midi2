public protocol Dissecting: Sendable {
    func analyze(from snapshot: Snapshot, mode: DissectionMode, store: ArtifactStore?) async throws -> Analysis
}
