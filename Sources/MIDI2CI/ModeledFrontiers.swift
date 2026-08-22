/// Software-only state machines for modeled MIDI-CI/profile/property frontiers.

public struct CompatibilitySelection: Equatable {
    public let compatible: Bool
    public let selected: [String]
    public let missing: [String]

    public init(requested: [String], supported: Set<String>) {
        var seen = Set<String>()
        let unique = requested.filter { seen.insert($0).inserted }
        selected = unique.filter { supported.contains($0) }
        missing = unique.filter { !supported.contains($0) }
        compatible = missing.isEmpty
    }
}

public enum MidiCITransactionState: Equatable { case idle, requestSent, awaitingResponse, completed, failed, timedOut }

public final class MidiCITransaction {
    public private(set) var state: MidiCITransactionState = .idle
    public private(set) var failureReason: String?
    public init() {}
    public func sendRequest() throws { guard state == .idle else { throw ModeledFrontierError.invalidState }; state = .requestSent }
    public func acceptRequest() throws { guard state == .requestSent else { throw ModeledFrontierError.invalidState }; state = .awaitingResponse }
    public func receiveResponse() throws { guard state == .awaitingResponse else { throw ModeledFrontierError.invalidState }; state = .completed }
    public func timeout() throws { guard state == .awaitingResponse else { throw ModeledFrontierError.invalidState }; state = .timedOut; failureReason = "timeout" }
    public func reject(reason: String = "rejected") throws { guard state == .requestSent || state == .awaitingResponse else { throw ModeledFrontierError.invalidState }; state = .failed; failureReason = reason }
}

public enum ProfileChannelAllocationState: Equatable { case unallocated, inquiry, negotiating, allocated, released, rejected }

public final class ProfileChannelAllocation {
    public let profileId: String
    public let channels: [UInt8]
    public private(set) var state: ProfileChannelAllocationState = .unallocated

    public init(profileId: String, channels: [UInt8]) throws {
        guard !profileId.isEmpty, !channels.isEmpty, channels.allSatisfy({ $0 < 16 }) else { throw ModeledFrontierError.invalidInput }
        self.profileId = profileId
        self.channels = Array(Set(channels)).sorted()
    }
    public func inquire() throws { guard state == .unallocated || state == .released || state == .rejected else { throw ModeledFrontierError.invalidState }; state = .inquiry }
    public func beginNegotiation() throws { guard state == .inquiry else { throw ModeledFrontierError.invalidState }; state = .negotiating }
    public func accept() throws { guard state == .negotiating else { throw ModeledFrontierError.invalidState }; state = .allocated }
    public func reject() throws { guard state == .negotiating else { throw ModeledFrontierError.invalidState }; state = .rejected }
    public func release() throws { guard state == .allocated else { throw ModeledFrontierError.invalidState }; state = .released }
}

public enum PropertyExchangeResourceState: Equatable { case idle, requested, accepted, responding, completed, rejected, invalid }

public final class PropertyExchangeResourceTransaction {
    public let resource: String
    public let requestId: UInt32
    public private(set) var state: PropertyExchangeResourceState = .idle
    public private(set) var failureReason: String?
    public init(resource: String, requestId: UInt32) throws { guard !resource.isEmpty else { throw ModeledFrontierError.invalidInput }; self.resource = resource; self.requestId = requestId }
    public func request() throws { guard state == .idle else { throw ModeledFrontierError.invalidState }; state = .requested }
    public func accept() throws { guard state == .requested else { throw ModeledFrontierError.invalidState }; state = .accepted }
    public func beginResponse() throws { guard state == .accepted || state == .responding else { throw ModeledFrontierError.invalidState }; state = .responding }
    public func complete() throws { guard state == .responding else { throw ModeledFrontierError.invalidState }; state = .completed }
    public func reject(reason: String = "rejected") throws { guard state == .requested || state == .accepted else { throw ModeledFrontierError.invalidState }; state = .rejected; failureReason = reason }
    public func invalidate(reason: String = "invalid-resource") throws { guard state != .completed else { throw ModeledFrontierError.invalidState }; state = .invalid; failureReason = reason }
}

public enum ModeledFrontierError: Error, Equatable { case invalidInput, invalidState }
