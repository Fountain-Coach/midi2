import Foundation
import Crypto

/// A short-lived, development-provisioned iPad/Ubuntu pairing contract.
/// The Mac prepares a unique key in the signed iPad app and the managed host.
/// Proofs authenticate the ephemeral key exchange, never manuscript access.
public enum R38ProvisionedDevice {
    public enum Failure: Error { case invalidKey, invalidProof }

    public static func offerProof(key: Data, offer: CodexKitPairingOffer) throws -> String {
        try sign(key: key, label: "offer", data: canonical(offer))
    }

    public static func responseProof(key: Data, offer: CodexKitPairingOffer,
                                     response: CodexKitPairingResponse) throws -> String {
        struct Transcript: Encodable {
            let offer: CodexKitPairingOffer
            let response: CodexKitPairingResponse
        }
        return try sign(key: key, label: "response",
                        data: canonical(Transcript(offer: offer, response: response)))
    }

    public static func verifiesOffer(key: Data, offer: CodexKitPairingOffer, proof: String) -> Bool {
        guard let correct = try? offerProof(key: key, offer: offer) else { return false }
        return matches(correct, proof)
    }

    public static func verifiesResponse(key: Data, offer: CodexKitPairingOffer,
                                        response: CodexKitPairingResponse, proof: String) -> Bool {
        guard let correct = try? responseProof(key: key, offer: offer, response: response)
        else { return false }
        return matches(correct, proof)
    }

    private static func canonical<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }

    private static func sign(key: Data, label: String, data: Data) throws -> String {
        guard key.count == 32 else { throw Failure.invalidKey }
        let domain = Data(("fountain-r38-provision-v1|" + label + "|").utf8)
        return Data(HMAC<SHA256>.authenticationCode(
            for: domain + data, using: SymmetricKey(data: key))).base64EncodedString()
    }

    private static func matches(_ a: String, _ b: String) -> Bool {
        guard let lhs = Data(base64Encoded: a), let rhs = Data(base64Encoded: b),
              lhs.count == 32, rhs.count == 32 else { return false }
        var diff: UInt8 = 0
        for i in 0..<lhs.count { diff |= lhs[i] ^ rhs[i] }
        return diff == 0
    }
}
