import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class PropertyExchangeCompressionTests: XCTestCase {
    func testZlibRoundTripIfAvailable() {
        let data = Array("Hello MIDI-CI".utf8)
        let enc: MidiCiPropertyExchangeBody.Encoding = .jsonZlib
        let compressed = PropertyExchangeCodec.encode(data, using: enc)
        let decoded = PropertyExchangeCodec.decode(compressed, using: enc)
        XCTAssertEqual(decoded, data)
    }
}

