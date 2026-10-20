# R38 peer-signed host admission (Ubuntu-built candidate)

The existing R38 MIDI2 pairing transcript now has an opt-in, public-key
signature proof in `CodexKitAdmission`. The iPad's **existing**
device-only Keychain identity yields a deterministic, domain-separated
Ed25519 signing key. Only its 32-byte public key needs to be enrolled
on a replacement host. The identity and private signing key stay on
the iPad; this is not a credential-copying operation.

A replacement CodexKit host sets `R38_PAIRING_AUTH_MODE=signed-v1` and
must have these independently owner-installed, root-owned regular files:

- `/etc/fountaincoach/r38-host-ed25519.key`: 32-byte host-local signing
  seed, base64-encoded; permissions no broader than 0600.
- `/etc/fountaincoach/r38-device-ed25519.pub`: 32-byte iPad signing
  public key, base64-encoded; not group/world writable.

In signed mode the host signs the exact ephemeral pairing offer, and
verifies the iPad's response using ONLY its enrolled device public key.
No fallback to the legacy shared-secret file occurs. An unrecognized
explicit authentication mode refuses. The old default mode remains
unchanged for the existing Ubuntu host until it has been deliberately
migrated. Signature verification does not bypass CodexKit's ephemeral
session binding, request correlation, TTL or authorization scope.

**Owner enrollment remains a separate prerequisite.** The iPad must
possess and verify the *correct host public signing key*, through the
existing Chapter 97 owner-signed bootstrap/admission contract. A
self-reported host key is not trusted. Host file presence is not a
completed owner approval, and a signed offer by itself is not a model
turn or manuscript grant.

## Acceptance and provenance

- macOS: `swift test --filter R38PeerSignedPairingTests`: 2/2 PASS.
- Ubuntu Mac mini (isolated source at
  `/home/benedikt/r38-peer-signed-pairing-build-20261020`):
  `swift test --filter R38PeerSignedPairingTests`: 2/2 PASS.
- Ubuntu: `swift build -c release --product codexkitumpd`: PASS.
- Candidate executable SHA-256:
  `5124b2d82ae521ffd43fe38cb007e5fa773b07085442b567d3c9119412aa0dcf`.
- Swift 6.3 compatibility: the unrelated `midi2compliance`
  stderr write now uses `FileHandle.standardError`.

**No compilation on Hetzner.** No active Ubuntu services were replaced.
Hetzner recovery CodexKit and Userland remain inactive pending owner
registration, independently verified key pins and end-to-end real-iPad
acceptance. This candidate is not a production-activation receipt.
