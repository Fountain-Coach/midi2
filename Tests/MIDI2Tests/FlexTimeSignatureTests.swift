import XCTest
@testable import MIDI2

final class FlexTimeSignatureTests: XCTestCase {
    func testRoundTrip() {
        let addr = FlexTimeSignature.Address.group(Uint4(2)!)
        let msg = try! FlexTimeSignature(address: addr, numerator: 3, denominatorPow2: 2)
        let packet = msg.encode()
        XCTAssertEqual(FlexTimeSignature.decode(packet), msg)
    }

    func testMalformed() {
        let bad = Ump128(word0: 0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexTimeSignature.decode(bad))
    }
}
