import Foundation
import CodexKitAdmission
#if os(Linux)
import Glibc

/// The one physical-iPad proof uses the existing authenticated Codex app-server
/// and MIDI2 instrument. It creates no public identity issuer and no manuscript
/// grant. A root-owned *local* approval file is an out-of-band owner witness,
/// never an untrusted MIDI2 payload.
@MainActor
final class R38PrivateComposerHost {
    private struct Pending {
        let host: CodexKitPairingHost
        let expires: Int64
        var agreement: CodexKitUnapprovedAgreement?
    }
    private var pending: [String: Pending] = [:]
    private var active: [String: CodexKitSealedSession] = [:]
    private let parent = "/run/fountaincoach/r38-codexkit-pairing"

    func begin(sessionID: String) async throws -> CodexKitPairingOffer {
        guard UUID(uuidString: sessionID) != nil else { throw Failure.invalidRequest }
        pending = pending.filter { $0.value.expires > Int64(Date().timeIntervalSince1970) }
        guard pending.count < 4, pending[sessionID] == nil, active[sessionID] == nil else {
            throw Failure.refused
        }
        let expiry = Int64(Date().timeIntervalSince1970) + 119
        let host = try CodexKitPairingHost(sessionID: sessionID, expiresAtSeconds: expiry)
        let offer = await host.currentOffer()
        pending[sessionID] = Pending(host: host, expires: expiry, agreement: nil)
        return offer
    }

    func finish(_ response: CodexKitPairingResponse) async throws {
        guard var state = pending[response.sessionID], state.agreement == nil else {
            throw Failure.refused
        }
        // Consume before validating; malformed responses must not be retried.
        pending.removeValue(forKey: response.sessionID)
        let agreement = try await state.host.receive(response)
        state.agreement = agreement
        try initializeRootOnlyDirectory()
        let pendingFile = parent + "/pending/" + response.sessionID
        try writeRootOnlyFile(agreement.confirmationCode + "\n", to: pendingFile)
        pending[response.sessionID] = state
    }

    func status(sessionID: String) throws -> Bool {
        if active[sessionID] != nil { return true }
        guard let state = pending[sessionID], let agreement = state.agreement,
              state.expires > Int64(Date().timeIntervalSince1970) else {
            throw Failure.refused
        }
        let approval = parent + "/approved/" + sessionID
        guard FileManager.default.fileExists(atPath: approval) else { return false }
        defer { try? FileManager.default.removeItem(atPath: approval) }
        guard isTrustedLocalFile(approval),
              let text = try? String(contentsOfFile: approval, encoding: .utf8),
              text.trimmingCharacters(in: .whitespacesAndNewlines) == agreement.confirmationCode else {
            throw Failure.refused
        }
        let privateSession = try agreement.withUnapprovedMaterial {
            try CodexKitSealedSession(independentlyApprovedSecret: $0,
                                      binding: agreement.binding,
                                      localDirection: .hostToWriter)
        }
        active[sessionID] = privateSession
        pending.removeValue(forKey: sessionID)
        // Pending operator code must be destroyed after activation.
        try? FileManager.default.removeItem(atPath: parent + "/pending/" + sessionID)
        return true
    }

    func execute(
        packet: CodexKitProtectedPacket,
        runtime: CodexKitRuntime,
        request: WireEnvelope
    ) async throws -> CodexKitProtectedPacket {
        guard try status(sessionID: packet.sessionID),
              let key = active[packet.sessionID],
              request.sessionId == packet.sessionID,
              request.correlationId == packet.correlationID,
              request.payload["executionId"] == packet.executionID else {
            throw Failure.refused
        }
        let turn = try await key.openComposerTurn(packet)
        // Construct an internal typed request from verified ciphertext.
        // No caller-supplied external Codex operation or prompt is trusted.
        let admitted = WireEnvelope(
            topic: "reframe/capability.invoke", schemaVersion: "reframe-midi2/1",
            correlationId: packet.correlationID,
            timestamp: UInt64(Date().timeIntervalSince1970 * 1_000_000_000),
            qos: "reliable", sessionId: packet.sessionID,
            capabilityMask: 0, resumeToken: nil, ttlMs: 119_000,
            payload: ["instrumentId": CodexKitProtectedBinding.instrument,
                      "operation": turn.operation, "prompt": turn.text,
                      "executionId": packet.executionID],
            arguments: nil)
        let result = try await runtime.execute(admitted)
        guard result.phase == "succeeded", !result.summary.isEmpty else {
            throw Failure.upstreamFailed
        }
        let reply = CodexKitPrivateComposerReply(
            text: result.summary, threadID: result.threadID, turnID: result.turnID)
        return try await key.seal(JSONEncoder().encode(reply),
                                  correlationID: packet.correlationID,
                                  executionID: packet.executionID)
    }

    func revoke(sessionID: String) async {
        if let key = active.removeValue(forKey: sessionID) { await key.invalidate() }
        pending.removeValue(forKey: sessionID)
        try? FileManager.default.removeItem(atPath: parent + "/pending/" + sessionID)
        try? FileManager.default.removeItem(atPath: parent + "/approved/" + sessionID)
    }

    enum Failure: Error { case invalidRequest, refused, upstreamFailed, untrustedLocalFile }

    private func initializeRootOnlyDirectory() throws {
        // Operates under the existing root-owned CodexKit service identity.
        for directory in ["/run/fountaincoach", parent, parent + "/pending", parent + "/approved"] {
            try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: false)
            if chmod(directory, mode_t(0o700)) != 0 { throw Failure.untrustedLocalFile }
            var statBuffer = stat()
            guard lstat(directory, &statBuffer) == 0, statBuffer.st_uid == 0,
                  (statBuffer.st_mode & mode_t(S_IFMT)) == mode_t(S_IFDIR) else {
                throw Failure.untrustedLocalFile
            }
        }
    }

    private func writeRootOnlyFile(_ value: String, to path: String) throws {
        let fd = open(path, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW, mode_t(0o600))
        guard fd >= 0 else { throw Failure.untrustedLocalFile }
        defer { _ = close(fd) }
        let bytes = Array(value.utf8)
        let result = bytes.withUnsafeBytes { ptr -> Int in
            write(fd, ptr.baseAddress, ptr.count)
        }
        guard result == bytes.count else {
            try? FileManager.default.removeItem(atPath: path)
            throw Failure.untrustedLocalFile
        }
    }

    private func isTrustedLocalFile(_ path: String) -> Bool {
        var info = stat()
        guard lstat(path, &info) == 0 else { return false }
        return info.st_uid == 0
            && (info.st_mode & mode_t(S_IFMT)) == mode_t(S_IFREG)
            && (info.st_mode & mode_t(0o077)) == 0
            && info.st_size > 0 && info.st_size <= 16
    }
}
#endif
