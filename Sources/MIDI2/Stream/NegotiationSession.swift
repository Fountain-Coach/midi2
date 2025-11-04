/// Simple stateful stream negotiation session.
public final class StreamNegotiationSession {
    public struct Capabilities: Equatable {
        public var supportsMIDI2: Bool
        public var jrTx: Bool
        public var jrRx: Bool
        public init(supportsMIDI2: Bool = true, jrTx: Bool = true, jrRx: Bool = true) {
            self.supportsMIDI2 = supportsMIDI2
            self.jrTx = jrTx
            self.jrRx = jrRx
        }
    }

    public let responderCaps: Capabilities
    public private(set) var negotiated: StreamConfigurationMessage?

    public init(responderCaps: Capabilities) {
        self.responderCaps = responderCaps
    }

    /// Accept an Endpoint Discovery and return responder's discovery (echoing versions and max groups).
    public func onEndpointDiscovery(_ req: EndpointDiscoveryMessage) -> EndpointDiscoveryMessage {
        // For demo purposes, echo back same versions and maxGroups
        EndpointDiscoveryMessage(majorVersion: req.majorVersion, minorVersion: req.minorVersion, maxGroups: req.maxGroups)
    }

    /// Process a Stream Configuration request and return a notification reflecting negotiated settings.
    public func onStreamConfigRequest(_ req: StreamConfigurationMessage) -> StreamConfigurationMessage {
        var notif = StreamConfigurationMessage(isNotification: true, jrTimestampsTx: false, jrTimestampsRx: false, protocolSelection: .midi1)
        // Protocol negotiation
        notif.protocolSelection = responderCaps.supportsMIDI2 && (req.protocolSelection == .midi2) ? .midi2 : .midi1
        // JR flags intersection
        notif.jrTimestampsTx = responderCaps.jrTx && req.jrTimestampsTx
        notif.jrTimestampsRx = responderCaps.jrRx && req.jrTimestampsRx
        negotiated = notif
        return notif
    }
}

