import XCTest
@testable import MIDI2

final class SystemCommonErrorTests: XCTestCase {
    func testUnsupportedStatus() {
        let byte0 = UInt32(0x1 << 4 | 0x1)
        let status = UInt32(0xF4)
        let word = (byte0 << 24) | (status << 16)
        let ump = UmpPacket32(word: word)
        XCTAssertThrowsError(try SystemCommon(parsingUMP: ump)) { error in
            XCTAssertTrue(error.localizedDescription.contains("unsupported system common status"))
        }
    }
}
