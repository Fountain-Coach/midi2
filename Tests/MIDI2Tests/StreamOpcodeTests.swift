import XCTest
@testable import MIDI2

final class StreamOpcodeTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(StreamOpcode.endpointDiscovery.rawValue, 0x00)
        XCTAssertEqual(StreamOpcode.endpointInfoNotification.rawValue, 0x01)
        XCTAssertEqual(StreamOpcode.deviceIdentityNotification.rawValue, 0x02)
        XCTAssertEqual(StreamOpcode.endpointNameNotification.rawValue, 0x03)
        XCTAssertEqual(StreamOpcode.productInstanceIdNotification.rawValue, 0x04)
        XCTAssertEqual(StreamOpcode.streamConfigurationRequest.rawValue, 0x05)
        XCTAssertEqual(StreamOpcode.streamConfigurationNotification.rawValue, 0x06)
        XCTAssertEqual(StreamOpcode.functionBlockDiscovery.rawValue, 0x10)
        XCTAssertEqual(StreamOpcode.functionBlockInfoNotification.rawValue, 0x11)
        XCTAssertEqual(StreamOpcode.functionBlockNameNotification.rawValue, 0x12)
        XCTAssertEqual(StreamOpcode.startOfClip.rawValue, 0x20)
        XCTAssertEqual(StreamOpcode.endOfClip.rawValue, 0x21)
    }

    func testInitFromRaw() {
        XCTAssertEqual(StreamOpcode(rawValue: 0x00), .endpointDiscovery)
        XCTAssertEqual(StreamOpcode(rawValue: 0x01), .endpointInfoNotification)
        XCTAssertEqual(StreamOpcode(rawValue: 0x02), .deviceIdentityNotification)
        XCTAssertEqual(StreamOpcode(rawValue: 0x03), .endpointNameNotification)
        XCTAssertEqual(StreamOpcode(rawValue: 0x04), .productInstanceIdNotification)
        XCTAssertEqual(StreamOpcode(rawValue: 0x05), .streamConfigurationRequest)
        XCTAssertEqual(StreamOpcode(rawValue: 0x06), .streamConfigurationNotification)
        XCTAssertEqual(StreamOpcode(rawValue: 0x10), .functionBlockDiscovery)
        XCTAssertEqual(StreamOpcode(rawValue: 0x11), .functionBlockInfoNotification)
        XCTAssertEqual(StreamOpcode(rawValue: 0x12), .functionBlockNameNotification)
        XCTAssertEqual(StreamOpcode(rawValue: 0x20), .startOfClip)
        XCTAssertEqual(StreamOpcode(rawValue: 0x21), .endOfClip)
        XCTAssertNil(StreamOpcode(rawValue: 0x22))
    }
}
