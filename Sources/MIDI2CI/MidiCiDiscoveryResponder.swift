import MIDI2

/// Provides the standard MIDI-CI Discovery response for a MIDI 2.0 instrument.
///
/// Transport adapters own packet I/O. This type owns the reusable protocol
/// boundary: when a Discovery envelope arrives, it returns the instrument's
/// advertised identity and supported MIDI-CI categories.
public struct MidiCiDiscoveryResponder: Equatable, Sendable {
    /// The instrument advertisement returned for every Discovery request.
    public let advertisement: MidiCiDiscoveryBody

    public init(advertisement: MidiCiDiscoveryBody) throws {
        try advertisement.validate()
        guard advertisement.muid != 0 else {
            throw MIDIError.malformedPacket("discovery responder MUID must be non-zero")
        }
        self.advertisement = advertisement
    }

    /// Respond to a parsed MIDI-CI envelope, or return `nil` for another CI
    /// operation that this responder does not own.
    public func respond(to request: MidiCiEnvelope) -> MidiCiEnvelope? {
        guard case .discovery = request.body else { return nil }
        return MidiCiEnvelope(
            scope: request.scope,
            subId2: 0x70,
            version: request.version,
            body: .discovery(advertisement)
        )
    }
}
