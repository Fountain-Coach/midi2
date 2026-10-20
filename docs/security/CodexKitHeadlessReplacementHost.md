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
