import XCTest
@testable import MIDI2

final class FlexValidationNegativeTests: XCTestCase {
    func testRejectsTempoAboveFixedPointRange() {
        XCTAssertThrowsError(try FlexDataTempo(beatsPerMinute: 70_000))
    }

    func testRejectsTextLongerThanTwelveBytes() {
        let addr = FlexText.Address.group(Uint4(0)!)
        XCTAssertThrowsError(try FlexText(address: addr, text: String(repeating: "a", count: 13)))
    }

    func testRejectsMetronomeAccentPatternLongerThanTenBytes() {
        let addr = FlexMetronome.Address.group(Uint4(0)!)
        XCTAssertThrowsError(try FlexMetronome(address: addr, clicksPerBeat: 4, accentPattern: "12345678901"))
    }
}
