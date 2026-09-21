import XCTest
@testable import MIDI2

final class SysEx8CompletionTests: XCTestCase {
    func testIncompleteStartAndContinuationCannotCompleteMessage() throws {
        let payload = Array(repeating: UInt8(1), count: 40)
        let packets = try SysEx8.fragment(manufacturerID: [0x7E], payload: payload)
        XCTAssertEqual(packets.count, 3)
        XCTAssertThrowsError(try SysEx8.reassemble(Array(packets.prefix(1))))
        XCTAssertThrowsError(try SysEx8.reassemble(Array(packets.prefix(2))))
        XCTAssertThrowsError(try SysEx8.reassemble(Array(packets.suffix(1))))
        XCTAssertEqual(try SysEx8.reassemble(packets).payload, payload)
    }
}
