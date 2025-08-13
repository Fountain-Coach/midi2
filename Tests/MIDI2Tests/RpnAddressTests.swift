import XCTest
@testable import MIDI2

final class RpnAddressTests: XCTestCase {
    func testKnownAddresses() {
        XCTAssertEqual(Midi2RPNAddress(rawValue: 0x0000), .perNotePitch)
        XCTAssertEqual(Midi2RPNAddress(rawValue: 0x0001), .perNotePressure)
        XCTAssertEqual(Midi2RPNAddress(rawValue: 0x0002), .perNoteTimbre)
    }

    func testOtherAndBounds() {
        let other = Midi2RPNAddress(rawValue: 0x1234)
        XCTAssertEqual(other?.rawValue, 0x1234)
        let max = Midi2RPNAddress(rawValue: 0x3FFF)
        XCTAssertEqual(max?.rawValue, 0x3FFF)
        XCTAssertNil(Midi2RPNAddress(rawValue: 0x4000))
    }
}
