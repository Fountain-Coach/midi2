import XCTest
@testable import MIDI2

final class FlexReservedNegativeTests: XCTestCase {
    func testRejectsReservedStatusClass() {
        // mt=0xD, status class = 0x7F (reserved)
        let pkt = Ump128(word0: (UInt32(0xD) << 28) | (UInt32(0x7F) << 16), word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(FlexDataBody(packet: pkt))
        XCTAssertNil(FlexDataTempo.decode(pkt))
    }
}
