/// Protocol negotiation request/response models derived from `midi2.full.openapi.json`.
public enum MidiCIProtocol: UInt8, Codable, CaseIterable {
    case midi1 = 1
    case midi2 = 2
}

/// Request packet listing supported protocols.
public struct ProtocolNegotiationRequest: Codable {
    public var supportedProtocols: [MidiCIProtocol]
    public init(supportedProtocols: [MidiCIProtocol]) {
        self.supportedProtocols = supportedProtocols
    }
}

/// Response packet indicating the protocol accepted by the responder.
public struct ProtocolNegotiationResponse: Codable {
    public var acceptedProtocol: MidiCIProtocol?
    public init(acceptedProtocol: MidiCIProtocol?) {
        self.acceptedProtocol = acceptedProtocol
    }
}
