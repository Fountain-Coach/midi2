import Foundation
import TeatroAppleBridge

// Build a simple sequence and write it to disk.
let seq = AppleSequencerBridge()
seq.setTempoMap([TempoEvent(beat: 0, bpm: 120)])
seq.addMarker(beat: 0, text: "Start")
seq.addLyric(beat: 1, text: "La")
seq.addNote(track: 0, channel: 0, note: 60, velocity: 100,
            startBeat: 0, durationBeats: 1)

let url = URL(fileURLWithPath: "demo.mid")
try seq.exportSMF(url: url)
print("Wrote", url.path)
