import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class ProfileDetailsTests: XCTestCase {
    func testDetailsInquiryIncludesVersionAndChannelMask() {
        let session = ProfileSession(supportedProfiles: ["/org.midi/piano"])
        let channels = [Uint4(0)!, Uint4(2)!, Uint4(15)!]
        let req = MidiCiProfilesBody(command: .detailsInquiry, profileId: "/org.midi/piano", target: .channel, channels: channels)
        let rep = session.handle(req)
        XCTAssertEqual(rep.count, 1)
        let details = rep.first?.details
        XCTAssertEqual(details?["ver"], 1)
        // mask: bits 0,2,15 set -> cmL = (1<<0)|(1<<2)=0b00000101=5, cmH=(1<<(15-8))=1<<7=128
        XCTAssertEqual(details?["cmL"], 5)
        XCTAssertEqual(details?["cmH"], 128)
    }

    func testDetailsInquiryUnsupportedProfileShowsSupportedZero() {
        let session = ProfileSession(supportedProfiles: [])
        let req = MidiCiProfilesBody(command: .detailsInquiry, profileId: "/org.midi/piano", target: .channel, channels: [Uint4(1)!])
        let rep = session.handle(req)
        XCTAssertEqual(rep.first?.details?["supported"], 0)
        XCTAssertEqual(rep.first?.details?["enabled"], 0)
    }

    func testDetailsReplyStoresLastDetails() {
        let session = ProfileSession(supportedProfiles: ["/org.midi/piano"], psdCapableProfiles: [])
        let inquiry = MidiCiProfilesBody(command: .detailsInquiry, profileId: "/org.midi/piano", target: .channel, channels: [Uint4(0)!])
        let replies = session.handle(inquiry)
        XCTAssertEqual(replies.first?.details?["psd"], 0)
        XCTAssertNotNil(session.lastDetails(for: .channel, channels: [Uint4(0)!]))
    }
}
