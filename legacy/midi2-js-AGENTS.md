# midi2.js / AGENTS

## Mission and current coverage
- Cross-browser TypeScript core for MIDI 2.0 UMP + MIDI-CI with no CoreMIDI/DOM dependencies in the core exports.
- Implemented (0.7.0): UMP encode/decode for utility/system/channel voice 1.0 & 2.0 (incl. per-note management/registered/assignable controllers and per-note pitch bend); Flex Data; SysEx7/8 fragmentation + reassembly; MIDI-CI envelopes (discovery, profiles, property exchange with chunking, process inquiry); scheduler with JR-aware clocks + record/replay; streaming decoder that reassembles SysEx and surfaces MIDI-CI; adapters for WebAudio/Three.js/Cannon.js; OpenAPI-derived runtime guards from `midi2.full.openapi.json`.
- Tests: `npm run ci` (codegen + tsc + vitest) covers UMP, SysEx, MIDI-CI helpers, scheduler, and the stream decoder. CI mirrors this in `.github/workflows/midi2-js.yml`.
- Build: `npm run build` (tsup) emits ESM+CJS+types to `dist/`; package is public `@fountain-coach/midi2@0.7.0`.
- Canonical sources: protocol facts must originate from `midi2.full.closed.schema.json` / `midi2.full.openapi.json`. When extracting details from PDF specs, render the relevant pages (e.g., `gs -sDEVICE=png16m -o /tmp/page.png -dFirstPage=N -dLastPage=N M2-104-UM_v1-1-2_UMP_and_MIDI_2-0_Protocol_Specification.pdf`), interpret the bit layout, and update/annotate the JSON schema/OpenAPI accordingly before changing code. Document the source section/page for any derived behaviors.

## Gaps vs DoD (sync with `docs/midi2-js-dod.md` and `midi2.js/docs/gap-plan.md`)
- Protocol: Endpoint/Device Info payload fidelity and GTB semantics still need tightening; reserved/unsupported statuses need explicit handling across decoders. Worker-clock JR projection needs broader coverage.
- MIDI-CI: compression/error/NAK paths and MUID management need negative tests; profile detail/added-removed reports still light; compression paths untested.
- Validation: broaden reserved-bit/range enforcement and malformed stream/flex/CI envelope tests; add oversize SysEx and invalid chunk-order tests.
- Adapters: expand coverage for per-note controllers/pitch-bend range negotiation and disposal safety.
- Tooling/distribution: keep coverage reporting and publish gating in CI; ensure `dist/` is reproducible from a clean lock.
- Docs: keep README, DoD, and gap plan aligned when surface area changes; note schema deltas explicitly.

## Workflow
- Default commands (run from `midi2.js`): `npm run check`, `npm test`, `npm run build`. Vitest here does not support `--runInBand`.
- Add tests alongside new protocol handlers; prefer `Uint32Array`/`Uint8Array` fixtures that mirror JSON Schema/OpenAPI expectations.
- Update `AGENTS.md`, `docs/midi2-js-dod.md`, and `midi2.js/docs/gap-plan.md` when adding/removing protocol surface area or changing public APIs.
- Keep core logic in `src/*` platform-agnostic; adapters stay isolated under `src/adapters/*`.
