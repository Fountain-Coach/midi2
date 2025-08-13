import XCTest
@testable import MIDI2

final class FlexDataPitchTests: XCTestCase {
    func testRoundTrip() {
        let original = FlexDataPitch(semitones: 3.5)
        let packet = original.encode(group: 1)
        let decoded = FlexDataPitch.decode(packet)
        XCTAssertNotNil(decoded)
        if let decoded {
            XCTAssertEqual(decoded.semitones, original.semitones, accuracy: 0.0001)
        }
    }

    func testSemanticEncoding() {
        let pitch = FlexDataPitch(semitones: 3.5)
        let packet = pitch.encode()
        XCTAssertEqual(packet.word1, 0x00038000)
        guard let decoded = FlexDataPitch.decode(packet) else { return XCTFail("decode failed") }
        XCTAssertEqual(decoded.semitones, 3.5, accuracy: 0.0001)
    }
}
