import Foundation

/// Tracks allocation and lifetime of MIDI-CI MUIDs (MIDI Universal IDs).
/// Handles local allocation, peer tracking, conflict detection, and expiry.
public final class MuidManager {
    public struct PeerState: Equatable {
        public let muid: UInt32
        public let lastSeen: Date
    }

    private var peerLastSeen: [UInt32: Date] = [:]
    private let ttlSeconds: TimeInterval
    private let now: () -> Date

    /// Local MUID managed by this instance.
    public private(set) var localMuid: UInt32

    /// Creates a manager.
    /// - Parameters:
    ///   - localHint: Preferred starting MUID (used if valid and non-conflicting).
    ///   - ttlSeconds: Expiry window for peer entries.
    ///   - now: Clock injection for testability.
    public init(localHint: UInt32? = nil, ttlSeconds: TimeInterval = 120, now: @escaping () -> Date = Date.init) {
        self.ttlSeconds = ttlSeconds
        self.now = now
        self.localMuid = 0
        self.localMuid = allocateUnique(preferred: localHint)
    }

    /// Registers or refreshes a peer MUID. Returns `true` if this registration
    /// conflicted with the local MUID and forced a rotation.
    @discardableResult
    public func registerPeer(_ muid: UInt32, at timestamp: Date? = nil) -> Bool {
        guard isUsable(muid) else { return false }
        let seen = timestamp ?? now()
        peerLastSeen[muid] = seen
        if muid == localMuid {
            rotateLocal()
            return true
        }
        return false
    }

    /// Releases a peer entry manually.
    public func releasePeer(_ muid: UInt32) {
        peerLastSeen.removeValue(forKey: muid)
    }

    /// Removes peers whose lastSeen is older than the TTL. Returns the removed MUIDs.
    @discardableResult
    public func cleanupExpired(at timestamp: Date? = nil) -> [UInt32] {
        let cutoff = (timestamp ?? now()).addingTimeInterval(-ttlSeconds)
        let expired = peerLastSeen.filter { $0.value < cutoff }.map(\.key)
        expired.forEach { peerLastSeen.removeValue(forKey: $0) }
        return expired
    }

    /// Returns the currently tracked peers and their last-seen timestamps.
    public var peers: [PeerState] {
        peerLastSeen.map { PeerState(muid: $0.key, lastSeen: $0.value) }
    }

    /// Forces a new local MUID, ensuring no collision with known peers.
    @discardableResult
    public func rotateLocal() -> UInt32 {
        localMuid = allocateUnique()
        return localMuid
    }

    private func allocateUnique(preferred: UInt32? = nil) -> UInt32 {
        if let candidate = preferred, isUsable(candidate), !peerLastSeen.keys.contains(candidate) {
            return candidate
        }
        // Limit attempts to avoid an infinite loop, then fall back to a linear scan.
        for _ in 0..<16 {
            let candidate = UInt32.random(in: 1...UInt32.max)
            if isUsable(candidate) && !peerLastSeen.keys.contains(candidate) && candidate != localMuid {
                return candidate
            }
        }
        // Deterministic fallback: scan upward from 1.
        var candidate: UInt32 = 1
        while !isUsable(candidate) || peerLastSeen.keys.contains(candidate) || candidate == localMuid {
            candidate &+= 1
            if candidate == 0 { candidate = 1 } // wrap protection
        }
        return candidate
    }

    private func isUsable(_ muid: UInt32) -> Bool {
        // Reserve 0 to avoid "unassigned" collisions; spec leaves 32-bit space open otherwise.
        return muid != 0
    }
}
