# MIDI 2.0 Stack — Swift reference + TypeScript port

Spec-accurate MIDI 2.0 stack in two flavors:
- **Swift**: reference library (`MIDI2`, `MIDI2CI`) plus teaching/interop CLIs (`midi2demo`, `jitterdemo`, `midi2compliance`, `midi2umpd`).
- **TypeScript (`midi2.js` 0.7.0)**: CoreMIDI-free UMP/SysEx/MIDI-CI stack with schedulers, clocks, adapters, and OpenAPI-derived guards.

Canonical sources: `midi2.full.closed.schema.json` and `midi2.full.openapi.json` (shared between Swift and TS); see `docs/conformance-checklist.md` for traceability and gaps.

## Swift coverage (status quo)
- UMP encode/decode: Channel Voice 1.0/2.0, Utility/System/Stream, Function Blocks; reserved-bit validation; PB-VRT baselines.
- SysEx7/8 fragmentation/reassembly with invalid-sequence tests.
- MIDI-CI: Profiles (enable/inquiry/details + PSD), Property Exchange (chunked GET/SET/NOTIFY with compression), CI Device Discovery.
- Stream §5: typed Endpoint Discovery (major/minor/max groups), Stream Configuration requests/replies, Function Block discovery/info, Group Terminal Blocks aggregate.
- Timing: Jitter Reduction clock/timestamp send/receive with `jitterdemo`.
- CLIs: `midi2demo` covers note-on, sysex7/8, flex, CI handshake, stream-config, profiles, PSD, property exchange; `midi2compliance` and `midi2umpd` for validation/ALSA-based experiments.

Swift gaps to close:
- Richer profile configuration reports and GTB negotiation semantics; deeper Function Block descriptors.
- Broader reserved/unsupported status coverage and hardware interop.
- More automated schema/PB-VRT diffs.

## TypeScript coverage (`midi2.js`)
- npm: `@fountain-coach/midi2` (0.7.0).
- UMP encode/decode (Channel Voice 1.0/2.0, System/Utility/Stream/Function Blocks), SysEx7/8 streaming, MIDI-CI envelopes, Flex Data.
- JR-aware schedulers (browser/AudioContext/worker clocks), deterministic ordering, record/replay.
- Adapters: WebAudio, Three.js, Cannon.js.
- OpenAPI-derived runtime guards (from `midi2.full.openapi.json`); DoD/gap plan in `midi2.js/docs/gap-plan.md`.

## Install
### Swift (SwiftPM)
```swift
dependencies: [
    .package(url: "https://github.com/Fountain-Coach/midi2.git", from: "0.7.0")
]
```
Build/test:
```bash
swift test
swift run midi2demo note-on --group 0 --channel 0 60 100
swift run midi2demo sysex8 --group 0 --manufacturer 00,20,33 "01 02 03 04"
swift run midi2demo profiles-demo --profile /org.midi/piano --channel 0
swift run midi2demo pe-demo --resource /clip/title --size 120 --chunk 50
swift run jitterdemo
```

### TypeScript
```bash
cd midi2.js
npm install
npm run ci   # codegen + typecheck + vitest
```
See `midi2.js/README.md` for browser/Node examples and adapters.

## Compliance and docs
- MIDI Association Workbench: `bash midi2-compliance/scripts/run_local.sh` (headless Electron + Playwright); configure fork via `WORKBENCH_FORK_URL`.
- Conformance: `docs/conformance-checklist.md`, `docs/quiet-frame-gap-closure.yaml`.
- Design/DoD: `docs/midi2-stack-essay.md`, `docs/midi2-js-dod.md`, `midi2.js/docs/gap-plan.md`, `AGENTS.md`.
