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
/// This lightweight implementation collects events in memory and writes a
/// minimal Standard MIDI File (format 0) for use in unit tests. The focus is on
/// deterministic translation from beat‑based positions to MIDI ticks.
public final class AppleSequencerBridge {
    private let ppq: Int
    private let timeSignature: TimeSignature

    private var tempoMap: [TempoEvent] = []
    private var markers: [(beat: Double, text: String)] = []
    private var lyrics: [(beat: Double, text: String)] = []
    private struct Note { let track: Int; let channel: UInt8; let note: UInt8; let velocity: UInt8; let start: Double; let duration: Double }
    private var notes: [Note] = []

    /// Creates a bridge with the desired pulses-per-quarter-note and signature.
    public init(ppq: Int = 480,
                timeSignature: TimeSignature = .init(numerator: 4, denominatorPow2: 2)) {
        self.ppq = ppq
        self.timeSignature = timeSignature
    }

    /// Sets the tempo map.
    public func setTempoMap(_ events: [TempoEvent]) {
        tempoMap = events.sorted { $0.beat < $1.beat }
    }

    /// Adds a marker at the specified beat.
    public func addMarker(beat: Double, text: String) {
        markers.append((beat, text))
    }

    /// Adds a lyric event at the specified beat.
    public func addLyric(beat: Double, text: String) {
        lyrics.append((beat, text))
    }

    /// Adds a note event to the sequence.
    public func addNote(track: Int, channel: UInt8, note: UInt8, velocity: UInt8,
                        startBeat: Double, durationBeats: Double) {
        notes.append(Note(track: track, channel: channel, note: note, velocity: velocity,
                          start: startBeat, duration: durationBeats))
    }

    /// Converts beats to absolute ticks using the configured PPQ.
    private func ticks(fromBeats beats: Double) -> Int {
        Int(round(beats * Double(ppq)))
    }

    /// Encodes an integer into a variable-length quantity.
    private func vlq(_ value: Int) -> [UInt8] {
        var buffer = value & 0x7F
        var result: [UInt8] = [UInt8(buffer)]
        var value = value >> 7
        while value > 0 {
            buffer = value & 0x7F
            value >>= 7
            result.insert(UInt8(buffer | 0x80), at: 0)
        }
        return result
    }

    /// Exports the sequence to a Standard MIDI File.
    public func exportSMF(url: URL) throws {
        var events: [(tick: Int, data: [UInt8])] = []

        // Tempo events
        for t in tempoMap {
            let usPerQuarter = Int(60_000_000 / t.bpm)
            let data: [UInt8] = [0xFF, 0x51, 0x03,
                                 UInt8((usPerQuarter >> 16) & 0xFF),
                                 UInt8((usPerQuarter >> 8) & 0xFF),
                                 UInt8(usPerQuarter & 0xFF)]
            events.append((tick: ticks(fromBeats: t.beat), data: data))
        }

        // Time signature at start
        let tsData: [UInt8] = [0xFF, 0x58, 0x04,
                               timeSignature.numerator,
                               timeSignature.denominatorPow2,
                               24, 8]
        events.append((tick: 0, data: tsData))

        // Markers and lyrics
        for m in markers {
            let bytes = Array(m.text.utf8)
            let data: [UInt8] = [0xFF, 0x06] + vlq(bytes.count) + bytes
            events.append((tick: ticks(fromBeats: m.beat), data: data))
        }
        for l in lyrics {
            let bytes = Array(l.text.utf8)
            let data: [UInt8] = [0xFF, 0x05] + vlq(bytes.count) + bytes
            events.append((tick: ticks(fromBeats: l.beat), data: data))
        }

        // Notes
        for n in notes {
            let start = ticks(fromBeats: n.start)
            let end = ticks(fromBeats: n.start + n.duration)
            events.append((tick: start, data: [0x90 | (n.channel & 0x0F), n.note, n.velocity]))
            events.append((tick: end, data: [0x80 | (n.channel & 0x0F), n.note, 0]))
        }

        // Sort by tick
        events.sort { $0.tick < $1.tick }

        // Build track data with delta times
        var trackBytes: [UInt8] = []
        var lastTick = 0
        for event in events {
            let delta = event.tick - lastTick
            lastTick = event.tick
            trackBytes += vlq(delta)
            trackBytes += event.data
        }
        // End-of-track
        trackBytes += [0x00, 0xFF, 0x2F, 0x00]

        // Header chunk
        var fileBytes: [UInt8] = []
        fileBytes += Array("MThd".utf8)
        fileBytes += [0x00, 0x00, 0x00, 0x06]
        fileBytes += [0x00, 0x00] // format 0
        fileBytes += [0x00, 0x01] // one track
        fileBytes += [UInt8((ppq >> 8) & 0xFF), UInt8(ppq & 0xFF)]

        // Track chunk
        fileBytes += Array("MTrk".utf8)
        let length = UInt32(trackBytes.count)
        fileBytes += [UInt8((length >> 24) & 0xFF), UInt8((length >> 16) & 0xFF),
                      UInt8((length >> 8) & 0xFF), UInt8(length & 0xFF)]
        fileBytes += trackBytes

        let data = Data(fileBytes)
        try data.write(to: url)
    }
}
