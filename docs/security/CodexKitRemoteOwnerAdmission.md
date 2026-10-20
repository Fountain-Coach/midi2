# CodexKit remote invocation admission — R38 safety boundary

**Status:** Source-only default-deny guard, NOT a deployed owner-authenticated model session.

A Codex provider being logged in on the host does not prove that a remote
MIDI2 device is a trusted, consenting writer. Standard MIDI-CI discovery and
the advertised profile remain available without authorizing any Codex request.

Until the host has a real independent, cryptographically verified owner/session
admission boundary, `codexkitumpd` returns a terminal `refused` lifecycle for
all executable Chapter 149 operations. The reply does not echo the incoming
prompt or auth/token-shaped payload fields.

Future admissible proof: identify the exact paired device and current writer
session, verify owner consent and only the approved capability, bind the
verification to the actual protected transport and correlation identity,
bound duration/replay/revocation, protect Composer private text in transit,
and prove terminal/disconnect refusal. A claimed MUID, IP address, advertised
instrument profile, arbitrary session ID or host-side Codex login are not
writer admission.

This is a prerequisite to Reframe R38 First Session, *not* a reason to deploy
a new `auth.fountain.coach` domain or the general-purpose auth provisioner.
The latter remains independently valuable and deferred.

## Verification

- `swift test --filter RemoteInvocationGateTests`: all three focused tests
  pass on macOS (discovery, refusals, wrong instrument/topic).
- Linux responder compilation and runtime refusal over actual RTP-MIDI2 are
  not established by these Mac tests and must be verified before deployment.
- Deployed service, credentials, publisher, reader, manuscripts and iPad
  signing are unchanged by this source-only patch.
