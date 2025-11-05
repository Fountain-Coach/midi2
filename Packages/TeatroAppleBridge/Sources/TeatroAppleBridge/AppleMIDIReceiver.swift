import Foundation

/// Receives UMP messages from Core MIDI inputs and forwards them to a handler.
///
/// The real implementation would hook into Core MIDI's receive blocks. For
/// cross‑platform testing we simulate inputs via ``VirtualMIDIRouter``.
public final class AppleMIDIReceiver {
    /// Callback invoked when UMP words arrive.
    public typealias Handler = @Sendable (_ group: UInt8, _ words: [UInt32], _ hostTime: UInt64) -> Void

    /// Errors that can be thrown by the receiver.
    public enum ReceiverError: Error { case inputNotFound }

    private let clientName: String
    private var io: AppleMIDIIO?

    /// Creates a receiver instance.
    public init(clientName: String = "TeatroClient") throws {
        self.clientName = clientName
        self.io = try? AppleMIDIIO(clientName: clientName)
    }

    /// Opens an input port matching the provided name.
    public func openInput(nameMatch: String, protocol midiProtocol: MIDIProtocolID,
                          handler: @escaping Handler) throws {
        if let io {
            try io.openInput(nameContains: nameMatch, handler: handler)
        } else {
            guard VirtualMIDIRouter.subscribe(nameMatch: nameMatch, handler: handler) else {
                throw ReceiverError.inputNotFound
            }
        }
    }
}
