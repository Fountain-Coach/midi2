import XCTest
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
}
