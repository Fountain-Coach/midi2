# midi2.js Gap Plan (toward DoD)

Current status:
- ✅ Flex text/ruby/chord encode/decode fixes and validation tests (see src/ump.ts and src/__tests__/ump.test.ts).
- ✅ Basic UMP/channel voice, utility, MIDI 1.0 CV, SysEx7/8 fragment/reassemble, MIDI-CI envelope wrapper, scheduler, and demo adapters.
- ✅ Scheduler record/replay with tests.
- 🚧 DoD coverage still partial; core gaps tracked below.

Priority gaps (aligns to docs/midi2-js-dod.md):

1) Protocol coverage
- Stream config and function block UMP (mt=0xF) encode/decode added; still missing Group/Terminal blocks, endpoint discovery payload fidelity, and process inquiry opcodes.
- Per-note controllers: missing pitch/pressure/timbre/attributes helpers and decode paths.
- Jitter Reduction: synchronizer + scheduler projection exist; still need deeper integration with worker clocks and stream timing semantics.
- MIDI 1.0 interoperability: byte-stream→UMP converter covers channel voice/system-common/realtime/SysEx7; 2.0→1.0 down-conversion covers channel voice + SysEx7/8 and MIDI-CI (universal SysEx) with running-status emission; still need richer mapping for CI envelopes and validation.

2) MIDI-CI flows
- Discovery, profiles, property exchange (chunking/compression/state/errors), and process inquiry envelopes are not implemented.
- No MUID management or error/NAK paths; only envelope framing/unframing is present.

3) Scheduling and adapters
- Record/replay exists; still need worker/off-main-thread clock tests and jitter-reduction mapping.
- Adapters do not cover per-note controllers, pitch-bend range negotiation, or disposal safety.
- No host separation: core exports adapters directly; consider packaging pure core + optional adapters.

4) Validation and negative tests
- Decode paths accept malformed packets (no reserved-bit checks; limited range validation).
- No negative tests for stream/flex/CI envelopes beyond the new SysEx and range cases.
- SysEx limits: add tests for oversize payloads and invalid chunk ordering.

5) Tooling and distribution
- Package is private 0.0.1 with no built `dist/` artifacts checked; no bundler/dual ESM+CJS output.
- No JS CI workflow (lint/type-check/test/browser bundle). No coverage reporting.
- `node_modules/` is committed; replace with clean lock + build pipeline.

Next execution steps (suggested order)
- Add decode validation for current UMP types (range/reserved bits) and negative tests.
- Implement remaining Flex data variants and per-note controllers; add vectors.
- Scaffold MIDI-CI discovery/profile/property/process inquiry envelopes and golden tests.
- Introduce record/replay in scheduler and worker-clock test coverage.
- Stand up CI (tsc --noEmit, vitest, coverage) and prepare publishable build outputs.
