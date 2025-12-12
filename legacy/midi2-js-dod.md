# Definition of Done: midi2.js (full spec parity)

The `midi2.js` stack is "done" when all criteria below are satisfied and demonstrated by automated checks.

## Protocol coverage
- UMP encode/decode: all MIDI 2.0 message types (Channel Voice, System Real-Time/Common, SysEx7/8, Flex Data, Jitter Reduction, Stream messages).
- Per-note: management + registered/assignable controllers, per-note pitch/pressure/timbre, attributes.
- RPN/NRPN: absolute and relative.
- MIDI 1.0 compatibility packets.
- Validation: range and reserved-bit checks aligned to the JSON Schema/OpenAPI; rejects malformed packets with useful errors.
- Canonical spec mapping: all normative PDF fields/opcodes mirrored in `midi2.full.closed.schema.json`/`midi2.full.openapi.json` with spec audit closed (no pending rows).

## MIDI-CI
- Universal SysEx7/8 envelopes (scope, SubID1=0x0D, SubID2 variants) encode/decode.
- Discovery: request/reply parsing, MUID management, capability flags, max SysEx.
- Profiles: enable/disable, inquiry/reports, Profile Specific Data framing.
- Property Exchange: chunked set/get/notify, compression, error codes, resource state handling, subscription lifecycle (start/partial/full/notify/end) with flow-control ACK/NAK.
- Process Inquiry: in/out stream identifiers, I/O status.
- ACK/NAK and error handling paths covered.

## Scheduling and clocks
- Scheduler delivers time-ordered events with jitter tolerance; supports browser, AudioContext, and worker/off-main-thread clocks.
- Deterministic record/replay API for captured event sequences.

## Host adapters
- WebAudio: voice allocation, per-note controllers, pitch bend range, channel pressure; safe disposal.
- Three.js: mapping primitives with hooks for custom scene updates; handles per-note lifecycle.
- Cannon.js (or equivalent physics): body creation/removal and impulse mapping; extensible hooks.
- Adapters are optional and side-effect free in core builds.

## Tooling and API surface
- Public API documented (types + helpers) with examples for core + adapters.
- Clear separation: pure protocol core has no DOM/platform references; adapters are thin and optional.
- Packaged outputs: ESM + type declarations.

## Testing and conformance
- Unit tests for every encoder/decoder path, SysEx fragmentation, MIDI-CI envelopes, and scheduler ordering.
- Cross-checks against Swift reference vectors and/or JSON Schema-generated cases.
- Golden tests for MIDI-CI flows (discovery, profiles, property exchange, process inquiry) including chunking.
- CI running lint/type-check + test matrix across supported runtimes (node + browser bundle via headless).

## Examples and demos
- Minimal runnable examples: audio (WebAudio), 3D (Three.js), physics (Cannon.js), and combined stack.
- Snippets showing SysEx7/8 + MIDI-CI framing.

## Quality gates
- No known TODOs for required spec items; gaps tracked with issue references. Spec audit remains at “captured” with no pending rows.
- Versioned releases with CHANGELOG updates.
- Security posture: no outstanding vuln advisories in dependencies that ship to users (dev-only allowances documented).
