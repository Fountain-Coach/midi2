import Foundation
import Crypto

/// Signature proofs for R38's existing ephemeral MIDI2 pairing transcript.
///
/// The existing iPad provisioned identity remains in its device-only Keychain.
/// Only a domain-separated signing PUBLIC key needs to be trusted by a
/// replacement host. A signing proof never grants model or manuscript access.
/// Trust-anchor installation is separately governed by host enrollment.
public enum R38PeerSignedPairing {
    public enum Failure: Error, Equatable { case invalidProvisionedIdentity }

    private static let domain = "fountain-r38-peer-signature-v1"
    private struct Transcript: Encodable {
        let offer: CodexKitPairingOffer
        let response: CodexKitPairingResponse
    }

    private static func message<T: Encodable>(_ value: T, role: String) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return Data((domain + "|" + role + "|").utf8) + (try encoder.encode(value))
    }

    private static func verifiedKey(_ data: Data) -> Curve25519.Signing.PublicKey? {
        guard data.count == 32 else { return nil }
        return try? Curve25519.Signing.PublicKey(rawRepresentation: data)
    }

    private static func verifiedProof(_ base64: String) -> Data? {
        guard let data = Data(base64Encoded: base64), data.count == 64,
              data.base64EncodedString() == base64 else { return nil }
        return data
    }

    /// Derive an independent signing seed. Neither the 32-byte existing
    /// identity nor the derived private signing seed is sent to the host.
    public static func deviceSigningKey(provisionedIdentity: Data) throws
        -> Curve25519.Signing.PrivateKey {
        guard provisionedIdentity.count == 32 else { throw Failure.invalidProvisionedIdentity }
        let seed = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: provisionedIdentity),
            salt: Data("fountain-r38-device-signing-salt-v1".utf8),
            info: Data("codexkit-pairing-ed25519-device-only-v1".utf8),
            outputByteCount: 32)
        let bytes = seed.withUnsafeBytes { Data($0) }
        return try Curve25519.Signing.PrivateKey(rawRepresentation: bytes)
    }

    public static func devicePublicKey(provisionedIdentity: Data) throws -> Data {
        try deviceSigningKey(provisionedIdentity: provisionedIdentity).publicKey.rawRepresentation
    }

    /// Host-local provisioned signing seed, never an RPC field or transcript.
    public static func hostOfferProof(
        hostSigningSeed: Data, offer: CodexKitPairingOffer
    ) throws -> String {
        guard hostSigningSeed.count == 32 else { throw Failure.invalidProvisionedIdentity }
        return try hostOfferProof(
            hostSigningKey: Curve25519.Signing.PrivateKey(rawRepresentation: hostSigningSeed),
            offer: offer)
    }

    public static func hostOfferProof(
        hostSigningKey: Curve25519.Signing.PrivateKey, offer: CodexKitPairingOffer
    ) throws -> String {
        try hostSigningKey.signature(for: message(offer, role: "host-offer")).base64EncodedString()
    }

    public static func verifiesHostOffer(
        trustedHostPublicKey: Data, offer: CodexKitPairingOffer, proof: String
    ) -> Bool {
        guard let key = verifiedKey(trustedHostPublicKey),
              let signature = verifiedProof(proof),
              let payload = try? message(offer, role: "host-offer") else { return false }
        return key.isValidSignature(signature, for: payload)
    }

    public static func deviceResponseProof(
        deviceSigningKey: Curve25519.Signing.PrivateKey,
        offer: CodexKitPairingOffer, response: CodexKitPairingResponse
    ) throws -> String {
        try deviceSigningKey.signature(
            for: message(Transcript(offer: offer, response: response), role: "device-response"))
            .base64EncodedString()
    }

    public static func verifiesDeviceResponse(
        trustedDevicePublicKey: Data, offer: CodexKitPairingOffer,
        response: CodexKitPairingResponse, proof: String
    ) -> Bool {
        guard let key = verifiedKey(trustedDevicePublicKey),
              let signature = verifiedProof(proof),
              let payload = try? message(
                Transcript(offer: offer, response: response), role: "device-response")
        else { return false }
        return key.isValidSignature(signature, for: payload)
    }
}
