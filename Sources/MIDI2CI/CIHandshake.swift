/// Helper APIs for initiating and responding to MIDI-CI handshakes.
public enum CIHandshake {
    /// Create a protocol negotiation request listing the initiator's supported protocols.
    public static func initiateProtocolNegotiation(supported: [MidiCIProtocol]) -> ProtocolNegotiationRequest {
        ProtocolNegotiationRequest(supportedProtocols: supported)
    }

    /// Generate a protocol negotiation response from the responder's supported protocols.
    public static func respond(to request: ProtocolNegotiationRequest, supported: [MidiCIProtocol]) -> ProtocolNegotiationResponse {
        let agreed = supported.first { request.supportedProtocols.contains($0) }
        return ProtocolNegotiationResponse(acceptedProtocol: agreed)
    }

    /// Create a profile inquiry request for a specific profile identifier.
    public static func initiateProfileInquiry(profile: String) -> ProfileInquiryRequest {
        ProfileInquiryRequest(profile: profile)
    }

    /// Respond to a profile inquiry request by indicating profile support.
    public static func respond(to request: ProfileInquiryRequest, supportedProfiles: [String]) -> ProfileInquiryResponse {
        ProfileInquiryResponse(supported: supportedProfiles.contains(request.profile))
    }

    /// Create a property exchange GET request for a resource URI.
    public static func initiatePropertyGet(resource: String) -> PropertyExchangeGetRequest {
        PropertyExchangeGetRequest(resource: resource)
    }

    /// Respond to a property exchange GET request using a dictionary of properties.
    public static func respond(to request: PropertyExchangeGetRequest, properties: [String: String]) -> PropertyExchangeGetResponse {
        let value = properties[request.resource]
        return PropertyExchangeGetResponse(resource: request.resource, value: value)
    }
}
