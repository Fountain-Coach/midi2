import ArgumentParser
import MIDI2
import MIDI2CI

struct ProfilesDemo: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "profiles-demo",
        abstract: "Simulate MIDI-CI Profile enable/disable and inquiry",
        discussion: "Demonstrates enabling a profile on a channel, inquiring status, and disabling again."
    )

    @Option(name: .long, help: "Profile ID")
    var profile: String = "/org.midi/piano"

    @Option(name: .long, help: "Channel (0-15)")
    var channel: Int = 0

    func run() throws {
        guard let ch = Uint4(UInt8(channel)) else { throw ValidationError("Invalid channel") }
        let session = ProfileSession(supportedProfiles: [profile])
        let chs = [ch]

        // Enable
        let en = MidiCiProfilesBody(command: .setOn, profileId: profile, target: .channel, channels: chs)
        for r in session.handle(en) {
            print("reply: \(r.command) details=\(r.details ?? [:])")
        }
        // Inquiry
        let iq = MidiCiProfilesBody(command: .inquiry, profileId: profile, target: .channel, channels: chs)
        for r in session.handle(iq) {
            print("reply: \(r.command) details=\(r.details ?? [:])")
        }
        // Disable
        let off = MidiCiProfilesBody(command: .setOff, profileId: profile, target: .channel, channels: chs)
        for r in session.handle(off) {
            print("reply: \(r.command) details=\(r.details ?? [:])")
        }
        // Inquiry again
        for r in session.handle(iq) {
            print("reply: \(r.command) details=\(r.details ?? [:])")
        }
    }
}

