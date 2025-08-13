import XCTest
@testable import MIDI2

final class PerNoteTimbreTests: XCTestCase {
    func testEncodingDecoding() {
        guard let timbre = PerNoteTimbre(0x12345678) else { return XCTFail("init failed") }
        let encoded = timbre.encode()
        let decoded = PerNoteTimbre.decode(encoded)
        XCTAssertEqual(decoded, timbre)
    }

    func testBounds() {
        XCTAssertNotNil(PerNoteTimbre(0))
        XCTAssertNotNil(PerNoteTimbre(Swift.UInt64(Swift.UInt32.max)))
        XCTAssertNil(PerNoteTimbre(Swift.UInt64(Swift.UInt32.max) + 1))
    }
}
