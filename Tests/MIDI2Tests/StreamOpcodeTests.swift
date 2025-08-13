import XCTest
@testable import MIDI2

final class StreamOpcodeTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(StreamOpcode.endpointDiscovery.rawValue, 0x00)
        XCTAssertEqual(StreamOpcode.streamConfiguration.rawValue, 0x01)
        XCTAssertEqual(StreamOpcode.functionBlock.rawValue, 0x02)
    }

    func testInitFromRaw() {
        XCTAssertEqual(StreamOpcode(rawValue: 0x00), .endpointDiscovery)
        XCTAssertEqual(StreamOpcode(rawValue: 0x01), .streamConfiguration)
        XCTAssertEqual(StreamOpcode(rawValue: 0x02), .functionBlock)
        XCTAssertNil(StreamOpcode(rawValue: 0x03))
    }
}
