import Foundation
import XCTest
import Crypto
@testable import CodexKitAdmission

final class R38PeerSignedPairingTests: XCTestCase {
    func testExistingDeviceIdentityProducesStablePublicKeyWithoutDisclosingSecret() throws {
        let provisioned = Data(repeating: 0x42, count: 32)
        let different = Data(repeating: 0x43, count: 32)
        let first = try R38PeerSignedPairing.devicePublicKey(provisionedIdentity: provisioned)
        let again = try R38PeerSignedPairing.devicePublicKey(provisionedIdentity: provisioned)
        let stranger = try R38PeerSignedPairing.devicePublicKey(provisionedIdentity: different)
        XCTAssertEqual(first.count, 32)
        XCTAssertEqual(first, again)
        XCTAssertNotEqual(first, provisioned)
        XCTAssertNotEqual(first, stranger)
        XCTAssertThrowsError(try R38PeerSignedPairing.devicePublicKey(provisionedIdentity: Data()))
    }

    func testExactHostAndDevicePublicKeysBindBothEphemeralPeers() async throws {
        let at = Date(timeIntervalSince1970: 1_800_000_000)
        let host = try CodexKitPairingHost(
            sessionID: UUID().uuidString, expiresAtSeconds: 1_800_000_115, now: at)
        let offer = await host.currentOffer()
        let device = try CodexKitPairingDevice(offer: offer, now: at)
        let hostSigningKey = Curve25519.Signing.PrivateKey()
        let otherHost = Curve25519.Signing.PrivateKey()
        let provisioned = Data(repeating: 0xA7, count: 32)
        let deviceSigningKey = try R38PeerSignedPairing.deviceSigningKey(
            provisionedIdentity: provisioned)
        let devicePublicKey = deviceSigningKey.publicKey.rawRepresentation

        let offerProof = try R38PeerSignedPairing.hostOfferProof(
            hostSigningKey: hostSigningKey, offer: offer)
        XCTAssertTrue(R38PeerSignedPairing.verifiesHostOffer(
            trustedHostPublicKey: hostSigningKey.publicKey.rawRepresentation,
            offer: offer, proof: offerProof))
        let seededOfferProof = try R38PeerSignedPairing.hostOfferProof(
            hostSigningSeed: hostSigningKey.rawRepresentation, offer: offer)
        XCTAssertEqual(seededOfferProof, offerProof)
        XCTAssertThrowsError(try R38PeerSignedPairing.hostOfferProof(
            hostSigningSeed: Data(), offer: offer))
        XCTAssertFalse(R38PeerSignedPairing.verifiesHostOffer(
            trustedHostPublicKey: otherHost.publicKey.rawRepresentation,
            offer: offer, proof: offerProof))
        XCTAssertFalse(R38PeerSignedPairing.verifiesHostOffer(
            trustedHostPublicKey: Data(), offer: offer, proof: offerProof))
        XCTAssertFalse(R38PeerSignedPairing.verifiesHostOffer(
            trustedHostPublicKey: hostSigningKey.publicKey.rawRepresentation,
            offer: offer, proof: "not-a-signature"))

        let response = device.response
        let responseProof = try R38PeerSignedPairing.deviceResponseProof(
            deviceSigningKey: deviceSigningKey, offer: offer, response: response)
        XCTAssertTrue(R38PeerSignedPairing.verifiesDeviceResponse(
            trustedDevicePublicKey: devicePublicKey, offer: offer,
            response: response, proof: responseProof))
        XCTAssertFalse(R38PeerSignedPairing.verifiesDeviceResponse(
            trustedDevicePublicKey: hostSigningKey.publicKey.rawRepresentation,
            offer: offer, response: response, proof: responseProof))
        XCTAssertFalse(R38PeerSignedPairing.verifiesDeviceResponse(
            trustedDevicePublicKey: devicePublicKey,
            offer: offer, response: response, proof: offerProof))
        let modified = CodexKitPairingResponse(
            protocolVersion: response.protocolVersion,
            sessionID: response.sessionID,
            devicePublicKey: response.devicePublicKey, nonce: "modified")
        XCTAssertFalse(R38PeerSignedPairing.verifiesDeviceResponse(
            trustedDevicePublicKey: devicePublicKey,
            offer: offer, response: modified, proof: responseProof))
        let alteredOffer = CodexKitPairingOffer(
            protocolVersion: offer.protocolVersion, binding: offer.binding,
            hostPublicKey: offer.hostPublicKey, nonce: "modified")
        XCTAssertFalse(R38PeerSignedPairing.verifiesHostOffer(
            trustedHostPublicKey: hostSigningKey.publicKey.rawRepresentation,
            offer: alteredOffer, proof: offerProof))
        XCTAssertFalse(R38PeerSignedPairing.verifiesDeviceResponse(
            trustedDevicePublicKey: devicePublicKey,
            offer: alteredOffer, response: response, proof: responseProof))
    }
}
