/// Profile inquiry packets based on models from `midi2.full.openapi.json`.
public struct ProfileInquiryRequest: Codable {
    /// Identifier of the profile being queried.
    public var profile: String
    public init(profile: String) { self.profile = profile }
}

public struct ProfileInquiryResponse: Codable {
    /// Indicates whether the responder supports the requested profile.
    public var supported: Bool
    public init(supported: Bool) { self.supported = supported }
}
