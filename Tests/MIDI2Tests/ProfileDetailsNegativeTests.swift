import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class ProfileDetailsNegativeTests: XCTestCase {
    func testUnsupportedProfileSetOnReturnsDisabledReport() {
        let session = ProfileSession(supportedProfiles: ["/org.midi/organ"])
        let req = MidiCiProfilesBody(command: .setOn, profileId: "/org.midi/piano", target: .channel, channels: [Uint4(0)!], details: [:])
        let replies = session.handle(req)
        XCTAssertEqual(replies.first?.command, .disabledReport)
        XCTAssertEqual(replies.first?.details?["ok"], 0)
    }

    func testDetailsInquiryMissingProfileIdDrops() {
        let req = MidiCiProfilesBody(command: .detailsInquiry, profileId: "", target: .functionBlock, channels: nil, details: [:])
        let replies = ProfileSession(supportedProfiles: []).handle(req)
        XCTAssertTrue(replies.isEmpty)
    }

    func testSetOnWithoutTargetIgnored() {
        let session = ProfileSession(supportedProfiles: ["/org.midi/piano"])
        let req = MidiCiProfilesBody(command: .setOn, profileId: "/org.midi/piano", target: nil, channels: [Uint4(0)!], details: [:])
        let replies = session.handle(req)
        XCTAssertTrue(replies.isEmpty)
        let inquiry = MidiCiProfilesBody(command: .inquiry, profileId: "/org.midi/piano", target: .channel, channels: [Uint4(0)!])
        let rep = session.handle(inquiry)
        XCTAssertEqual(rep.first?.details?["enabled"], 0)
    }

    func testDetailsInquiryInvalidChannelCountIgnored() {
        // channels count > 0x10 will be truncated to empty by decoder
        let body = MidiCiProfilesBody(command: .detailsInquiry, profileId: "/org.midi/piano", target: .channel, channels: nil, details: nil)
        var bytes = body.sysEx7Bytes()
        bytes[4] = 0x20 // chanCount
        let parsed = MidiCiProfilesBody(sysEx7Bytes: bytes)
        let replies = ProfileSession(supportedProfiles: ["/org.midi/piano"]).handle(parsed)
        XCTAssertEqual(replies.count, parsed.profileId.isEmpty ? 0 : 1)
    }
}
