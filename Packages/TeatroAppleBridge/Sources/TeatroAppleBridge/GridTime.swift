import Foundation

/// Utilities for converting between grid-based musical time and beats/seconds.
public enum GridTime {
    /// Converts a bar:beat:tick position into total beats.
    /// - Parameters:
    ///   - bar: Bar number starting at 1.
    ///   - beat: Beat number within the bar starting at 1.
    ///   - tick: Tick offset within the beat.
    ///   - beatsPerBar: Number of beats in each bar.
    ///   - ticksPerBeat: Tick resolution per beat.
    /// - Returns: Total beats from the beginning of the piece.
    public static func barBeatTickToBeats(bar: Int, beat: Int, tick: Int,
                                          beatsPerBar: Int, ticksPerBeat: Int) -> Double {
        let barBeats = Double((bar - 1) * beatsPerBar)
        let beatBeats = Double(beat - 1)
        let tickBeats = Double(tick) / Double(ticksPerBeat)
        return barBeats + beatBeats + tickBeats
    }

    /// Converts beats to seconds given a tempo in BPM.
    /// - Parameters:
    ///   - beats: Number of beats.
    ///   - tempoBPM: Tempo in beats per minute.
    /// - Returns: Duration in seconds.
    public static func beatsToSeconds(_ beats: Double, tempoBPM: Double) -> Double {
        beats * 60.0 / tempoBPM
    }
}
