# midi2.js Gap Plan (toward DoD)

> **📦 ARCHIVED**: This document is retained for historical reference. Current gap tracking is maintained in:
> - [`docs/gap-closure-tracker.md`](../docs/gap-closure-tracker.md) - Active gap tracking with status updates
> - [`docs/spec-compliance-dashboard.md`](../docs/spec-compliance-dashboard.md) - Current compliance metrics
>
> **Last Active Version**: 0.7.0 | **Current Version**: 0.9.0

Snapshot status (0.7.0 plan):
- ✅ UMP encode/decode (utility/system/channel voice 1.0 & 2.0, stream/function blocks incl. process inquiry 0x03), Flex Data, SysEx7/8 fragment/reassemble.
- ✅ MIDI-CI envelopes (discovery, profiles, property exchange with chunking, process inquiry) and OpenAPI-derived runtime guards.
- ✅ Scheduler with JR-aware clocks + record/replay; adapters for WebAudio/Three.js/Cannon.js.
- ✅ CI: `npm run ci` (codegen + tsc + vitest) and publishable `dist/` via tsup.
- 🚧 DoD coverage still partial; core gaps below.

Priority gaps (aligns to docs/midi2-js-dod.md):

1) Protocol coverage
- Endpoint/Device Info payload fidelity and GTB semantics: tighten encode/decode and add vectors.
- Reserved/unsupported statuses: unify placeholder handling across decoders; broaden negative tests.
- Worker-clock JR projection: add coverage for off-main-thread clocks and jitter mapping.

2) MIDI-CI flows
- Profile detail/added-removed reports and compression/error/NAK paths need negative tests; MUID management coverage is thin. Compression/error/NAK paths remain untested.

3) Scheduling and adapters
- Adapters: add per-note controllers/pitch-bend range negotiation and disposal safety tests.
- Deterministic replay: broaden fixtures across multi-group streams.

4) Validation and negative tests
- Expand reserved-bit/range checks for stream/flex/CI envelopes; add oversize SysEx and invalid chunk-order tests.
- Ensure OpenAPI guard regeneration is part of CI (fail on drift).

5) Tooling and distribution
- Keep coverage reporting in CI; validate `npm pack` output; ensure `dist/` is reproducible from clean lock and codegen outputs.

Next execution steps (suggested order)
- Harden stream Endpoint/Device Info + GTB semantics with golden vectors.
- Add schema validation for property exchange JSON and negative tests for CI detail/added-removed reports.
- Broaden reserved/unsupported status handling and negative tests across decoders.
- Add worker-clock JR projection tests; extend adapters for per-note controllers and pitch-bend negotiation.
- Add `npm pack` verification to CI and ensure codegen guards are regenerated in the pipeline.
