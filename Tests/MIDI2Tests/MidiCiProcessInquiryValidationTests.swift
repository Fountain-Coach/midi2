import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class MidiCiProcessInquiryValidationTests: XCTestCase {
    func testRejectsFilterValueOutOfRange() {
        // command=messageReport, len=7, payload bytes represent JSON {"x":2}
        let bytes: [UInt8] = [0x02, 0x07, 0x7B, 0x22, 0x78, 0x22, 0x3A, 0x32, 0x7D]
        XCTAssertThrowsError(try MidiCiProcessInquiryBody(validatingSysEx7Bytes: bytes))
    }

    func testRejectsInvalidDeviceIdScopeInSession() {
        let session = ProcessInquirySession(filters: [:], deviceId: 0x10) // invalid
        let reply = session.handle(MidiCiProcessInquiryBody(command: .capInquiry))
        XCTAssertNil(reply)
    }
}
