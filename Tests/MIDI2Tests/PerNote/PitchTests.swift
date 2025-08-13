import XCTest
@testable import MIDI2

final class PerNotePitchTests: XCTestCase {
    func testEncodingDecoding() {
        guard let pitch = PerNotePitch(12345) else { return XCTFail("init failed") }
        let encoded = pitch.encode()
        let decoded = PerNotePitch.decode(encoded)
        XCTAssertEqual(decoded, pitch)
    }

    func testBounds() {
        XCTAssertNotNil(PerNotePitch(Swift.Int64(Swift.Int32.min)))
        XCTAssertNotNil(PerNotePitch(Swift.Int64(Swift.Int32.max)))
        XCTAssertNil(PerNotePitch(Swift.Int64(Swift.Int32.min) - 1))
        XCTAssertNil(PerNotePitch(Swift.Int64(Swift.Int32.max) + 1))
    }
}
