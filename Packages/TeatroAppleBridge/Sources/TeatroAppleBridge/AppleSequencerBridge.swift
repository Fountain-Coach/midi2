import Foundation

/// Represents a tempo change at a given beat position.
public struct TempoEvent {
    /// Beat position where the tempo change occurs.
    public let beat: Double
    /// Beats per minute at the specified beat.
    public let bpm: Double

    /// Creates a tempo event.
    public init(beat: Double, bpm: Double) {
        self.beat = beat
        self.bpm = bpm
    }
}

/// Time signature represented as numerator and denominator power-of-two.
public struct TimeSignature {
    /// Numerator of the time signature.
    public let numerator: UInt8
    /// Denominator expressed as power of two (e.g. 4/4 → 2).
    public let denominatorPow2: UInt8

    /// Creates a time signature.
    public init(numerator: UInt8, denominatorPow2: UInt8) {
        self.numerator = numerator
        self.denominatorPow2 = denominatorPow2
    }
}

/// Builds MusicSequence structures and exports Standard MIDI Files.
///
/// The current implementation provides API stubs to be filled in with Core
/// MIDI sequencing calls on Apple platforms.
public final class AppleSequencerBridge {
    /// Creates a bridge with the desired pulses-per-quarter-note and signature.
    public init(ppq: Int = 480,
                timeSignature: TimeSignature = .init(numerator: 4, denominatorPow2: 2)) {}

    /// Sets the tempo map.
    public func setTempoMap(_ events: [TempoEvent]) {}

    /// Adds a marker at the specified beat.
    public func addMarker(beat: Double, text: String) {}

    /// Adds a lyric event at the specified beat.
    public func addLyric(beat: Double, text: String) {}

    /// Adds a note event to the sequence.
    public func addNote(track: Int, channel: UInt8, note: UInt8, velocity: UInt8,
                        startBeat: Double, durationBeats: Double) {}

    /// Exports the sequence to a Standard MIDI File.
    public func exportSMF(url: URL) throws {}
}
