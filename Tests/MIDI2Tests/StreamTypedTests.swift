import XCTest
@testable import MIDI2

final class StreamTypedTests: XCTestCase {
    func testEndpointDiscoveryRoundTrip() throws {
        // reserved high nibble in data2 must be zero
        let msg = EndpointDiscoveryMessage(data1: 0x12, data2: 0x04)
        let group = Uint4(0x3)!
        let pkt = msg.ump(group: group)
        let parsed = try EndpointDiscoveryMessage(parsingUMP: pkt)
        XCTAssertEqual(parsed, msg)
        // Ensure wrong opcode fails
        let wrong = StreamBody(opcode: .streamConfiguration, data1: 0x12, data2: 0x34).ump(group: group)
        XCTAssertNil(EndpointDiscoveryMessage(ump: wrong))
        XCTAssertThrowsError(try EndpointDiscoveryMessage(parsingUMP: wrong))
    }

    func testStreamConfigurationRoundTrip() throws {
        // Use spec-valid bytes: data1=0x27 (proto=midi2, jrTx/jrRx/isNotif set), data2=0x00
        let msg = StreamConfigurationMessage(data1: 0x27, data2: 0x00)
        let group = Uint4(0x0)!
        let pkt = msg.ump(group: group)
        let parsed = try StreamConfigurationMessage(parsingUMP: pkt)
        XCTAssertEqual(parsed, msg)
    }

    func testFunctionBlockRoundTrip() throws {
        let msg = FunctionBlockMessage(data1: 0x01, data2: 0xFF)
        let group = Uint4(0xF)!
        let pkt = msg.ump(group: group)
        let parsed = try FunctionBlockMessage(parsingUMP: pkt)
        XCTAssertEqual(parsed, msg)
    }
}
