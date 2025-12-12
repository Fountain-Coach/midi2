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

    func testStreamConfigurationRejectsReservedBits() {
        let group = Uint4(0x0)!
        // data1 bit 3 set (reserved)
        let pktReservedBit3 = StreamBody(opcode: .streamConfiguration, data1: 0b0000_1000, data2: 0x00)
            .ump(group: group)
        XCTAssertNil(StreamConfigurationMessage(ump: pktReservedBit3))
        XCTAssertThrowsError(try StreamConfigurationMessage(parsingUMP: pktReservedBit3))

        // data1 bit 4 set (reserved)
        let pktReservedBit4 = StreamBody(opcode: .streamConfiguration, data1: 0b0001_0000, data2: 0x00)
            .ump(group: group)
        XCTAssertNil(StreamConfigurationMessage(ump: pktReservedBit4))
        XCTAssertThrowsError(try StreamConfigurationMessage(parsingUMP: pktReservedBit4))

        // data1 bit 7 set (reserved)
        let pktReservedBit7 = StreamBody(opcode: .streamConfiguration, data1: 0b1000_0000, data2: 0x00)
            .ump(group: group)
        XCTAssertNil(StreamConfigurationMessage(ump: pktReservedBit7))
        XCTAssertThrowsError(try StreamConfigurationMessage(parsingUMP: pktReservedBit7))

        // protocol selector invalid (value 0b10)
        let pktInvalidProto = StreamBody(opcode: .streamConfiguration, data1: 0b0100_0000, data2: 0x00)
            .ump(group: group)
        XCTAssertNil(StreamConfigurationMessage(ump: pktInvalidProto))
        XCTAssertThrowsError(try StreamConfigurationMessage(parsingUMP: pktInvalidProto))

        // data2 must be zero
        let pktData2NonZero = StreamBody(opcode: .streamConfiguration, data1: 0x01, data2: 0xFF)
            .ump(group: group)
        XCTAssertNil(StreamConfigurationMessage(ump: pktData2NonZero))
        XCTAssertThrowsError(try StreamConfigurationMessage(parsingUMP: pktData2NonZero))
    }

    func testFunctionBlockRoundTrip() throws {
        let msg = FunctionBlockMessage(data1: 0x01, data2: 0xFF)
        let group = Uint4(0xF)!
        let pkt = msg.ump(group: group)
        let parsed = try FunctionBlockMessage(parsingUMP: pkt)
        XCTAssertEqual(parsed, msg)
    }

    func testEndpointDiscoveryRejectsReservedNibble() {
        let group = Uint4(0x3)!
        // High nibble in data2 must be zero
        let pkt = StreamBody(opcode: .endpointDiscovery, data1: 0x12, data2: 0xF0).ump(group: group)
        XCTAssertNil(EndpointDiscoveryMessage(ump: pkt))
        XCTAssertThrowsError(try EndpointDiscoveryMessage(parsingUMP: pkt))
    }
}
