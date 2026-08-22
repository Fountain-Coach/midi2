<!-- generated: Scripts/generate_runtime_completeness.py -->
# Runtime Completeness Boundary

> Runtime completeness is claimed only for the named, executable Swift and TypeScript core surfaces below. Physical-device interoperability is never inferred from software tests.

Boundary: `owned-core-software-runtime`

## `ump-core` — verified

UMP core encode/decode, MIDI 1 channel voice, MIDI 2 channel voice, system, utility, Flex, SysEx7/SysEx8, and MDS

**Evidence:**
- `Sources/MIDI2`
- `Tests/MIDI2Tests`
- `midi2.js/src`
- `midi2.js/src/__tests__`

## `midi-ci-core` — verified

MIDI-CI discovery, Profile, Process Inquiry, MUID, Property Exchange, compression, chunking, and subscription lifecycle

**Evidence:**
- `Sources/MIDI2CI`
- `Tests/MIDI2Tests`
- `midi2.js/src`
- `midi2.js/src/__tests__`

## `stream-core` — verified

Endpoint, Function Block, Group Terminal Block, Stream Configuration, negotiation, and profile associations

**Evidence:**
- `Sources/MIDI2/Stream`
- `Tests/MIDI2Tests`
- `midi2.js/src/stream-negotiation.ts`
- `midi2.js/src/__tests__`

## `midi-clip-lifecycle` — verified

SMF2CLIP header, DCTPQ/DCS timing, Start/End of Clip boundaries, stable UMP ordering, and maximum-delta chunking

**Evidence:**
- `Sources/MIDI2/MidiClipFile.swift`
- `Tests/MIDI2Tests/MidiClipFileTests.swift`
- `midi2.js/src/midi-clip.ts`
- `midi2.js/src/__tests__/midi-clip.test.ts`

## `jitter-reduction` — verified

JR clock/timestamp encoding, receiver reconstruction, scheduler projection, and deterministic clock tests

**Evidence:**
- `Sources/MIDI2/System`
- `Tests/MIDI2Tests/System`
- `midi2.js/src/jitter.ts`
- `midi2.js/src/__tests__/jitter.test.ts`

## `negative-validation` — verified

Reserved, unsupported, malformed, and bounded-value rejection for the covered core decoders

**Evidence:**
- `Tests/MIDI2Tests/NegativeTests`
- `midi2.js/src/__tests__/negative.test.ts`
- `docs/negative-test-matrix.md`

## `modeled-frontier-runtime` — verified

Compatibility selection, MIDI-CI transaction failure, profile channel allocation, Property Exchange resource errors, and software UMP ordering/reserved-value validation

**Evidence:**
- `Sources/MIDI2CI/ModeledFrontiers.swift`
- `Sources/MIDI2/UmpOrderingValidator.swift`
- `Tests/MIDI2Tests/ModeledFrontierTests.swift`
- `midi2.js/src/modeled-frontiers.ts`
- `midi2.js/src/__tests__/modeled-frontiers.test.ts`
- `docs/normative-behavior.json`

## `optional-host-adapters` — out-of-scope

Host-specific adapter negotiation and worker-only timing environments

**Evidence:**
- `midi2.js/src/adapters`
- `midi2.js/src/__tests__/jitter.worker.test.ts`

## `hardware-interoperability` — excluded

Physical MIDI 2.0 device interoperability, MIDI-CI exchange with external hardware, and hardware JR synchronization

**Evidence:**
- `docs/claims.json`
- `docs/conformance-checklist.md`

## Claim rule

The named core software surfaces may be claimed runtime-complete only when every required entry is `verified` and the Swift and TypeScript validation gates pass. `out-of-scope` is not evidence of implementation. Hardware remains `excluded` and cannot be claimed from these results.
