import MIDI2

// Construct a MIDI-CI profile inquiry and parse the reply.
let requestBody = MidiCiProfilesBody(
    command: .inquiry,
    profileId: "com.example.profile",
    target: .channel,
    channels: [Uint4(0)!]
)
let requestEnv = MidiCiEnvelope(scope: .nonRealtime, subId2: 0x72, version: 1, body: .profiles(requestBody))
let requestPayload = requestEnv.sysEx7Payload()

let parsed = try MidiCiEnvelope(sysEx7Payload: requestPayload)
if case let .profiles(body) = parsed.body {
    let replyBody = MidiCiProfilesBody(
        command: .reply,
        profileId: body.profileId,
        target: body.target,
        channels: body.channels
    )
    let replyEnv = MidiCiEnvelope(scope: .nonRealtime, subId2: 0x72, version: 1, body: .profiles(replyBody))
    let replyPayload = replyEnv.sysEx7Payload()
    print(replyPayload.count)
}
