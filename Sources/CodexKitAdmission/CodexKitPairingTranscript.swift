import Foundation
import Crypto

/// R38 ephemeral key agreement for two peers that are not yet trusted.
/// This is NOT enrollment, owner approval, an access token, or authorization.
/// The independently trusted host operator must compare the displayed
/// short authentication strings and approve via OS-verified local authority
/// before either peer may construct an admitted CodexKitSealedSession.
public enum CodexKitPairingError: Error, Equatable, Sendable {
    case malformedOffer
    case mismatchedOffer
    case expired
    case alreadyCompleted
    case invalidPeerKey
}

public struct CodexKitPairingOffer: Codable, Equatable, Sendable {
    public let protocolVersion: Int
    public let binding: CodexKitProtectedBinding
    /// Base64url-encoded 32-byte Curve25519 public key.
    public let hostPublicKey: String
    /// Base64url-encoded cryptographically random 16-byte challenge.
    public let nonce: String
}

public struct CodexKitPairingResponse: Codable, Equatable, Sendable {
    public let protocolVersion: Int
    public let sessionID: String
    public let devicePublicKey: String
    public let nonce: String
}

/// Unapproved, private transcript material. Never persist or log it.
/// The resolved short code must be compared via a trusted local operator.
/// A matching code alone never changes authority state.
public struct CodexKitUnapprovedAgreement: Sendable {
    public let confirmationCode: String
    public let binding: CodexKitProtectedBinding
    private let material: Data

    init(confirmationCode: String, binding: CodexKitProtectedBinding, material: Data) {
        self.confirmationCode = confirmationCode
        self.binding = binding
        self.material = material
    }

    /// The trusted host's owner-admission layer, NOT MIDI2, controls whether
    /// a pending agreement can be handed to the private session transport.
    /// This is intentionally not a public authorization API.
    public func withUnapprovedMaterial<T>(
        _ use: (Data) throws -> T
    ) rethrows -> T {
        try use(material)
    }
}

public actor CodexKitPairingHost {
    private let privateKey: Curve25519.KeyAgreement.PrivateKey
    private let offer: CodexKitPairingOffer
    private var consumed = false

    public init(sessionID: String, expiresAtSeconds: Int64, now: Date = Date()) throws {
        guard Double(expiresAtSeconds) > now.timeIntervalSince1970,
              Double(expiresAtSeconds) - now.timeIntervalSince1970 <= 120 else {
            throw CodexKitPairingError.expired
        }
        let binding = try CodexKitProtectedBinding(
            sessionID: sessionID,
            instrumentID: CodexKitProtectedBinding.instrument,
            expiresAtSeconds: expiresAtSeconds)
        let key = Curve25519.KeyAgreement.PrivateKey()
        privateKey = key
        var generator = SystemRandomNumberGenerator()
        let nonce = Data((0..<16).map { _ in UInt8.random(in: .min ... .max, using: &generator) })
        offer = CodexKitPairingOffer(
            protocolVersion: 1, binding: binding,
            hostPublicKey: Self.encode(key.publicKey.rawRepresentation),
            nonce: Self.encode(nonce))
    }

    public func currentOffer() -> CodexKitPairingOffer { offer }

    /// Consumes the exact pending host offer once, even when malformed.
    /// Untrusted device assertions never issue authorization.
    public func receive(
        _ response: CodexKitPairingResponse, now: Date = Date()
    ) throws -> CodexKitUnapprovedAgreement {
        guard !consumed else { throw CodexKitPairingError.alreadyCompleted }
        consumed = true
        guard now.timeIntervalSince1970 < Double(offer.binding.expiresAtSeconds) else {
            throw CodexKitPairingError.expired
        }
        guard response.protocolVersion == 1,
              response.sessionID == offer.binding.sessionID,
              response.nonce == offer.nonce else { throw CodexKitPairingError.mismatchedOffer }
        guard let bytes = Self.decode(response.devicePublicKey), bytes.count == 32,
              let publicKey = try? Curve25519.KeyAgreement.PublicKey(rawRepresentation: bytes) else {
            throw CodexKitPairingError.invalidPeerKey
        }
        return try Self.derive(privateKey: privateKey, otherPublic: publicKey,
                               offer: offer, response: response)
    }

    fileprivate static func derive(
        privateKey: Curve25519.KeyAgreement.PrivateKey,
        otherPublic: Curve25519.KeyAgreement.PublicKey,
        offer: CodexKitPairingOffer,
        response: CodexKitPairingResponse
    ) throws -> CodexKitUnapprovedAgreement {
        let shared = try privateKey.sharedSecretFromKeyAgreement(with: otherPublic)
        let transcript = Data((
            "fountaincoach-r38-pairing-v1|" +
            offer.binding.instrumentID + "|" +
            offer.binding.sessionID + "|" +
            String(offer.binding.expiresAtSeconds) + "|" +
            offer.hostPublicKey + "|" +
            response.devicePublicKey + "|" + offer.nonce
        ).utf8)
        let salt = Data(SHA256.hash(data: transcript))
        let material = shared.hkdfDerivedSymmetricKey(
            using: SHA256.self, salt: salt,
            sharedInfo: Data("codexkit-private-composer-session-v1".utf8),
            outputByteCount: 32)
        let codeKey = shared.hkdfDerivedSymmetricKey(
            using: SHA256.self, salt: salt,
            sharedInfo: Data("codexkit-human-verification-v1".utf8),
            outputByteCount: 32)
        let codeDigest = HMAC<SHA256>.authenticationCode(for: transcript, using: codeKey)
        let prefix = codeDigest.prefix(4).reduce(UInt32(0)) { ($0 << 8) | UInt32($1) }
        let code = String(format: "%08d", prefix % 100_000_000)
        return CodexKitUnapprovedAgreement(
            confirmationCode: code, binding: offer.binding,
            material: material.withUnsafeBytes { Data($0) })
    }

    fileprivate static func encode(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    fileprivate static func decode(_ text: String) -> Data? {
        guard !text.isEmpty,
              text.utf8.allSatisfy({ ($0 >= 65 && $0 <= 90) ||
                  ($0 >= 97 && $0 <= 122) ||
                  ($0 >= 48 && $0 <= 57) || $0 == 45 || $0 == 95 }) else {
            return nil
        }
        let encoded = text.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = encoded + String(repeating: "=", count: (4 - encoded.count % 4) % 4)
        guard let data = Data(base64Encoded: padded),
              encode(data) == text else { return nil }
        return data
    }
}

public struct CodexKitPairingDevice: Sendable {
    private let privateKey: Curve25519.KeyAgreement.PrivateKey
    public let response: CodexKitPairingResponse
    private let offer: CodexKitPairingOffer

    public init(offer: CodexKitPairingOffer, now: Date = Date()) throws {
        guard offer.protocolVersion == 1,
              offer.binding.instrumentID == CodexKitProtectedBinding.instrument,
              !offer.binding.sessionID.isEmpty,
              Double(offer.binding.expiresAtSeconds) > now.timeIntervalSince1970,
              Double(offer.binding.expiresAtSeconds) - now.timeIntervalSince1970 <= 120,
              let key = CodexKitPairingHost.decode(offer.hostPublicKey), key.count == 32,
              (try? Curve25519.KeyAgreement.PublicKey(rawRepresentation: key)) != nil,
              let nonce = CodexKitPairingHost.decode(offer.nonce), nonce.count == 16 else {
            throw CodexKitPairingError.malformedOffer
        }
        let local = Curve25519.KeyAgreement.PrivateKey()
        privateKey = local
        response = CodexKitPairingResponse(
            protocolVersion: 1, sessionID: offer.binding.sessionID,
            devicePublicKey: CodexKitPairingHost.encode(local.publicKey.rawRepresentation),
            nonce: offer.nonce)
        self.offer = offer
    }

    public func agreement(now: Date = Date()) throws -> CodexKitUnapprovedAgreement {
        guard now.timeIntervalSince1970 < Double(offer.binding.expiresAtSeconds) else {
            throw CodexKitPairingError.expired
        }
        guard let key = CodexKitPairingHost.decode(offer.hostPublicKey),
              let publicKey = try? Curve25519.KeyAgreement.PublicKey(rawRepresentation: key) else {
            throw CodexKitPairingError.invalidPeerKey
        }
        return try CodexKitPairingHost.derive(
            privateKey: privateKey, otherPublic: publicKey,
            offer: offer, response: response)
    }
}
