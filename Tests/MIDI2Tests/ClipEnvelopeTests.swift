import XCTest
@testable import MIDI2

final class ClipEnvelopeTests: XCTestCase {
    func testRoundTrip() {
        let env = ClipEnvelope(startOfClip: true, endOfClip: false, pickupBars: 1.25)
        let packet = env.encode(group: 3)
        XCTAssertEqual(ClipEnvelope.decode(packet), env)
    }

    func testMalformed() {
        let bad = Ump128(word0: 0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(ClipEnvelope.decode(bad))
    }
}
