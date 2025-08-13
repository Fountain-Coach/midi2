import XCTest
@testable import MIDI2

final class SystemStatusTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(SystemStatus.mtcQuarterFrame.rawValue, 0xF1)
        XCTAssertEqual(SystemStatus.songPositionPointer.rawValue, 0xF2)
        XCTAssertEqual(SystemStatus.songSelect.rawValue, 0xF3)
        XCTAssertEqual(SystemStatus.tuneRequest.rawValue, 0xF6)
        XCTAssertEqual(SystemStatus.timingClock.rawValue, 0xF8)
        XCTAssertEqual(SystemStatus.start.rawValue, 0xFA)
        XCTAssertEqual(SystemStatus.continue.rawValue, 0xFB)
        XCTAssertEqual(SystemStatus.stop.rawValue, 0xFC)
        XCTAssertEqual(SystemStatus.activeSensing.rawValue, 0xFE)
        XCTAssertEqual(SystemStatus.systemReset.rawValue, 0xFF)
    }

    func testInitFromRawValue() {
        XCTAssertEqual(SystemStatus(rawValue: 0xF1), .mtcQuarterFrame)
        XCTAssertEqual(SystemStatus(rawValue: 0xF2), .songPositionPointer)
        XCTAssertEqual(SystemStatus(rawValue: 0xF3), .songSelect)
        XCTAssertEqual(SystemStatus(rawValue: 0xF6), .tuneRequest)
        XCTAssertEqual(SystemStatus(rawValue: 0xF8), .timingClock)
        XCTAssertEqual(SystemStatus(rawValue: 0xFA), .start)
        XCTAssertEqual(SystemStatus(rawValue: 0xFB), .continue)
        XCTAssertEqual(SystemStatus(rawValue: 0xFC), .stop)
        XCTAssertEqual(SystemStatus(rawValue: 0xFE), .activeSensing)
        XCTAssertEqual(SystemStatus(rawValue: 0xFF), .systemReset)
        XCTAssertNil(SystemStatus(rawValue: 0xF4))
    }
}
