import XCTest
@testable import MIDI2

final class UtilityErrorTests: XCTestCase {
    func testUnsupportedStatus() {
        let byte0 = UInt32(0x0 << 4)
        let word = (byte0 << 24) | (UInt32(0x03) << 16)
        let ump = UmpPacket32(word: word)
        XCTAssertThrowsError(try Utility(parsingUMP: ump)) { error in
            XCTAssertTrue(error.localizedDescription.contains("unsupported utility status"))
        }
    }

    func testNonZeroGroupNibble() {
        let byte0 = UInt32(0x0 << 4 | 0x1)
        let word = (byte0 << 24)
        let ump = UmpPacket32(word: word)
        XCTAssertThrowsError(try Utility(parsingUMP: ump)) { error in
            XCTAssertTrue(error.localizedDescription.contains("group nibble"))
        }
    }

    func testNoopMustHaveZeroPayload() {
        let byte0 = UInt32(0x0 << 4)
        let word = (byte0 << 24) | (UInt32(0x00) << 16) | 0x1234
        let ump = UmpPacket32(word: word)
        XCTAssertThrowsError(try Utility(parsingUMP: ump)) { error in
            XCTAssertTrue(error.localizedDescription.contains("zero data"))
        }
    }
}
