import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class ProfileReportsTests: XCTestCase {
    func testAddedRemovedReports() {
        let session = ProfileSession(supportedProfiles: ["/org.midi/piano"]) 
        let ch0 = [Uint4(0)!]
        let added = session.reportAdded(profileId: "/org.midi/piano", target: .channel, channels: ch0)
        XCTAssertEqual(added.command, .addedReport)
        XCTAssertEqual(added.details?["ok"], 1)

        let removed = session.reportRemoved(profileId: "/org.midi/piano", target: .channel, channels: ch0)
        XCTAssertEqual(removed.command, .removedReport)
        XCTAssertEqual(removed.details?["ok"], 1)
    }

    func testAddedRemovedReportsCarryChannelMask() {
        let session = ProfileSession(supportedProfiles: ["/org.midi/piano"])
        let channels = [Uint4(0)!, Uint4(2)!, Uint4(15)!]
        let added = session.reportAdded(profileId: "/org.midi/piano", target: .channel, channels: channels)
        XCTAssertEqual(added.details?["cmL"], 5)
        XCTAssertEqual(added.details?["cmH"], 128)

        let removed = session.reportRemoved(profileId: "/org.midi/piano", target: .channel, channels: channels)
        XCTAssertEqual(removed.details?["cmL"], 5)
        XCTAssertEqual(removed.details?["cmH"], 128)
    }
}
