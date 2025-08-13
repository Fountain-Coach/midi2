/// Property exchange packets modelled after `midi2.full.openapi.json` definitions.
public struct PropertyExchangeGetRequest: Codable {
    /// URI of the property being requested.
    public var resource: String
    public init(resource: String) { self.resource = resource }
}

public struct PropertyExchangeGetResponse: Codable {
    /// URI of the property.
    public var resource: String
    /// Optional value returned by the responder.
    public var value: String?
    public init(resource: String, value: String?) {
        self.resource = resource
        self.value = value
    }
}
