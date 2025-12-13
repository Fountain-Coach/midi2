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
}
