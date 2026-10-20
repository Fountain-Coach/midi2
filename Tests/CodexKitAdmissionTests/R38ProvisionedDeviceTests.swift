import Foundation
import XCTest
@testable import CodexKitAdmission

final class R38ProvisionedDeviceTests: XCTestCase {
    func testProofBindsBothPeersAndTranscript() async throws {
        let when = Date(timeIntervalSince1970: 1_800_000_000)
        let host = try CodexKitPairingHost(
            sessionID: UUID().uuidString, expiresAtSeconds: 1_800_000_110, now: when)
        let offer = await host.currentOffer()
        let device = try CodexKitPairingDevice(offer: offer, now: when)
        let key = Data(repeating: 0x4A, count: 32)
        let stranger = Data(repeating: 0x61, count: 32)
        let proof = try R38ProvisionedDevice.offerProof(key: key, offer: offer)
        XCTAssertTrue(R38ProvisionedDevice.verifiesOffer(key: key, offer: offer, proof: proof))
        XCTAssertFalse(R38ProvisionedDevice.verifiesOffer(key: stranger, offer: offer, proof: proof))
        let response = device.response
        let signedResponse = try R38ProvisionedDevice.responseProof(
            key: key, offer: offer, response: response)
        XCTAssertTrue(R38ProvisionedDevice.verifiesResponse(
            key: key, offer: offer, response: response, proof: signedResponse))
        XCTAssertFalse(R38ProvisionedDevice.verifiesResponse(
            key: stranger, offer: offer, response: response, proof: signedResponse))
        let altered = CodexKitPairingResponse(
            protocolVersion: response.protocolVersion, sessionID: response.sessionID,
            devicePublicKey: response.devicePublicKey, nonce: "forged")
        XCTAssertFalse(R38ProvisionedDevice.verifiesResponse(
            key: key, offer: offer, response: altered, proof: signedResponse))
    }
}
