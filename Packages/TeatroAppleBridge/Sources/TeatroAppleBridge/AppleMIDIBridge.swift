import Foundation

/// Identifies a destination by matching its name and desired protocol.
public struct MIDIDestinationSelector {
    /// Substring that should appear in the destination name.
    public var matchContains: String
    /// UMP group (0-15) to transmit on.
    public var group: UInt8
    /// Preferred MIDI protocol version.
    public var `protocol`: MIDIProtocolID

    /// Creates a new destination selector.
    /// - Parameters:
    ///   - matchContains: Substring to match in destination names.
    ///   - group: UMP group number.
    ///   - protocol: Preferred protocol; defaults to MIDI 2.0.
    public init(matchContains: String, group: UInt8 = 0, protocol midiProtocol: MIDIProtocolID = ._2_0) {
        self.matchContains = matchContains
        self.group = group
        self.`protocol` = midiProtocol
    }
}

/// Represents the MIDI protocol version used for communication.
public enum MIDIProtocolID: UInt8 {
    /// MIDI 1.0 over Universal MIDI Packets.
    case _1_0 = 1
    /// Native MIDI 2.0.
    case _2_0 = 2
}

/// Bridge for sending UMP messages through Core MIDI destinations.
///
/// The implementation is a placeholder; full Core MIDI integration is
/// provided on Apple platforms in future work.
public final class AppleMIDIBridge {
    /// Creates a new bridge instance.
    public init(clientName: String = "TeatroClient") throws {}

    /// Selects a MIDI destination matching the provided selector.
    public func selectDestination(_ selector: MIDIDestinationSelector) throws {}

    /// Sends raw UMP words to the selected destination.
    public func sendUMP(words: [UInt32], hostTime: UInt64) throws {}

    /// Convenience method to send a Control Change message.
    public func sendCC(channel: UInt8, cc: UInt8, value: UInt8,
                       group: UInt8 = 0, hostTime: UInt64) throws {}

    /// Convenience method to send a Note On message.
    public func sendNoteOn(channel: UInt8, note: UInt8, velocity: UInt16,
                           group: UInt8 = 0, hostTime: UInt64) throws {}

    /// Convenience method to send a Note Off message.
    public func sendNoteOff(channel: UInt8, note: UInt8, velocity: UInt16,
                            group: UInt8 = 0, hostTime: UInt64) throws {}

    /// Starts a virtual MIDI source that other applications can subscribe to.
    public func startVirtualSource(name: String, protocol midiProtocol: MIDIProtocolID) throws {}

    /// Publishes UMP words through the virtual source.
    public func publishUMP(words: [UInt32], hostTime: UInt64) throws {}
}
