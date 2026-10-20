# R38 private Composer session codec — source acceptance

**2026-10-20 — source library only; no approved pairing or live model turn yet.**

## Reuse, not an authentication provider

The real Ubuntu `codexkitumpd` service is already authenticated to
OpenAI via its existing host-side Codex app-server. MIDI-CI merely discovers
its instrument; it does **not** authenticate the iPad, approve the writer,
or protect text sent as RTP-MIDI2 SysEx8/Flex.

The R35 `FountainAuthHostKit` owner decision (OS-verified `SO_PEERCRED`
and explicit approval) remains the existing local operator authority.
FountainAuthKit manages independently authorized grants. Neither shall
be replaced by client-supplied fields. The owner enrollment and
session-key provisioner is **not implemented** here.

## What the codec actually does

`CodexKitAdmission.CodexKitSealedSession` accepts precisely 32 bytes
of already-approved private session key material via a host/Keychain adapter.
It DOES NOT create or trust that approval. HKDF derives distinct AES-256-GCM
traffic keys by direction and session identity. Each sealed packet authenticates
the exact instrument, expiry, session, correlation, execution, sequence and
direction. An actor refuses reused or stale sequence counters, forgery,
wrong direction, expired/invalidated sessions and oversized payloads.
Its only supported incoming operation is `codex/turn.submit`, not
approval, code execution, tool invocation or manuscript modification.

Private Composer text and replies are encrypted, not copied into public
routing envelopes or telemetry. The wire carries a sealed body and
non-secret routing metadata. A future host admission adapter must
enforce verified physical peer/session binding before constructing this
actor, and the iPad must never derive a key from an unchecked MIDI-CI
profile or a self-asserted owner identity.

## Test and current limits

Mac `swift test --filter CodexKitAdmissionTests` checks:
- authenticated text/reply roundtrip without plaintext on the wire;
- a mismatched key, tampered correlation/ciphertext, and wrong direction;
- replay, expiry and disconnect;
- unsupported Codex operations, invalid issuer material/instrument;
- the separate public discovery and default-refuse gate.

**Not established:** R35-to-iPad key delivery and physical owner approval,
durable revocation/counter state across host crashes, packet fragment/MTU
handling, injection into the operating responder, and one real iPad reply.
This module is source-only and should not be used as a production issuer.

No production services, R36 pilot, reader, published content, signing,
Apple entitlement, or `auth.fountain.coach` infrastructure are changed.
