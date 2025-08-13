import XCTest
@testable import MIDI2

final class FlexTextTests: XCTestCase {
    func testRoundTrip() {
        let addr = FlexText.Address.group(Uint4(3)!)
        let msg = FlexText(address: addr, text: "Hello")
        let packet = msg.encode()
        XCTAssertEqual(FlexText.decode(packet), msg)
    }

    func testMalformed() {
        let bad = Ump128(word0: 0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexText.decode(bad))
    }
}
