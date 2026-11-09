import Foundation

/// The source-backed no-authentication *model* of one M2-124-UM v1.0.1
/// Host/Client transport relationship. One instance belongs to one external
/// peer; this type neither opens sockets nor admits an FCIS instrument.
/// Sections: 5.5, 6.1-6.6, 6.11-6.17, 7.1-7.2.
public enum NetworkMidi2SessionRole: Sendable { case host, client }

public enum NetworkMidi2SessionPhase: Sendable, Equatable {
    case idle, pendingInvitation, established, pendingSessionReset, pendingBye
}

public enum NetworkMidi2SessionError: Error, Equatable {
    case wrongRole
    case invalidState
    case sessionNotEstablished
}

public enum NetworkMidi2SessionEffect: Sendable, Equatable {
    case send(NetworkMidi2Command)
    case transportEstablished
    case transportClosed
    case pendingInvitation
    case umpPayloadForValidation([UInt32])
    case idleUMP
    case ignoredDuplicate(sequence: UInt16)
    case missingSequence(expected: UInt16, received: UInt16)
    case pingMatched(UInt32)
    case nakReceived(UInt8)
}

/// This state machine is intentionally not a MIDITransport: packet transport,
/// peer addressing, retry/timing, authentication, full UMP validation and
/// independent peer acceptance remain obligations of NetworkMidi2Session.
public struct NetworkMidi2SessionCore: Sendable {
    public let role: NetworkMidi2SessionRole
    public let endpointName: String
    public let productInstanceID: String
    public private(set) var phase: NetworkMidi2SessionPhase = .idle
    public private(set) var expectedInboundSequence: UInt16 = 0
    public private(set) var nextOutboundSequence: UInt16 = 0

    private var observedSequenceNumbers: Set<UInt16> = []
    private var observedOrder: [UInt16] = []
    private var pendingPingID: UInt32?

    public init(role: NetworkMidi2SessionRole, endpointName: String, productInstanceID: String) throws {
        // Reuse the normative string constraints from the wire codec.
        _ = try NetworkMidi2PacketCodec.invitation(
            endpointName: endpointName, productInstanceID: productInstanceID
        )
        self.role = role
        self.endpointName = endpointName
        self.productInstanceID = productInstanceID
    }

    /// Client session invitation, no authentication capability advertised.
    public mutating func beginInvitation() throws -> NetworkMidi2SessionEffect {
        guard role == .client else { throw NetworkMidi2SessionError.wrongRole }
        guard phase == .idle else { throw NetworkMidi2SessionError.invalidState }
        phase = .pendingInvitation
        return .send(try NetworkMidi2PacketCodec.invitation(
            endpointName: endpointName, productInstanceID: productInstanceID
        ))
    }

    /// Called only after the external transport policy permits an invitation.
    /// This flag is *not* FCIS instrument admission and grants no operations.
    public mutating func receive(
        _ command: NetworkMidi2Command, transportPeerPermitted: Bool = false
    ) throws -> [NetworkMidi2SessionEffect] {
        switch command.code {
        case 0x01: // Invitation
            guard role == .host else {
                return [.send(try nak(for: command, reason: 0x02))]
            }
            do { _ = try NetworkMidi2PacketCodec.endpointIdentity(from: command) }
            catch {
                setIdle()
                return [.send(try bye(reason: 0x07)), .transportClosed]
            }
            if phase == .established {
                return [.send(try accepted())] // repeated invitation, §6.4
            }
            guard phase == .idle else {
                return [.send(try nak(for: command, reason: 0x02))]
            }
            guard transportPeerPermitted else {
                return [.send(try bye(reason: 0x42)), .transportClosed]
            }
            resetSequenceState()
            phase = .established
            return [.send(try accepted()), .transportEstablished]

        case 0x10: // Invitation Reply: Accepted
            if role == .client && phase == .established { return [] } // §6.5 duplicate reply
            guard role == .client, phase == .pendingInvitation else {
                setIdle()
                return [.send(try bye(reason: 0x06)), .transportClosed]
            }
            do { _ = try NetworkMidi2PacketCodec.endpointIdentity(from: command) }
            catch {
                setIdle()
                return [.send(try bye(reason: 0x07)), .transportClosed]
            }
            resetSequenceState()
            phase = .established
            return [.transportEstablished]

        case 0x11: // Invitation Reply: Pending
            if role == .client && phase == .established { return [] }
            guard role == .client, phase == .pendingInvitation else {
                setIdle()
                return [.send(try bye(reason: 0x06)), .transportClosed]
            }
            do { _ = try NetworkMidi2PacketCodec.endpointIdentity(from: command) }
            catch {
                setIdle()
                return [.send(try bye(reason: 0x07)), .transportClosed]
            }
            return [.pendingInvitation]

        case 0x12, 0x13: // Authentication requested but not supported by this core
            setIdle()
            return [.send(try bye(reason: 0x45)), .transportClosed]

        case 0x20: // Ping is valid in every state
            guard command.payload.count == 1 else {
                return [.send(try nak(for: command, reason: 0x03))]
            }
            return [.send(try NetworkMidi2Command(code: 0x21, payload: command.payload))]

        case 0x21: // Ping Reply
            guard command.payload.count == 1,
                  pendingPingID == command.payload[0] else {
                return [.send(try nak(for: command, reason: 0x20))]
            }
            pendingPingID = nil
            return [.pingMatched(command.payload[0])]

        case 0xFF: // UMP Data, §7.1
            guard phase == .established else {
                setIdle()
                return [.send(try bye(reason: 0x05)), .transportClosed]
            }
            let sequence = command.specificData
            if observedSequenceNumbers.contains(sequence) {
                return [.ignoredDuplicate(sequence: sequence)]
            }
            guard sequence == expectedInboundSequence else {
                return [.missingSequence(expected: expectedInboundSequence, received: sequence)]
            }
            observedSequenceNumbers.insert(sequence)
            observedOrder.append(sequence)
            if observedOrder.count > 128 {
                let stale = observedOrder.removeFirst()
                observedSequenceNumbers.remove(stale)
            }
            expectedInboundSequence &+= 1
            return command.payload.isEmpty ? [.idleUMP] : [.umpPayloadForValidation(command.payload)]

        case 0x80: // Retransmit is not implemented in this bounded model
            guard phase == .established else {
                setIdle()
                return [.send(try bye(reason: 0x05)), .transportClosed]
            }
            return [.send(try nak(for: command, reason: 0x01))]

        case 0x82: // Session Reset
            guard phase == .established || phase == .pendingSessionReset else {
                setIdle()
                return [.send(try bye(reason: 0x05)), .transportClosed]
            }
            resetSequenceState()
            phase = .established
            return [.send(try NetworkMidi2Command(code: 0x83))]

        case 0x83: // Session Reset Reply
            guard phase == .pendingSessionReset else {
                return phase == .established
                    ? [.send(try requestReset())]
                    : [.send(try bye(reason: 0x05))]
            }
            resetSequenceState()
            phase = .established
            return []

        case 0x8F: // NAK does not terminate the session
            return [.nakReceived(UInt8(command.specificData >> 8))]

        case 0xF0: // Bye, respond even if no session is established
            setIdle()
            return [.send(try NetworkMidi2Command(code: 0xF1)), .transportClosed]

        case 0xF1: // Bye Reply
            guard phase == .pendingBye else { return [] }
            setIdle()
            return [.transportClosed]

        default:
            return [.send(try nak(for: command, reason: 0x01))]
        }
    }

    /// The caller must feed whole, validated UMP messages, not arbitrary words.
    public mutating func sendUMP(_ validatedWholeUMPWords: [UInt32]) throws -> NetworkMidi2SessionEffect {
        guard phase == .established else { throw NetworkMidi2SessionError.sessionNotEstablished }
        let command = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: nextOutboundSequence, words: validatedWholeUMPWords
        )
        nextOutboundSequence &+= 1
        return .send(command)
    }

    public mutating func beginPing(id: UInt32) throws -> NetworkMidi2SessionEffect {
        pendingPingID = id
        return .send(try NetworkMidi2Command(code: 0x20, payload: [id]))
    }

    public mutating func beginReset() throws -> NetworkMidi2SessionEffect {
        guard phase == .established else { throw NetworkMidi2SessionError.sessionNotEstablished }
        phase = .pendingSessionReset
        return .send(try NetworkMidi2Command(code: 0x82))
    }

    public mutating func beginBye(reason: UInt8 = 0x01) throws -> NetworkMidi2SessionEffect {
        phase = .pendingBye
        return .send(try bye(reason: reason))
    }

    private func accepted() throws -> NetworkMidi2Command {
        let invitation = try NetworkMidi2PacketCodec.invitation(
            endpointName: endpointName, productInstanceID: productInstanceID
        )
        return try NetworkMidi2Command(
            code: 0x10, specificData: invitation.specificData & 0xFF00,
            payload: invitation.payload
        )
    }

    private func bye(reason: UInt8) throws -> NetworkMidi2Command {
        try NetworkMidi2Command(code: 0xF0, specificData: UInt16(reason) << 8)
    }

    private func nak(for original: NetworkMidi2Command, reason: UInt8) throws -> NetworkMidi2Command {
        let header = UInt32(original.code) << 24
            | UInt32(original.payload.count) << 16 | UInt32(original.specificData)
        return try NetworkMidi2Command(code: 0x8F, specificData: UInt16(reason) << 8, payload: [header])
    }

    private mutating func requestReset() throws -> NetworkMidi2Command {
        phase = .pendingSessionReset
        return try NetworkMidi2Command(code: 0x82)
    }

    private mutating func resetSequenceState() {
        expectedInboundSequence = 0
        nextOutboundSequence = 0
        observedSequenceNumbers.removeAll()
        observedOrder.removeAll()
    }

    private mutating func setIdle() {
        phase = .idle
        pendingPingID = nil
        resetSequenceState()
    }
}
