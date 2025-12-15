import XCTest
@testable import MIDI2CI

final class MuidManagerTests: XCTestCase {
    func testUsesHintWhenAvailable() {
        let mgr = MuidManager(localHint: 0x0A0B0C0D, ttlSeconds: 30, now: { Date(timeIntervalSince1970: 0) })
        XCTAssertEqual(mgr.localMuid, 0x0A0B0C0D)
    }

    func testRotatesOnConflict() {
        let current = Date(timeIntervalSince1970: 0)
        let mgr = MuidManager(localHint: 0x01020304, ttlSeconds: 30, now: { current })
        let old = mgr.localMuid

        // Registering a peer with the same MUID should rotate the local value.
        let conflicted = mgr.registerPeer(old, at: current)
        XCTAssertTrue(conflicted)
        XCTAssertNotEqual(mgr.localMuid, old)
        XCTAssertTrue(mgr.peers.contains { $0.muid == old })
    }

    func testCleanupExpiresOldPeers() {
        var current = Date(timeIntervalSince1970: 0)
        let mgr = MuidManager(localHint: 0x11111111, ttlSeconds: 10, now: { current })

        mgr.registerPeer(0xAAAA_BBBB, at: current) // expires at t=10
        current = current.addingTimeInterval(3)
        mgr.registerPeer(0xCCCC_DDDD, at: current) // expires at t=13

        current = current.addingTimeInterval(10) // t=13
        let expired = mgr.cleanupExpired(at: current)
        XCTAssertTrue(expired.contains(0xAAAA_BBBB))
        XCTAssertFalse(expired.contains(0xCCCC_DDDD))
        XCTAssertTrue(mgr.peers.contains { $0.muid == 0xCCCC_DDDD })
    }

    func testRefreshExtendsPeerLifetime() {
        var current = Date(timeIntervalSince1970: 0)
        let mgr = MuidManager(localHint: 0x22222222, ttlSeconds: 5, now: { current })

        mgr.registerPeer(0x0F0F_F0F0, at: current) // expires at t=5
        current = current.addingTimeInterval(4)
        mgr.registerPeer(0x0F0F_F0F0, at: current) // refresh to t=4

        current = current.addingTimeInterval(2) // t=6
        let expired = mgr.cleanupExpired(at: current)
        XCTAssertFalse(expired.contains(0x0F0F_F0F0))
    }
}
