import XCTest
@testable import MIDI2

final class FlexDataTempoTests: XCTestCase {
    func testRoundTrip() {
        let original = FlexDataTempo(beatsPerMinute: 123.456)
        let packet = original.encode(group: 2)
        let decoded = FlexDataTempo.decode(packet)
        XCTAssertNotNil(decoded)
        if let decoded {
            XCTAssertEqual(decoded.beatsPerMinute, original.beatsPerMinute, accuracy: 0.001)
        }
    }

    func testSemanticEncoding() {
        let tempo = FlexDataTempo(beatsPerMinute: 120)
        let packet = tempo.encode()
        XCTAssertEqual(packet.word1, 0x00780000)
        guard let decoded = FlexDataTempo.decode(packet) else { return XCTFail("decode failed") }
        XCTAssertEqual(decoded.beatsPerMinute, 120, accuracy: 0.0001)
    }

    func testMalformedDecode() {
        let bad = Ump128(word0: 0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexDataTempo.decode(bad))
    }
}
