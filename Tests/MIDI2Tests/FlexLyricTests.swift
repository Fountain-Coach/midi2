import XCTest
@testable import MIDI2

final class FlexLyricTests: XCTestCase {
    func testRoundTrip() {
        let addr = FlexLyric.Address.group(Uint4(0)!)
        let msg = try! FlexLyric(address: addr, lyric: "la")
        let packet = msg.encode()
        XCTAssertEqual(FlexLyric.decode(packet), msg)
    }

    func testMalformed() {
        let bad = Ump128(word0: 0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexLyric.decode(bad))
    }
}
