import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class ProcessInquirySessionTests: XCTestCase {
    func testCapabilityInquiryFlow() {
        let session = ProcessInquirySession(filters: ["noteOn": 1, "clock": 1])
        let inq = MidiCiProcessInquiryBody(command: .capInquiry)
        let rep = session.handle(inq)
        XCTAssertEqual(rep?.command, .capReply)
        XCTAssertEqual(rep?.filters?["noteOn"], 1)
        XCTAssertEqual(rep?.filters?["clock"], 1)
    }

    func testMessageReportFlow() {
        let session = ProcessInquirySession(filters: ["sysex": 2])
        let rep1 = session.handle(MidiCiProcessInquiryBody(command: .messageReport, filters: ["sysex": 2]))
        XCTAssertEqual(rep1?.command, .messageReportReply)
        XCTAssertEqual(rep1?.filters?["sysex"], 2)
        let rep2 = session.handle(MidiCiProcessInquiryBody(command: .endReport))
        XCTAssertNil(rep2) // end report has no reply
    }

    func testMessageReportClampsAndDropsUnsupported() {
        let session = ProcessInquirySession(filters: ["sysex": 1, "noteOn": 1])
        let reply = session.handle(MidiCiProcessInquiryBody(command: .messageReport, filters: ["sysex": 3, "clock": 2]))
        XCTAssertEqual(reply?.command, .messageReportReply)
        // sysex clamped to supported level (1), clock dropped (unsupported)
        XCTAssertEqual(reply?.filters?["sysex"], 1)
        XCTAssertNil(reply?.filters?["clock"])
    }

    func testInvalidDeviceIdNoReply() {
        let session = ProcessInquirySession(filters: ["sysex": 1], deviceId: 0x10) // invalid scope
        let reply = session.handle(MidiCiProcessInquiryBody(command: .capInquiry))
        XCTAssertNil(reply)
    }
}
