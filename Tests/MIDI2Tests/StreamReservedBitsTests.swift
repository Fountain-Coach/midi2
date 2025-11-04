import XCTest
@testable import MIDI2

final class StreamReservedBitsTests: XCTestCase {
    func testEndpointDiscoveryReservedHighNibbleFails() throws {
        let group = Uint4(0x1)!
        // data2 high nibble non-zero (0xF0)
        let pkt = StreamBody(opcode: .endpointDiscovery, data1: 0x12, data2: 0xF4).ump(group: group)
        XCTAssertNil(EndpointDiscoveryMessage(ump: pkt))
        XCTAssertThrowsError(try EndpointDiscoveryMessage(parsingUMP: pkt))
    }

    func testStreamConfigReservedBitsInData1Fail() throws {
        let group = Uint4(0x0)!
        // Set reserved bit3 (0x08)
        let pkt = StreamBody(opcode: .streamConfiguration, data1: 0x08, data2: 0x00).ump(group: group)
        XCTAssertNil(StreamConfigurationMessage(ump: pkt))
        XCTAssertThrowsError(try StreamConfigurationMessage(parsingUMP: pkt))
    }

    func testStreamConfigInvalidProtocolFieldFails() throws {
        let group = Uint4(0x0)!
        // protocol field = 2 (0b10 << 5 = 0x40) is reserved
        let pkt = StreamBody(opcode: .streamConfiguration, data1: 0x40, data2: 0x00).ump(group: group)
        XCTAssertNil(StreamConfigurationMessage(ump: pkt))
        XCTAssertThrowsError(try StreamConfigurationMessage(parsingUMP: pkt))
    }

    func testStreamConfigReservedData2NonZeroFails() throws {
        let group = Uint4(0x0)!
        let pkt = StreamBody(opcode: .streamConfiguration, data1: 0x01, data2: 0x01).ump(group: group)
        XCTAssertNil(StreamConfigurationMessage(ump: pkt))
        XCTAssertThrowsError(try StreamConfigurationMessage(parsingUMP: pkt))
    }
}

