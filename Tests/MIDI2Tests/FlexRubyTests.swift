import XCTest
@testable import MIDI2

final class FlexRubyTests: XCTestCase {
    func testRoundTrip() {
        let addr = FlexRuby.Address.channel(group: Uint4(0)!, channel: Uint4(1)!)
        let msg = try! FlexRuby(address: addr, ruby: "kana")
        let packet = msg.encode()
        XCTAssertEqual(FlexRuby.decode(packet), msg)
    }

    func testMalformed() {
        let bad = Ump128(word0: 0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexRuby.decode(bad))
    }
}
