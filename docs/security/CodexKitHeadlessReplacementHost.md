# CodexKit headless replacement host - R38

20 October 2026. A Hetzner Ubuntu 24.04 replacement started the shipped
CodexKit executable and reached RTP-MIDI2 initialization but exited during
unconditional ALSA sequencer initialization. The cloud host had a /dev/snd/seq
node, but no /usr/share/alsa/alsa.conf, so libasound could not open the
default sequencer. This failure was independent of OpenAI authentication.

Use --rtp-only on explicitly selected software-only replacement Linux hosts.
The flag suppresses ump_alsa_open() but leaves the released RTP-MIDI2/SysEx8
transport, CodexKit instrument, encrypted pair admission, Codex App Server
boundary, and refusal policy unchanged. The original Ubuntu systemd unit
omits the flag and retains its ALSA behavior.

Acceptance requires a real replacement-host UDP listener, same
unauthenticated MIDI-CI inquiry response, refusal of unapproved
codex/turn.submit, and later a separately authenticated OpenAI turn
after approved device enrollment. Startup alone is not an approved
disaster-recovery conversation.

No GitHub CI or workflows added.

## Independent off-host profile check

The freshly built Linux x86-64 candidate from commit aed86a1
(SHA-256 226caa7346d0dfaf5ef6248c3d44aa132ac2e4721a6638b7a1b89b2cf92d9271)
was copied as a separate release into the pre-existing Hetzner recovery
Volume without altering the Ubuntu service. Running it with --rtp-only
and a disposable port created a real UDP listener with no ALSA dependency.

The Mac ran the explicit opt-in test
R38_REMOTE_CODEX_HOST=65.109.14.71 R38_REMOTE_CODEX_PORT=65486
swift test --filter R38RemoteHeadlessCodexKitTests.

Actual remote MIDI-CI inquiry/response 1/1 PASS (0.089s):
R38_HETZNER_HEADLESS_REMOTE_MIDI_CI_PROFILE_PASS.
This was a read-only public instrument profile, never an authenticated
model turn or writer grant. The short-lived process uses a deadline and
is not a deployed service.
