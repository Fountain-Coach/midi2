import XCTest
@testable import MIDI2

final class MidiCiProcessInquiryNegativeTests: XCTestCase {
    func testInvalidCommandRejected() {
        let bytes: [UInt8] = [0x7F, 0x00]
        XCTAssertThrowsError(try MidiCiProcessInquiryBody(validatingSysEx7Bytes: bytes))
        XCTAssertThrowsError(try MidiCiProcessInquiryBody(validatingSysEx8Bytes: bytes))
    }

    func testInvalidLengthRejected() {
        let bytes: [UInt8] = [0x00, 0x05, 0x01] // length=5 but only 1 byte follows
        XCTAssertThrowsError(try MidiCiProcessInquiryBody(validatingSysEx7Bytes: bytes))
    }
}
