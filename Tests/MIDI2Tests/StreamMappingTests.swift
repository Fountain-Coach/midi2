import XCTest
@testable import MIDI2

final class StreamMappingTests: XCTestCase {
    func testEndpointDiscoveryFieldsRoundTrip() throws {
        var msg = EndpointDiscoveryMessage(majorVersion: 1, minorVersion: 2, maxGroups: 8)
        XCTAssertEqual(msg.majorVersion, 1)
        XCTAssertEqual(msg.minorVersion, 2)
        XCTAssertEqual(msg.maxGroups, 8)
        XCTAssertEqual(msg.reservedHighNibble, 0)

        msg.majorVersion = 3
        msg.minorVersion = 4
        msg.reservedHighNibble = 0 // reserved must be explicitly set; keep zero
        msg.maxGroups = 0xF
        XCTAssertEqual(msg.data1, 0x34)
        XCTAssertEqual(msg.data2, 0x0F)
    }

    func testStreamConfigurationFieldsRoundTrip() throws {
        var msg = StreamConfigurationMessage(isNotification: true, jrTimestampsTx: true, jrTimestampsRx: true, protocolSelection: .midi2)
        XCTAssertTrue(msg.isNotification)
        XCTAssertTrue(msg.jrTimestampsTx)
        XCTAssertTrue(msg.jrTimestampsRx)
        XCTAssertEqual(msg.protocolSelection, .midi2)
        XCTAssertEqual(msg.reservedByte2, 0)

        msg.isNotification = false
        msg.jrTimestampsTx = false
        msg.jrTimestampsRx = true
        msg.protocolSelection = .midi1
        XCTAssertEqual((msg.data1 & 0x02), 0)
        XCTAssertEqual((msg.data1 & 0x04), 0x04)
        XCTAssertEqual((msg.data1 >> 5) & 0x03, 0)
        XCTAssertEqual(msg.data2, 0x00)
        XCTAssertEqual(msg.opcode, .streamConfigurationRequest)
    }

    func testFunctionBlockFieldsRoundTrip() throws {
        var msg = FunctionBlockMessage(index: 0x7F, firstGroup: 0x0, groupCount: 0xF)
        XCTAssertEqual(msg.index, 0x7F)
        XCTAssertEqual(msg.firstGroup, 0x0)
        XCTAssertEqual(msg.groupCount, 0xF)

        msg.index = 0x01
        msg.firstGroup = 0xA
        msg.groupCount = 0x3
        XCTAssertEqual(msg.data1, 0x01)
        XCTAssertEqual(msg.data2, 0xA3)
    }

    func testEndpointInfoValidationAndRoundTrip() throws {
        let msg = try EndpointInfoNotification(
            staticFunctionBlocks: true,
            numberOfFunctionBlocks: 0x20,
            midi1Supported: true,
            midi2Supported: true,
            jrTimestampsRx: true,
            jrTimestampsTx: false
        )
        let packet = msg.ump(group: Uint4(0)!)
        let decoded = try EndpointInfoNotification(parsingUMP: packet)
        XCTAssertEqual(decoded, msg)
    }

    func testEndpointInfoRejectsReservedBits() throws {
        let group = Uint4(0)!
        let status = StreamOpcode.endpointInfoNotification.rawValue
        XCTAssertThrowsError(try EndpointInfoNotification(parsingUMP: UmpPacket32(mt: 0xF, group: group, status: status, data1: 0x41, data2: 0x00)))
        XCTAssertThrowsError(try EndpointInfoNotification(parsingUMP: UmpPacket32(mt: 0xF, group: group, status: status, data1: 0x21, data2: 0x00)))
        XCTAssertThrowsError(try EndpointInfoNotification(parsingUMP: UmpPacket32(mt: 0xF, group: group, status: status, data1: 0x01, data2: 0x10)))
    }
}
