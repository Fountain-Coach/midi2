import XCTest
import Foundation
@testable import SBCore

struct DummyNavigator: Navigating {
    func snapshot(url: URL, wait: WaitPolicy, store: ArtifactStore?) async throws -> Snapshot {
        Snapshot()
    }
}

struct DummyDissector: Dissecting {
    func analyze(from snapshot: Snapshot, mode: DissectionMode, store: ArtifactStore?) async throws -> Analysis {
        Analysis()
    }
}

struct DummyIndexer: Indexing {
    func upsert(analysis: Analysis, options: IndexOptions) async throws -> IndexResult {
        IndexResult()
    }
}

final class SBTests: XCTestCase {
    func testBrowseAndDissect() async throws {
        let sb = SB(navigator: DummyNavigator(), dissector: DummyDissector(), indexer: DummyIndexer(), store: nil)
        let (snap, analysis, res) = try await sb.browseAndDissect(url: URL(string: "https://example.com")!, wait: .domContentLoaded, mode: .quick, index: IndexOptions())
        XCTAssertNotNil(snap)
        XCTAssertNotNil(analysis)
        XCTAssertNil(res)
    }
}
