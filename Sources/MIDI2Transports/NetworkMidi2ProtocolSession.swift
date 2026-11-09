import Foundation

/// Pure, per-peer M2-124-UM v1.0.1 session-control slice. No socket, host
/// authorization, DNS-SD, FEC or retransmit is implemented here.
/// Source: sections 5.5, 6.1-6.6, 6.13-6.17, 7.1; pp. 24-30, 37-42.
///
/// One value belongs to one explicit remote endpoint. A future socket owner
/// must bind it to that endpoint's IP address and UDP port, as required in
/// section 8. Never reuse one state instance across different remote clients.
public struct NetworkMidi2ProtocolSession: Sendable {
    public enum Role: Sendable { case host, client }
    public enum State: Sendable { case idle, pendingInvitation, established, pendingBye }

    /// Decided by the owning host's authorization/availability policy.
    /// A received UDP invitation never grants permission by itself.
    public enum HostAdmission: Sendable {
        case allow
        case pending
        case rejectTooManySessions
        case rejectByUser
    }

    public enum SessionError: Error, Equatable, Sendable {
        case wrongRole
        case wrongState
        case admissionDecisionRequired
    }

    public struct RemoteIdentity: Equatable, Sendable {
        public let endpointName: String
        public let productInstanceID: String
    }

    public struct Outcome: Equatable, Sendable {
        /// Commands to return to the same explicitly bound transport peer.
        public let outgoing: [NetworkMidi2Command]
        /// Raw UMP words; complete message validation is not provided here.
        public let incomingUMPWords: [UInt32]
        public init(outgoing: [NetworkMidi2Command] = [], incomingUMPWords: [UInt32] = []) {
            self.outgoing = outgoing
            self.incomingUMPWords = incomingUMPWords
        }
    }

    public let role: Role
    public private(set) var state: State = .idle
    public private(set) var remoteIdentity: RemoteIdentity?
    private let endpointName: String
    private let productInstanceID: String
    private var nextSequenceNumber: UInt16 = 0
    private var outstandingPingID: UInt32?
    // Bounded duplicate suppression for retransmitted/FEC copies (§7.2.1).
    // This does not establish out-of-order buffering or lost-packet recovery.
    private var recentlyDeliveredSequenceNumbers: Set<UInt16> = []
    private var recentSequenceOrder: [UInt16] = []
    private static let duplicateHistoryLimit = 1024

    public init(role: Role, endpointName: String, productInstanceID: String) throws {
        // Reuse the source-bound codec's identity validation.
        _ = try NetworkMidi2PacketCodec.invitation(
            endpointName: endpointName, productInstanceID: productInstanceID
        )
        self.role = role
        self.endpointName = endpointName
        self.productInstanceID = productInstanceID
    }

    /// Client §6.4; any retry policy and timeout must be owned by the later
    /// transport session and represented in its scenario evidence.
    public mutating func beginInvitation() throws -> NetworkMidi2Command {
        guard role == .client else { throw SessionError.wrongRole }
        guard state == .idle else { throw SessionError.wrongState }
        state = .pendingInvitation
        return try NetworkMidi2PacketCodec.invitation(
            endpointName: endpointName, productInstanceID: productInstanceID
        )
    }

    public mutating func makePing(id: UInt32) throws -> NetworkMidi2Command {
        outstandingPingID = id
        return try NetworkMidi2Command(code: 0x20, payload: [id])
    }

    /// Only send UMP data after a session is established (§7.1).
    /// This does not implement retransmission, FEC or UMP message validation.
    public mutating func makeUMPData(words: [UInt32]) throws -> NetworkMidi2Command {
        guard state == .established else { throw SessionError.wrongState }
        let command = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: nextSequenceNumber, words: words
        )
        nextSequenceNumber &+= 1
        return command
    }

    public mutating func beginBye(reason: UInt8 = 0x01) throws -> NetworkMidi2Command {
        guard state != .idle else { throw SessionError.wrongState }
        state = .pendingBye
        return try NetworkMidi2Command(code: 0xF0, specificData: UInt16(reason) << 8)
    }

    /// One event from an already identified remote endpoint.
    /// A host MUST supply an external admission decision for a new invitation.
    /// No implicit positive authorization or fallback is permitted.
    public mutating func receive(
        _ command: NetworkMidi2Command, hostAdmission: HostAdmission? = nil
    ) throws -> Outcome {
        switch command.code {
        case 0x20: // §6.13 Ping, valid in every state
            guard command.payload.count == 1 else {
                return try nak(command, reason: 0x03)
            }
            return Outcome(outgoing: [
                try NetworkMidi2Command(code: 0x21, payload: command.payload)
            ])

        case 0x21: // §6.14 Ping Reply
            guard command.payload.count == 1 else {
                return try nak(command, reason: 0x03)
            }
            guard outstandingPingID == command.payload[0] else {
                return try nak(command, reason: 0x20)
            }
            outstandingPingID = nil
            return Outcome()

        case 0xF0: // §6.16 Bye is acknowledged even outside a session
            reset()
            return Outcome(outgoing: [try NetworkMidi2Command(code: 0xF1)])

        case 0xF1: // §6.17 Bye Reply
            if state == .pendingBye { reset() }
            return Outcome()

        case 0x01: // §6.4 Invitation
            guard role == .host else { return try nak(command, reason: 0x02) }
            guard let identity = Self.parseIdentity(command) else {
                reset()
                return Outcome(outgoing: [try bye(reason: 0x07)])
            }
            if state == .established {
                guard remoteIdentity == identity else {
                    reset()
                    return Outcome(outgoing: [try bye(reason: 0x07)])
                }
                return Outcome(outgoing: [try acceptedReply()])
            }
            guard state == .idle || state == .pendingInvitation else {
                return try nak(command, reason: 0x02)
            }
            guard let hostAdmission else {
                // A host without its policy decision cannot complete processing
                // this invitation; its caller must explicitly pend or refuse.
                throw SessionError.admissionDecisionRequired
            }
            switch hostAdmission {
            case .allow:
                remoteIdentity = identity
                state = .established
                return Outcome(outgoing: [try acceptedReply()])
            case .pending:
                remoteIdentity = identity
                state = .pendingInvitation
                return Outcome(outgoing: [try pendingReply()])
            case .rejectTooManySessions:
                reset()
                return Outcome(outgoing: [try bye(reason: 0x40)])
            case .rejectByUser:
                reset()
                return Outcome(outgoing: [try bye(reason: 0x42)])
            }

        case 0x10: // §6.5 Invitation Reply: Accepted
            guard role == .client else { return try nak(command, reason: 0x02) }
            if state == .established { return Outcome() }
            guard state == .pendingInvitation else {
                return Outcome(outgoing: [try bye(reason: 0x06)])
            }
            guard let identity = Self.parseIdentity(command) else {
                reset()
                return Outcome(outgoing: [try bye(reason: 0x07)])
            }
            remoteIdentity = identity
            nextSequenceNumber = 0
            state = .established
            return Outcome()

        case 0x11: // §6.6 Invitation Reply: Pending
            guard role == .client else { return try nak(command, reason: 0x02) }
            if state == .pendingInvitation || state == .established { return Outcome() }
            return Outcome(outgoing: [try bye(reason: 0x06)])

        case 0xFF: // §7.1 UMP Data only in Established Session
            guard state == .established else {
                reset()
                return Outcome(outgoing: [try bye(reason: 0x05)])
            }
            let sequence = command.specificData
            guard recentlyDeliveredSequenceNumbers.insert(sequence).inserted else {
                // §7.2.1: receivers ignore an already processed UMP Data command.
                return Outcome()
            }
            recentSequenceOrder.append(sequence)
            if recentSequenceOrder.count > Self.duplicateHistoryLimit {
                let forgotten = recentSequenceOrder.removeFirst()
                recentlyDeliveredSequenceNumbers.remove(forgotten)
            }
            return Outcome(incomingUMPWords: command.payload)

        default: // §5.5 unimplemented/unknown command: NAK, no session promotion
            return try nak(command, reason: 0x01)
        }
    }

    private mutating func reset() {
        state = .idle
        remoteIdentity = nil
        nextSequenceNumber = 0
        outstandingPingID = nil
        recentlyDeliveredSequenceNumbers.removeAll()
        recentSequenceOrder.removeAll()
    }

    private func acceptedReply() throws -> NetworkMidi2Command {
        try makeIdentityReply(code: 0x10)
    }

    private func pendingReply() throws -> NetworkMidi2Command {
        try makeIdentityReply(code: 0x11)
    }

    private func makeIdentityReply(code: UInt8) throws -> NetworkMidi2Command {
        // The §6.4 invitation identity format and §§6.5/6.6 reply identity
        // formats use the same word-aligned strings; only code/CSD2 differ.
        let invitation = try NetworkMidi2PacketCodec.invitation(
            endpointName: endpointName, productInstanceID: productInstanceID
        )
        return try NetworkMidi2Command(
            code: code, specificData: invitation.specificData & 0xFF00,
            payload: invitation.payload
        )
    }

    private func bye(reason: UInt8) throws -> NetworkMidi2Command {
        try NetworkMidi2Command(code: 0xF0, specificData: UInt16(reason) << 8)
    }

    private func nak(_ incoming: NetworkMidi2Command, reason: UInt8) throws -> Outcome {
        let header = (UInt32(incoming.code) << 24)
            | (UInt32(incoming.payload.count) << 16)
            | UInt32(incoming.specificData)
        return Outcome(outgoing: [
            try NetworkMidi2Command(
                code: 0x8F, specificData: UInt16(reason) << 8, payload: [header]
            )
        ])
    }

    private static func parseIdentity(_ command: NetworkMidi2Command) -> RemoteIdentity? {
        let nameWords = Int(command.specificData >> 8)
        guard (1...25).contains(nameWords),
              command.payload.count >= nameWords + 1,
              command.payload.count <= 36 else { return nil }

        let bytes = command.payload.flatMap { word -> [UInt8] in
            [UInt8(truncatingIfNeeded: word >> 24),
             UInt8(truncatingIfNeeded: word >> 16),
             UInt8(truncatingIfNeeded: word >> 8),
             UInt8(truncatingIfNeeded: word)]
        }
        let nameBytes = Array(bytes.prefix(nameWords * 4).prefix(while: { $0 != 0 }))
        let idBytes = Array(bytes.dropFirst(nameWords * 4).prefix(while: { $0 != 0 }))
        guard !nameBytes.isEmpty, nameBytes.count <= 98,
              !idBytes.isEmpty, idBytes.count <= 42,
              idBytes.allSatisfy({ (32...126).contains(Int($0)) }),
              let name = String(bytes: nameBytes, encoding: .utf8),
              let id = String(bytes: idBytes, encoding: .ascii) else { return nil }
        return RemoteIdentity(endpointName: name, productInstanceID: id)
    }
}
