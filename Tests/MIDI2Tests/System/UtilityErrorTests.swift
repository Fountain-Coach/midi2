import XCTest
@testable import MIDI2

final class UtilityErrorTests: XCTestCase {
    func testUnsupportedStatus() {
        let word = (UInt32(0x0) << 28) | (UInt32(0x5) << 20)
        let ump = UmpPacket32(word: word)
        XCTAssertThrowsError(try Utility(parsingUMP: ump)) { error in
            XCTAssertTrue(error.localizedDescription.contains("unknown utility opcode"))
        }
    }

    func testNonZeroGroupNibble() {
        let word = (UInt32(0x0) << 28) | (UInt32(0x1) << 24)
        let ump = UmpPacket32(word: word)
        XCTAssertThrowsError(try Utility(parsingUMP: ump)) { error in
            XCTAssertTrue(error.localizedDescription.contains("group 0"))
        }
    }

    func testNoopMustHaveZeroPayload() {
        let word = (UInt32(0x0) << 28) | (UInt32(0x0) << 20) | 0x1234
        let ump = UmpPacket32(word: word)
        XCTAssertThrowsError(try Utility(parsingUMP: ump)) { error in
            XCTAssertTrue(error.localizedDescription.contains("zero data"))
        }
    }
}
