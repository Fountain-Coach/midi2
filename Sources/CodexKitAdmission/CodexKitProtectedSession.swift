import Foundation
import Crypto

/// A private Composer transport contract; it is not an OAuth issuer or a
/// credential enrollment mechanism. Material is injected ONLY after the
/// trusted host's independently verified owner decision.
public enum CodexKitProtectedSessionError: Error, Equatable, Sendable {
    case invalidMaterial
    case invalidBinding
    case expired
    case staleOrReplayed
    case oversized
    case authenticationFailed
    case wrongOperation
}

public struct CodexKitProtectedBinding: Codable, Equatable, Sendable {
    public static let instrument = "fountaincoach.codexkit@0.1.0"
    public static let scope = "codex/turn.submit"

    public let sessionID: String
    public let instrumentID: String
    public let expiresAtSeconds: Int64

    public init(sessionID: String, instrumentID: String, expiresAtSeconds: Int64) throws {
        guard !sessionID.isEmpty, sessionID.utf8.count <= 128,
              sessionID.utf8.allSatisfy({ ($0 >= 48 && $0 <= 57) ||
                  ($0 >= 65 && $0 <= 90) || ($0 >= 97 && $0 <= 122) ||
                  $0 == 45 || $0 == 95 }),
              instrumentID == Self.instrument,
              expiresAtSeconds > 0 else {
            throw CodexKitProtectedSessionError.invalidBinding
        }
        self.sessionID = sessionID
        self.instrumentID = instrumentID
        self.expiresAtSeconds = expiresAtSeconds
    }
}

public enum CodexKitProtectedDirection: String, Codable, Sendable {
    case writerToHost
    case hostToWriter
}

/// Public routing metadata only. Writer text and model responses are never
/// placed in the unencrypted MIDI2 envelope.
public struct CodexKitProtectedPacket: Codable, Equatable, Sendable {
    public let version: Int
    public let sessionID: String
    public let correlationID: String
    public let executionID: String
    public let sequence: UInt64
    public let direction: CodexKitProtectedDirection
    public let sealedBody: Data
}

/// The only admitted first-session operation. No book or file writes, and no
/// arbitrary Codex app-server commands through this restricted transport.
public struct CodexKitPrivateComposerTurn: Codable, Equatable, Sendable {
    public let operation: String
    public let instrumentID: String
    public let text: String

    public init(text: String) throws {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              text.utf8.count <= 32_768 else {
            throw CodexKitProtectedSessionError.oversized
        }
        self.operation = CodexKitProtectedBinding.scope
        self.instrumentID = CodexKitProtectedBinding.instrument
        self.text = text
    }

    public func validated() throws {
        guard operation == CodexKitProtectedBinding.scope,
              instrumentID == CodexKitProtectedBinding.instrument else {
            throw CodexKitProtectedSessionError.wrongOperation
        }
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              text.utf8.count <= 32_768 else {
            throw CodexKitProtectedSessionError.oversized
        }
    }
}

/// One actor per independently owner-approved key and session binding.
/// This actor never *creates* an approval, pairing, or provider grant.
/// Its secret must be supplied from the approved local host/Keychain boundary.
/// Both directions use separately derived keys to prevent cross-direction
/// reflection. AEAD authenticates version/session/operation routing metadata.
public actor CodexKitSealedSession {
    private let binding: CodexKitProtectedBinding
    private let outboundKey: SymmetricKey
    private let inboundKey: SymmetricKey
    private let outboundDirection: CodexKitProtectedDirection
    private var nextSequence: UInt64 = 1
    private var lastReceivedSequence: UInt64 = 0
    private var invalidated = false

    public init(
        independentlyApprovedSecret: Data,
        binding: CodexKitProtectedBinding,
        localDirection: CodexKitProtectedDirection
    ) throws {
        guard independentlyApprovedSecret.count == 32 else {
            throw CodexKitProtectedSessionError.invalidMaterial
        }
        self.binding = binding
        self.outboundDirection = localDirection
        // Domain-separated HKDF prevents using the same AEAD key in both directions.
        let master = SymmetricKey(data: independentlyApprovedSecret)
        let salt = Data(("FountainCoach.CodexKit.R38." + binding.sessionID).utf8)
        func derive(_ direction: CodexKitProtectedDirection) -> SymmetricKey {
            HKDF<SHA256>.deriveKey(
                inputKeyMaterial: master, salt: salt,
                info: Data((binding.instrumentID + "." + direction.rawValue).utf8),
                outputByteCount: 32)
        }
        outboundKey = derive(localDirection)
        inboundKey = derive(localDirection == .writerToHost ? .hostToWriter : .writerToHost)
    }

    public func invalidate() { invalidated = true }

    public func seal(
        _ plaintext: Data, correlationID: String, executionID: String,
        now: Date = Date()
    ) throws -> CodexKitProtectedPacket {
        try requireValid(now: now)
        guard !plaintext.isEmpty, plaintext.count <= 40_960,
              validID(correlationID), validID(executionID),
              nextSequence != UInt64.max else {
            throw CodexKitProtectedSessionError.oversized
        }
        let sequence = nextSequence
        let aad = try associatedData(
            sessionID: binding.sessionID, correlationID: correlationID,
            executionID: executionID, sequence: sequence,
            direction: outboundDirection)
        let sealed = try AES.GCM.seal(plaintext, using: outboundKey, authenticating: aad)
        guard let combined = sealed.combined else {
            throw CodexKitProtectedSessionError.authenticationFailed
        }
        nextSequence += 1
        return .init(version: 1, sessionID: binding.sessionID,
                     correlationID: correlationID, executionID: executionID,
                     sequence: sequence, direction: outboundDirection,
                     sealedBody: combined)
    }

    public func open(_ packet: CodexKitProtectedPacket, now: Date = Date()) throws -> Data {
        try requireValid(now: now)
        guard packet.version == 1, packet.sessionID == binding.sessionID,
              packet.direction != outboundDirection,
              validID(packet.correlationID), validID(packet.executionID) else {
            throw CodexKitProtectedSessionError.invalidBinding
        }
        guard packet.sealedBody.count >= 12 + 16,
              packet.sealedBody.count <= 41_000 else {
            throw CodexKitProtectedSessionError.oversized
        }
        guard packet.sequence > lastReceivedSequence else {
            throw CodexKitProtectedSessionError.staleOrReplayed
        }
        let aad = try associatedData(
            sessionID: packet.sessionID, correlationID: packet.correlationID,
            executionID: packet.executionID, sequence: packet.sequence,
            direction: packet.direction)
        do {
            let box = try AES.GCM.SealedBox(combined: packet.sealedBody)
            let data = try AES.GCM.open(box, using: inboundKey, authenticating: aad)
            guard !data.isEmpty, data.count <= 40_960 else {
                throw CodexKitProtectedSessionError.oversized
            }
            lastReceivedSequence = packet.sequence
            return data
        } catch let error as CodexKitProtectedSessionError {
            throw error
        } catch {
            throw CodexKitProtectedSessionError.authenticationFailed
        }
    }

    /// Checks the decrypted request's operation, never caller-supplied
    /// plaintext fields from a public RTP-MIDI2 envelope.
    public func openComposerTurn(
        _ packet: CodexKitProtectedPacket, now: Date = Date()
    ) throws -> CodexKitPrivateComposerTurn {
        guard outboundDirection == .hostToWriter else {
            throw CodexKitProtectedSessionError.invalidBinding
        }
        let data = try open(packet, now: now)
        guard let turn = try? JSONDecoder().decode(CodexKitPrivateComposerTurn.self, from: data) else {
            throw CodexKitProtectedSessionError.wrongOperation
        }
        try turn.validated()
        return turn
    }

    private func requireValid(now: Date) throws {
        guard !invalidated, now.timeIntervalSince1970 < Double(binding.expiresAtSeconds) else {
            throw CodexKitProtectedSessionError.expired
        }
    }

    private func validID(_ value: String) -> Bool {
        !value.isEmpty && value.utf8.count <= 128 &&
        value.utf8.allSatisfy { ($0 >= 48 && $0 <= 57) ||
            ($0 >= 65 && $0 <= 90) || ($0 >= 97 && $0 <= 122) ||
            $0 == 45 || $0 == 95 }
    }

    private func associatedData(
        sessionID: String, correlationID: String, executionID: String,
        sequence: UInt64, direction: CodexKitProtectedDirection
    ) throws -> Data {
        guard validID(sessionID), validID(correlationID), validID(executionID) else {
            throw CodexKitProtectedSessionError.invalidBinding
        }
        return Data(
            "codexkit-r38-v1|\(binding.instrumentID)|\(binding.expiresAtSeconds)|\(sessionID)|\(correlationID)|\(executionID)|\(sequence)|\(direction.rawValue)"
                .utf8)
    }
}
