import XCTest
@testable import MIDI2

final class MidiCiProcessInquiryBodyTests: XCTestCase {
    func testRoundTripSysEx7() {
        let body = MidiCiProcessInquiryBody(command: .capInquiry, filters: ["noteOn": 1])
        let bytes = body.sysEx7Bytes()
        let parsed = MidiCiProcessInquiryBody(sysEx7Bytes: bytes)
        XCTAssertEqual(parsed.command, body.command)
        XCTAssertEqual(parsed.filters?["noteOn"], 1)
    }

    func testRoundTripSysEx8() {
        let body = MidiCiProcessInquiryBody(command: .messageReport, filters: ["clock": 3])
        let bytes = body.sysEx8Bytes()
        let parsed = MidiCiProcessInquiryBody(sysEx8Bytes: bytes)
        XCTAssertEqual(parsed.command, body.command)
        XCTAssertEqual(parsed.filters?["clock"], 3)
    }
}
