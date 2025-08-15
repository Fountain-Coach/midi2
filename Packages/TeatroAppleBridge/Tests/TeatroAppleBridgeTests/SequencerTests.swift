import XCTest
import Foundation
@testable import TeatroAppleBridge

final class SequencerTests: XCTestCase {
    func testGridTimeAndClock() {
        let beats = GridTime.barBeatTickToBeats(bar: 2, beat: 1, tick: 240,
                                                beatsPerBar: 4, ticksPerBeat: 480)
        XCTAssertEqual(beats, 4.5, accuracy: 0.0001)

        let seconds = GridTime.beatsToSeconds(4.0, tempoBPM: 120.0)
        XCTAssertEqual(seconds, 2.0, accuracy: 0.0001)

        let host = MIDIClock.secondsToHostTime(seconds)
        XCTAssertEqual(Double(host) / 1_000_000_000, seconds, accuracy: 0.0001)
    }

    func testExportSMFWritesData() throws {
        let seq = AppleSequencerBridge()
        seq.setTempoMap([TempoEvent(beat: 0, bpm: 120)])
        seq.addMarker(beat: 0, text: "Start")
        seq.addLyric(beat: 1, text: "La")
        seq.addNote(track: 0, channel: 0, note: 60, velocity: 100,
                    startBeat: 0, durationBeats: 1)

        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test.mid")
        try seq.exportSMF(url: url)
        let data = try Data(contentsOf: url)
        XCTAssertGreaterThan(data.count, 0)
    }
}
