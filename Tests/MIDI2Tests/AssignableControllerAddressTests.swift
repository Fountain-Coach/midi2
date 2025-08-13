import XCTest
@testable import MIDI2

final class AssignableControllerAddressTests: XCTestCase {
    func testRoundTrip() {
        let addr = Midi2AssignableControllerAddress(rawValue: 0x40)
        XCTAssertEqual(addr?.rawValue, 0x40)
    }

    func testBounds() {
        XCTAssertNotNil(Midi2AssignableControllerAddress(rawValue: 0))
        XCTAssertNotNil(Midi2AssignableControllerAddress(rawValue: 0x7F))
        XCTAssertNil(Midi2AssignableControllerAddress(rawValue: 0x80))
    }
}
