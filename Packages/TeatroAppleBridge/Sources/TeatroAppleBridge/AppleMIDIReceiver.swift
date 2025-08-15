import Foundation

/// Receives UMP messages from Core MIDI inputs and forwards them to a handler.
///
/// This is a stub implementation that will be expanded with real Core MIDI
/// receive blocks on Apple platforms.
public final class AppleMIDIReceiver {
    /// Callback invoked when UMP words arrive.
    public typealias Handler = (_ group: UInt8, _ words: [UInt32], _ hostTime: UInt64) -> Void

    /// Creates a receiver instance.
    public init(clientName: String = "TeatroClient") throws {}

    /// Opens an input port matching the provided name.
    public func openInput(nameMatch: String, protocol midiProtocol: MIDIProtocolID,
                          handler: @escaping Handler) throws {}
}
