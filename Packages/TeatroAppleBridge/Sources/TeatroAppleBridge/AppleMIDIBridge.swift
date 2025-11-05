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
    /// Bridge‑specific errors.
    public enum BridgeError: Error {
        case destinationNotFound
        case noDestinationSelected
        case virtualSourceNotStarted
    }

    private let clientName: String
    private var io: AppleMIDIIO?
    private var destinationName: String?
    private var virtualSourceName: String?

    /// Records events for unit tests.
    public private(set) var sentEvents: [(group: UInt8, words: [UInt32], hostTime: UInt64)] = []

    /// Creates a new bridge instance.
    public init(clientName: String = "TeatroClient") throws {
        self.clientName = clientName
        // Try to initialize real CoreMIDI IO when available; otherwise remain on virtual router.
        self.io = try? AppleMIDIIO(clientName: clientName)
    }

    /// Selects a MIDI destination matching the provided selector.
    public func selectDestination(_ selector: MIDIDestinationSelector) throws {
        if let io {
            // Verify an endpoint exists; store selector string for later send.
            let endpoints = try io.enumerateEndpoints().filter { $0.isDestination }
            guard endpoints.contains(where: { $0.name.contains(selector.matchContains) }) else {
                throw BridgeError.destinationNotFound
            }
            destinationName = selector.matchContains
        } else {
            guard let name = VirtualMIDIRouter.sourceName(matching: selector.matchContains) else {
                throw BridgeError.destinationNotFound
            }
            destinationName = name
        }
    }

    /// Sends raw UMP words to the selected destination.
    public func sendUMP(words: [UInt32], hostTime: UInt64) throws {
        guard let name = destinationName else {
            throw BridgeError.noDestinationSelected
        }
        let group = UInt8((words.first ?? 0) >> 24 & 0x0F)
        sentEvents.append((group, words, hostTime))
        if let io {
            try io.sendUMP(toDestinationNameContains: name, words: words, hostTime: hostTime)
        } else {
            VirtualMIDIRouter.publish(name: name, group: group, words: words, hostTime: hostTime)
        }
    }

    /// Convenience method to send a Control Change message.
    public func sendCC(channel: UInt8, cc: UInt8, value: UInt8,
                       group: UInt8 = 0, hostTime: UInt64) throws {
        let status: UInt32 = 0xB0 | UInt32(channel & 0x0F)
        let word: UInt32 = (0x2 << 28) | (UInt32(group & 0x0F) << 24)
            | (status << 16) | (UInt32(cc & 0x7F) << 8) | UInt32(value & 0x7F)
        try sendUMP(words: [word], hostTime: hostTime)
    }

    /// Convenience method to send a Note On message.
    public func sendNoteOn(channel: UInt8, note: UInt8, velocity: UInt16,
                           group: UInt8 = 0, hostTime: UInt64) throws {
        let vel = UInt32(min(velocity, 0x7F))
        let status: UInt32 = 0x90 | UInt32(channel & 0x0F)
        let word: UInt32 = (0x2 << 28) | (UInt32(group & 0x0F) << 24)
            | (status << 16) | (UInt32(note & 0x7F) << 8) | vel
        try sendUMP(words: [word], hostTime: hostTime)
    }

    /// Convenience method to send a Note Off message.
    public func sendNoteOff(channel: UInt8, note: UInt8, velocity: UInt16,
                            group: UInt8 = 0, hostTime: UInt64) throws {
        let vel = UInt32(min(velocity, 0x7F))
        let status: UInt32 = 0x80 | UInt32(channel & 0x0F)
        let word: UInt32 = (0x2 << 28) | (UInt32(group & 0x0F) << 24)
            | (status << 16) | (UInt32(note & 0x7F) << 8) | vel
        try sendUMP(words: [word], hostTime: hostTime)
    }

    /// Starts a virtual MIDI source that other applications can subscribe to.
    public func startVirtualSource(name: String, protocol midiProtocol: MIDIProtocolID) throws {
        virtualSourceName = name
        // For virtual in-process tests we keep a virtual source; AU/Apps would publish real virtual sources via CoreMIDI.
        VirtualMIDIRouter.registerSource(name: name)
    }

    /// Publishes UMP words through the virtual source.
    public func publishUMP(words: [UInt32], hostTime: UInt64) throws {
        guard let name = virtualSourceName else {
            throw BridgeError.virtualSourceNotStarted
        }
        let group = UInt8((words.first ?? 0) >> 24 & 0x0F)
        sentEvents.append((group, words, hostTime))
        VirtualMIDIRouter.publish(name: name, group: group, words: words, hostTime: hostTime)
    }
}
