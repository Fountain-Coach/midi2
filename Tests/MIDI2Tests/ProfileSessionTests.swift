import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class ProfileSessionTests: XCTestCase {
    func testEnableDisableInquiry() {
        let session = ProfileSession(supportedProfiles: ["/org.midi/piano"])
        let ch0: [Uint4] = [Uint4(0)!]

        // Enable
        let enable = MidiCiProfilesBody(command: .setOn, profileId: "/org.midi/piano", target: .channel, channels: ch0)
        let en = session.handle(enable)
        XCTAssertEqual(en.count, 1)
        XCTAssertEqual(en.first?.command, .enabledReport)
        XCTAssertEqual(en.first?.details?["ok"], 1)

        // Inquiry should report supported=1, enabled=1
        let inq = MidiCiProfilesBody(command: .inquiry, profileId: "/org.midi/piano", target: .channel, channels: ch0)
        let rep = session.handle(inq)
        XCTAssertEqual(rep.count, 1)
        XCTAssertEqual(rep.first?.command, .reply)
        XCTAssertEqual(rep.first?.details?["supported"], 1)
        XCTAssertEqual(rep.first?.details?["enabled"], 1)

        // Disable
        let disable = MidiCiProfilesBody(command: .setOff, profileId: "/org.midi/piano", target: .channel, channels: ch0)
        let dis = session.handle(disable)
        XCTAssertEqual(dis.count, 1)
        XCTAssertEqual(dis.first?.command, .disabledReport)

        // Inquiry now enabled=0
        let rep2 = session.handle(inq)
        XCTAssertEqual(rep2.first?.details?["enabled"], 0)
    }

    func testUnsupportedEnableYieldsDisabledReport() {
        let session = ProfileSession(supportedProfiles: [])
        let ch0: [Uint4] = [Uint4(0)!]
        let enable = MidiCiProfilesBody(command: .setOn, profileId: "/unknown", target: .channel, channels: ch0)
        let en = session.handle(enable)
        XCTAssertEqual(en.first?.command, .disabledReport)
        XCTAssertEqual(en.first?.details?["ok"], 0)
    }

    func testEnableDisableReportsCarryChannelMask() {
        let session = ProfileSession(supportedProfiles: ["/org.midi/piano"])
        let channels: [Uint4] = [Uint4(1)!, Uint4(9)!] // cmL bit1, cmH bit1

        let enable = MidiCiProfilesBody(command: .setOn, profileId: "/org.midi/piano", target: .channel, channels: channels)
        let enabled = session.handle(enable)
        XCTAssertEqual(enabled.first?.command, .enabledReport)
        XCTAssertEqual(enabled.first?.details?["ok"], 1)
        XCTAssertEqual(enabled.first?.details?["cmL"], 2)
        XCTAssertEqual(enabled.first?.details?["cmH"], 2)

        let disable = MidiCiProfilesBody(command: .setOff, profileId: "/org.midi/piano", target: .channel, channels: channels)
        let disabled = session.handle(disable)
        XCTAssertEqual(disabled.first?.command, .disabledReport)
        XCTAssertEqual(disabled.first?.details?["ok"], 1)
        XCTAssertEqual(disabled.first?.details?["cmL"], 2)
        XCTAssertEqual(disabled.first?.details?["cmH"], 2)
    }
}
