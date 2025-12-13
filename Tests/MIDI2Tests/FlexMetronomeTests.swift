import XCTest
@testable import MIDI2

final class FlexMetronomeTests: XCTestCase {
    func testRoundTrip() {
        let addr = FlexMetronome.Address.group(Uint4(3)!)
        let msg = try! FlexMetronome(address: addr, clicksPerBeat: 4, accentPattern: "1000")
        let packet = msg.encode()
        XCTAssertEqual(FlexMetronome.decode(packet), msg)
    }

    func testMalformed() {
        let bad = Ump128(word0: 0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexMetronome.decode(bad))
    }
}
