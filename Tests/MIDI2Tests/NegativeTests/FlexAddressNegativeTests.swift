import XCTest
@testable import MIDI2

final class FlexAddressNegativeTests: XCTestCase {
    func testKeySignatureRejectsInvalidChannelNibble() {
        // addrByte channel nibble 0xF (reserved)
        let word0 = (UInt32(0xD) << 28) | (UInt32(0x10) << 16) | UInt32(0x1F)
        let pkt = Ump128(word0: word0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexKeySignature.decode(pkt))
    }

    func testLyricRejectsInvalidChannelNibble() {
        let word0 = (UInt32(0xD) << 28) | (UInt32(0x11) << 16) | UInt32(0x1F)
        let pkt = Ump128(word0: word0, word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexLyric.decode(pkt))
    }

    func testMetronomeRejectsClicksBelowOne() {
        let addr = FlexMetronome.Address.group(Uint4(0)!)
        XCTAssertThrowsError(try FlexMetronome(address: addr, clicksPerBeat: 0, accentPattern: "1000"))
    }
}
