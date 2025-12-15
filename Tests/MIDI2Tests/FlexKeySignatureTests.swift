import XCTest
@testable import MIDI2

final class FlexKeySignatureTests: XCTestCase {
    func testRoundTrip() {
        let addr = FlexKeySignature.Address.channel(group: Uint4(1)!, channel: Uint4(2)!)
        let msg = try! FlexKeySignature(address: addr, key: "Gm")
        let packet = msg.encode()
        XCTAssertEqual(FlexKeySignature.decode(packet), msg)
    }

    func testMalformed() {
        let bad = Ump128(word0: 0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexKeySignature.decode(bad))
    }
}
