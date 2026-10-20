import Foundation
import XCTest
@testable import CodexKitAdmission

final class CodexKitPairingTranscriptTests: XCTestCase {
    private let start = Date(timeIntervalSince1970: 1_800_000_000)

    func testTwoEphemeralPeersAgreeAndEncryptionInteroperatesButApprovalIsNotInferred() async throws {
        let host = try CodexKitPairingHost(
            sessionID: "ipad-owner-001", expiresAtSeconds: 1_800_000_090, now: start)
        let offer = await host.currentOffer()
        let device = try CodexKitPairingDevice(offer: offer, now: start)
        let hostAgreement = try await host.receive(device.response, now: start)
        let deviceAgreement = try device.agreement(now: start)
        XCTAssertEqual(hostAgreement.confirmationCode, deviceAgreement.confirmationCode)
        XCTAssertEqual(hostAgreement.confirmationCode.count, 8)
        XCTAssertEqual(hostAgreement.binding, deviceAgreement.binding)

        let writer = try deviceAgreement.withUnapprovedMaterial {
            try CodexKitSealedSession(independentlyApprovedSecret: $0,
                                      binding: deviceAgreement.binding,
                                      localDirection: .writerToHost)
        }
        let remote = try hostAgreement.withUnapprovedMaterial {
            try CodexKitSealedSession(independentlyApprovedSecret: $0,
                                      binding: hostAgreement.binding,
                                      localDirection: .hostToWriter)
        }
        let turn = try CodexKitPrivateComposerTurn(text: "Only after actual owner approval")
        let request = try await writer.seal(JSONEncoder().encode(turn),
                                             correlationID: "corr-1", executionID: "exec-1",
                                             now: start)
        let readback = try await remote.openComposerTurn(request, now: start)
        XCTAssertEqual(turn, readback)
        // This unit proof is deliberately cryptographic only. A real runtime
        // must NOT construct or expose remote until OS-local owner approval.
    }

    func testOneHostOfferCannotBeUsedTwice() async throws {
        let host = try CodexKitPairingHost(
            sessionID: "ipad-owner-002", expiresAtSeconds: 1_800_000_090, now: start)
        let offer = await host.currentOffer()
        let device = try CodexKitPairingDevice(offer: offer, now: start)
        _ = try await host.receive(device.response, now: start)
        do {
            _ = try await host.receive(device.response, now: start)
            XCTFail("Host challenge must be one-use")
        } catch let error as CodexKitPairingError {
            XCTAssertEqual(error, .alreadyCompleted)
        }
    }

    func testExpiredAndForgedHostOfferRefuse() async throws {
        let host = try CodexKitPairingHost(
            sessionID: "ipad-owner-003", expiresAtSeconds: 1_800_000_020, now: start)
        let offer = await host.currentOffer()
        XCTAssertThrowsError(try CodexKitPairingDevice(
            offer: offer, now: Date(timeIntervalSince1970: 1_800_000_020)))
        let device = try CodexKitPairingDevice(offer: offer, now: start)
        let bad = CodexKitPairingResponse(
            protocolVersion: 1, sessionID: device.response.sessionID,
            devicePublicKey: device.response.devicePublicKey, nonce: "forgedNonce")
        do {
            _ = try await host.receive(bad, now: start)
            XCTFail("Changing challenge must fail closed")
        } catch let error as CodexKitPairingError {
            XCTAssertEqual(error, .mismatchedOffer)
        }
        do {
            _ = try await host.receive(device.response, now: start)
            XCTFail("Rejected attempt must consume host pairing")
        } catch let error as CodexKitPairingError {
            XCTAssertEqual(error, .alreadyCompleted)
        }
    }

    func testEachPairingHasIndependentRandomKey() async throws {
        let a = try CodexKitPairingHost(sessionID: "same-session",
                                       expiresAtSeconds: 1_800_000_090, now: start)
        let b = try CodexKitPairingHost(sessionID: "same-session",
                                       expiresAtSeconds: 1_800_000_090, now: start)
        let ao = await a.currentOffer()
        let bo = await b.currentOffer()
        XCTAssertNotEqual(ao.hostPublicKey, bo.hostPublicKey)
        XCTAssertNotEqual(ao.nonce, bo.nonce)
    }
}
