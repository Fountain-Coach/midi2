import Foundation
import CodexKitAdmission
#if os(Linux)
import Glibc

/// The existing trusted Mac provisions this iPad and managed Linux host.
/// A short-lived transcript must be authenticated by their provisioned key.
/// No login ceremony, public identity provider or manuscript permission.
@MainActor
final class R38PrivateComposerHost {
    private struct Pending {
        let host: CodexKitPairingHost
        let expires: Int64
    }
    private var pending: [String: Pending] = [:]
    private var active: [String: CodexKitSealedSession] = [:]
    private let deviceKeyPath = "/etc/fountaincoach/r38-provisioned-device.key"

    func begin(sessionID: String) async throws -> CodexKitPairingOffer {
        guard UUID(uuidString: sessionID) != nil else { throw Failure.invalidRequest }
        pending = pending.filter { $0.value.expires > Int64(Date().timeIntervalSince1970) }
        guard pending.count < 4, pending[sessionID] == nil, active[sessionID] == nil else {
            throw Failure.refused
        }
        let expiry = Int64(Date().timeIntervalSince1970) + 119
        let host = try CodexKitPairingHost(sessionID: sessionID, expiresAtSeconds: expiry)
        let offer = await host.currentOffer()
        pending[sessionID] = Pending(host: host, expires: expiry)
        return offer
    }

    func signedOffer(_ offer: CodexKitPairingOffer) throws -> String {
        try R38ProvisionedDevice.offerProof(key: deviceSecret(), offer: offer)
    }

    func finish(_ response: CodexKitPairingResponse, proof: String) async throws {
        guard let state = pending.removeValue(forKey: response.sessionID),
              state.expires > Int64(Date().timeIntervalSince1970) else {
            throw Failure.refused
        }
        let offer = await state.host.currentOffer()
        guard R38ProvisionedDevice.verifiesResponse(
            key: try deviceSecret(), offer: offer, response: response, proof: proof) else {
            throw Failure.refused
        }
        let agreement = try await state.host.receive(response)
        let admitted = try agreement.withUnapprovedMaterial {
            try CodexKitSealedSession(independentlyApprovedSecret: $0,
                                      binding: agreement.binding,
                                      localDirection: .hostToWriter)
        }
        active[response.sessionID] = admitted
    }

    func status(sessionID: String) throws -> Bool {
        active[sessionID] != nil
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
                      "threadId": turn.threadID ?? "",
                      "executionId": packet.executionID],
            arguments: nil)
        FileHandle.standardError.write(Data("r38.private.turn.admitted\n".utf8))
        let result = try await runtime.execute(admitted)
        FileHandle.standardError.write(Data("r38.private.turn.codex.completed bytes=\(result.summary.utf8.count)\n".utf8))
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
    }

    enum Failure: Error { case invalidRequest, refused, upstreamFailed, untrustedLocalFile }

    private func deviceSecret() throws -> Data {
        var info = stat()
        guard lstat(deviceKeyPath, &info) == 0,
              info.st_uid == 0,
              (info.st_mode & mode_t(S_IFMT)) == mode_t(S_IFREG),
              (info.st_mode & mode_t(0o077)) == 0,
              info.st_size >= 43, info.st_size <= 60,
              let text = try? String(contentsOfFile: deviceKeyPath, encoding: .utf8),
              let key = Data(base64Encoded: text.trimmingCharacters(in: .whitespacesAndNewlines)),
              key.count == 32 else { throw Failure.untrustedLocalFile }
        return key
    }
}
#endif
