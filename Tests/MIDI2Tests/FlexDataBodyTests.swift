import XCTest
@testable import MIDI2

final class FlexDataBodyTests: XCTestCase {
    func testDecodeTempo() {
        let tempo = FlexDataTempo(beatsPerMinute: 90)
        let pkt = tempo.encode()
        XCTAssertEqual(FlexDataBody(packet: pkt), .tempo(tempo))
    }

    func testUnknown() {
        let bad = Ump128(word0: 0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexDataBody(packet: bad))
    }
}
