import XCTest
@testable import MIDI2

final class NrpnAddressTests: XCTestCase {
    func testRoundTrip() {
        let addr = Midi2NRPNAddress(rawValue: 0x1ABC)
        XCTAssertEqual(addr?.rawValue, 0x1ABC)
    }

    func testBounds() {
        XCTAssertNotNil(Midi2NRPNAddress(rawValue: 0))
        XCTAssertNotNil(Midi2NRPNAddress(rawValue: 0x3FFF))
        XCTAssertNil(Midi2NRPNAddress(rawValue: 0x4000))
    }
}
