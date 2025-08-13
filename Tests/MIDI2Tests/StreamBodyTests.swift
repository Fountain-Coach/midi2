import XCTest
@testable import MIDI2

final class StreamBodyTests: XCTestCase {
    func testRoundTrip() throws {
        let body = StreamBody(opcode: .endpointDiscovery, data1: 0x12, data2: 0x34)
        let packet = body.ump(group: Uint4(0x2)!)
        let decoded = StreamBody(ump: packet)
        XCTAssertEqual(decoded, body)

        XCTAssertNoThrow(try StreamBody(parsingUMP: packet))
    }
}
