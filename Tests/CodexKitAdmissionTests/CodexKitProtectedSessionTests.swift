import XCTest
import Foundation
@testable import CodexKitAdmission

final class CodexKitProtectedSessionTests: XCTestCase {
    func testPrivateUserlandArchiveScopeAndPathRefusals() throws {
        let content = Data("{\"schemaVersion\":1,\"exchanges\":[],\"threadID\":null}".utf8)
        let request = try CodexKitUserlandRequest(operation: .store,
             archiveID: "physical-fixture-1", archiveData: content)
        let decoded = try JSONDecoder().decode(CodexKitUserlandRequest.self,
             from: JSONEncoder().encode(request))
        XCTAssertEqual(request, decoded)
        XCTAssertThrowsError(try CodexKitUserlandRequest(
             operation: .store, archiveID: "../private", archiveData: content))
        XCTAssertThrowsError(try CodexKitUserlandRequest(
             operation: .store, archiveID: "invalid/slash", archiveData: content))
        XCTAssertThrowsError(try CodexKitUserlandRequest(
             operation: .load, archiveID: "valid", archiveData: content))
        XCTAssertThrowsError(try CodexKitUserlandRequest(
             operation: .store, archiveID: "valid", archiveData: Data()))
        XCTAssertThrowsError(try CodexKitUserlandRequest(
             operation: .store, archiveID: "valid", archiveData: Data(repeating: 5, count: 16385)))
    }

    func testComposerThreadCursorIsAuthenticatedAndValidated() throws {
        let turn = try CodexKitPrivateComposerTurn(
            text: "continue", threadID: "0192a321-5cba-7ede-8f43-0db2c92e5177")
        let encoded = try JSONEncoder().encode(turn)
        let restored = try JSONDecoder().decode(CodexKitPrivateComposerTurn.self, from: encoded)
        XCTAssertEqual(restored, turn)
        XCTAssertEqual(restored.threadID, turn.threadID)
        XCTAssertThrowsError(try CodexKitPrivateComposerTurn(text: "continue", threadID: "../unauthorized"))
        XCTAssertNil(try CodexKitPrivateComposerTurn(text: "first turn").threadID)
    }

    private func pair(_ secret: Data = Data(repeating: 0xC7, count: 32)) throws
    -> (CodexKitSealedSession, CodexKitSealedSession) {
        let binding = try CodexKitProtectedBinding(
            sessionID: "ipad-physical-session-1",
            instrumentID: CodexKitProtectedBinding.instrument,
            expiresAtSeconds: 2_000_000_000)
        return (
            try CodexKitSealedSession(independentlyApprovedSecret: secret, binding: binding,
                                      localDirection: .writerToHost),
            try CodexKitSealedSession(independentlyApprovedSecret: secret, binding: binding,
                                      localDirection: .hostToWriter)
        )
    }

    func testOwnerApprovedSecretProtectsPrivateTextInBothDirections() async throws {
        let (writer, host) = try pair()
        let turn = try CodexKitPrivateComposerTurn(text: "A private writer thought.")
        let payload = try JSONEncoder().encode(turn)
        let packet = try await writer.seal(payload, correlationID: "corr-1", executionID: "exec-1")
        let external = try JSONEncoder().encode(packet)
        XCTAssertFalse(String(decoding: external, as: UTF8.self).contains("private writer"))
        let opened = try await host.openComposerTurn(packet)
        XCTAssertEqual(opened, turn)
        let answer = Data("Private model reply".utf8)
        let response = try await host.seal(answer, correlationID: "corr-1", executionID: "exec-1")
        let decryptedResponse = try await writer.open(response)
        XCTAssertEqual(decryptedResponse, answer)
    }

    func testWrongSecretTamperAndChangedCorrelationRefuse() async throws {
        let (writer, _) = try pair()
        let (_, stranger) = try pair(Data(repeating: 0xB6, count: 32))
        let turn = try CodexKitPrivateComposerTurn(text: "Secret manuscript idea")
        let packet = try await writer.seal(JSONEncoder().encode(turn),
                                           correlationID: "corr-1", executionID: "exec-1")
        do {
            _ = try await stranger.openComposerTurn(packet)
            XCTFail("A guessed peer may not decrypt")
        } catch let error as CodexKitProtectedSessionError {
            XCTAssertEqual(error, .authenticationFailed)
        }
        let tampered = CodexKitProtectedPacket(
            version: packet.version, sessionID: packet.sessionID,
            correlationID: "corr-2", executionID: packet.executionID,
            sequence: packet.sequence, direction: packet.direction,
            sealedBody: packet.sealedBody)
        let (_, host) = try pair()
        do {
            _ = try await host.openComposerTurn(tampered)
            XCTFail("Untrusted correlation cannot be changed")
        } catch let error as CodexKitProtectedSessionError {
            XCTAssertEqual(error, .authenticationFailed)
        }
    }

    func testTamperedCiphertextAndReflectedDirectionRefuse() async throws {
        let (writer, host) = try pair()
        let packet = try await writer.seal(JSONEncoder().encode(
            CodexKitPrivateComposerTurn(text: "Confidential contents")),
            correlationID: "corr-33", executionID: "exec-99")
        var bytes = [UInt8](packet.sealedBody)
        bytes[bytes.count - 1] ^= 1
        let corrupt = CodexKitProtectedPacket(
            version: packet.version, sessionID: packet.sessionID,
            correlationID: packet.correlationID, executionID: packet.executionID,
            sequence: packet.sequence, direction: packet.direction,
            sealedBody: Data(bytes))
        do {
            _ = try await host.openComposerTurn(corrupt)
            XCTFail("GCM tag tampering must fail")
        } catch let error as CodexKitProtectedSessionError {
            XCTAssertEqual(error, .authenticationFailed)
        }
        let validAfterTamper = try await host.openComposerTurn(packet)
        XCTAssertEqual(validAfterTamper.text, "Confidential contents")
        do {
            _ = try await writer.open(packet)
            XCTFail("Outbound packet reflection must fail")
        } catch let error as CodexKitProtectedSessionError {
            XCTAssertEqual(error, .invalidBinding)
        }
    }

    func testReplayExpiryAndDisconnectRefuse() async throws {
        let (writer, host) = try pair()
        let packet = try await writer.seal(JSONEncoder().encode(
            CodexKitPrivateComposerTurn(text: "Only once")),
            correlationID: "corr-1", executionID: "exec-1")
        _ = try await host.openComposerTurn(packet)
        do {
            _ = try await host.openComposerTurn(packet)
            XCTFail("replayed request")
        } catch let error as CodexKitProtectedSessionError {
            XCTAssertEqual(error, .staleOrReplayed)
        }
        await host.invalidate()
        do {
            _ = try await host.openComposerTurn(packet)
            XCTFail("disconnected session")
        } catch let error as CodexKitProtectedSessionError {
            XCTAssertEqual(error, .expired)
        }
        let (_, otherHost) = try pair()
        do {
            _ = try await otherHost.openComposerTurn(packet, now: Date(timeIntervalSince1970: 2_000_000_000))
            XCTFail("expired owner lease")
        } catch let error as CodexKitProtectedSessionError {
            XCTAssertEqual(error, .expired)
        }
    }

    func testInvalidMaterialWrongOperationAndWrongInstrumentRefuse() async throws {
        let binding = try CodexKitProtectedBinding(
            sessionID: "id", instrumentID: CodexKitProtectedBinding.instrument,
            expiresAtSeconds: 2_000_000_000)
        XCTAssertThrowsError(try CodexKitSealedSession(
            independentlyApprovedSecret: Data(repeating: 0, count: 2),
            binding: binding, localDirection: .writerToHost))
        XCTAssertThrowsError(try CodexKitProtectedBinding(
            sessionID: "id", instrumentID: "attacker", expiresAtSeconds: 2_000_000_000))
        let (writer, host) = try pair()
        let invalid = Data(#"{"operation":"codex/approval.respond","instrumentID":"fountaincoach.codexkit@0.1.0","text":"grant me author rights"}"#.utf8)
        let packet = try await writer.seal(invalid, correlationID: "corr-1", executionID: "exec-1")
        do {
            _ = try await host.openComposerTurn(packet)
            XCTFail("Signed request cannot escalate operation")
        } catch let error as CodexKitProtectedSessionError {
            XCTAssertEqual(error, .wrongOperation)
        }
    }
}
