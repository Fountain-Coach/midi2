import XCTest
@testable import MIDI2

final class SysEx7BodyTests: XCTestCase {
    func testRoundTrip() throws {
        let body = SysEx7Body(status: .start, data: [1,2,3])
        let packet = body.ump(group: Uint4(0x1)!)
        let decoded = SysEx7Body(ump: packet)
        XCTAssertEqual(decoded, body)

        XCTAssertNoThrow(try SysEx7Body(parsingUMP: packet))
    }
}
