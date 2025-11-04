import XCTest
@testable import MIDI2

final class StreamMappingTests: XCTestCase {
    func testEndpointDiscoveryFieldsRoundTrip() throws {
        var msg = EndpointDiscoveryMessage(majorVersion: 1, minorVersion: 2, capabilitiesNibble: 0xA, numGroups: 8)
        XCTAssertEqual(msg.majorVersion, 1)
        XCTAssertEqual(msg.minorVersion, 2)
        XCTAssertEqual(msg.capabilitiesNibble, 0xA)
        XCTAssertEqual(msg.numGroups, 8)

        msg.majorVersion = 3
        msg.minorVersion = 4
        msg.capabilitiesNibble = 0x5
        msg.numGroups = 0xF
        XCTAssertEqual(msg.data1, 0x34)
        XCTAssertEqual(msg.data2, 0x5F)
    }

    func testStreamConfigurationFieldsRoundTrip() throws {
        var msg = StreamConfigurationMessage(isReply: true, mode: 0b101, jrRequested: true, protocolSelection: 0b10, groupMask: 0xAA)
        XCTAssertTrue(msg.isReply)
        XCTAssertEqual(msg.mode, 0b101)
        XCTAssertTrue(msg.jrRequested)
        XCTAssertEqual(msg.protocolSelection, 0b10)
        XCTAssertEqual(msg.groupMask, 0xAA)

        msg.isReply = false
        msg.mode = 0b010
        msg.jrRequested = false
        msg.protocolSelection = 0b01
        msg.groupMask = 0x55
        XCTAssertEqual(msg.data1 & 0x01, 0)
        XCTAssertEqual((msg.data1 >> 1) & 0x07, 0b010)
        XCTAssertEqual((msg.data1 & 0x10) >> 4, 0)
        XCTAssertEqual((msg.data1 >> 5) & 0x03, 0b01)
        XCTAssertEqual(msg.data2, 0x55)
    }

    func testFunctionBlockFieldsRoundTrip() throws {
        var msg = FunctionBlockMessage(kind: 0b10, index: 0x1F, flags: 0b01, count: 0x2A)
        XCTAssertEqual(msg.kind, 0b10)
        XCTAssertEqual(msg.index, 0x1F)
        XCTAssertEqual(msg.flags, 0b01)
        XCTAssertEqual(msg.count, 0x2A & 0x3F)

        msg.kind = 0b01
        msg.index = 0x3F
        msg.flags = 0b11
        msg.count = 0x3E
        XCTAssertEqual(msg.data1 >> 6, 0b01)
        XCTAssertEqual(msg.data1 & 0x3F, 0x3F)
        XCTAssertEqual(msg.data2 >> 6, 0b11)
        XCTAssertEqual(msg.data2 & 0x3F, 0x3E)
    }
}

