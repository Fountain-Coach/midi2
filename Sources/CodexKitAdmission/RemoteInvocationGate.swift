import Foundation

/// An authenticated Codex app-server process does not authenticate the
/// remote RTP-MIDI2 peer. MIDI-CI discovery is public; execution is not.
///
/// This source revision intentionally admits NO remote execution until the
/// owning host provides a cryptographically verified owner/session binding.
/// The follow-up must replace this closed gate with a verifier that checks
/// peer identity, writer intent, exact instrument/capability, expiry, nonce,
/// replay and revocation before an app-server request is made.
public enum CodexKitRemoteInvocationGate {
    public static let instrumentID = "fountaincoach.codexkit@0.1.0"
    public static let publicDiscoveryTopic = "reframe/capability.discover"
    public static let invocationTopic = "reframe/capability.invoke"

    public enum Decision: Equatable, Sendable {
        case allowDiscovery
        case refuseExecution
        case ignore
    }

    /// Inputs are untrusted wire data, not a verified host or writer identity.
    /// No amount of caller-supplied session/correlation metadata promotes it.
    public static func decide(topic: String, instrumentID: String?, operation: String?) -> Decision {
        guard topic == publicDiscoveryTopic || topic == invocationTopic else { return .ignore }
        if topic == publicDiscoveryTopic { return .allowDiscovery }
        guard instrumentID == Self.instrumentID, operation?.isEmpty == false else { return .ignore }
        return .refuseExecution
    }
}
