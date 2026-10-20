import XCTest
import MIDI2
import MIDI2CI
import MIDI2Transports

/// Only runs when an explicit test host is provided. Read-only MIDI-CI:
/// no writer enrollment, model request, credentials, or manuscript access.
final class R38RemoteHeadlessCodexKitTests: XCTestCase {
    func testRemoteCodexKitSoftwarePeerAdvertisesItsGovernedProfile() throws {
        guard let host = ProcessInfo.processInfo.environment["R38_REMOTE_CODEX_HOST"],
              let portText = ProcessInfo.processInfo.environment["R38_REMOTE_CODEX_PORT"],
              let port = UInt16(portText) else {
            throw XCTSkip("No isolated R38 remote test host configured")
        }
        let observed = expectation(description: "Remote CodexKit MIDI-CI profile reply")
        observed.assertForOverFulfill = false
        let session = RTPMidiSession(localName: "R38 Mac read-only recovery verifier",
                                     enableDiscovery: false, enableCINegotiation: true)
        session.onReceiveUMP = { words in
            guard words.count.isMultiple(of: 4) else { return }
            let packets = stride(from: 0, to: words.count, by: 4).compactMap {
                UmpPacket128(words: Array(words[$0..<($0 + 4)]))
            }
            guard packets.count == words.count / 4,
                  let message = DataMessageBody(sysex8Packets: packets),
                  case let .sysex8(manufacturer, payload) = message,
                  manufacturer == [0x7E],
                  let envelope = try? MidiCiEnvelope(sysEx8Payload: payload),
                  case .profiles(let profile) = envelope.body,
                  profile.command == .reply,
                  profile.profileId == "fountaincoach.codexkit@0.1.0",
                  profile.details?["supported"] == 1 else { return }
            observed.fulfill()
        }
        try session.open()
        try session.waitUntilReady(timeout: 8)
        defer { try? session.close() }
        try session.connect(host: host, port: port)
        let inquiry = MidiCiEnvelope(
            scope: .nonRealtime, subId2: 0x72,
            body: .profiles(MidiCiProfilesBody(
                command: .inquiry, profileId: "fountaincoach.codexkit@0.1.0",
                target: .functionBlock)))
        let words = try DataMessageBody.sysex8(
            manufacturerID: [0x7E], data: inquiry.sysEx8Payload())
            .umpPackets(group: Uint4(0)!).flatMap(\.words)
        try session.send(umpWords: words)
        wait(for: [observed], timeout: 12)
        print("R38_HETZNER_HEADLESS_REMOTE_MIDI_CI_PROFILE_PASS")
    }
}
