import XCTest
@testable import MIDI2

final class FlexChordNameTests: XCTestCase {
    func testRoundTrip() {
        let addr = FlexChordName.Address.channel(group: Uint4(1)!, channel: Uint4(2)!)
        let msg = FlexChordName(address: addr, chord: "Cmaj7")
        let packet = msg.encode()
        XCTAssertEqual(FlexChordName.decode(packet), msg)
    }

    func testMalformed() {
        let bad = Ump128(word0: 0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexChordName.decode(bad))
    }
}
