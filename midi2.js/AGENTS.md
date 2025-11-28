# midi2.js / AGENTS

## Mission and current coverage
- Cross-browser TypeScript core for MIDI 2.0 UMP + MIDI-CI with no CoreMIDI/DOM dependencies in the core exports.
- Implemented: UMP encode/decode for utility, system, MIDI 1.0 channel voice, and MIDI 2.0 channel voice (incl. per-note management/registered/assignable controllers); Flex Data for tempo/time signature/key signature/chord/text/lyric/ruby; SysEx7/8 fragmentation + reassembly; MIDI-CI envelopes (discovery, endpoint inquiry, profiles, property chunking, process inquiry); scheduler with jitter tolerance + record/replay; streaming decoder that reassembles SysEx and surfaces MIDI-CI; demo adapters for WebAudio, Three.js, Cannon.js.
- Tests: `npm test` (vitest) currently passes 57 cases covering UMP, SysEx, MIDI-CI helpers, scheduler, and the stream decoder. `npm run check` runs TypeScript. CI mirrors this in `.github/workflows/midi2-js.yml`.
- Build: `npm run build` emits `dist/`; package remains private `0.0.1` and does not ship artifacts by default.

## Gaps vs DoD (sync with `docs/midi2-js-dod.md` and `midi2.js/docs/gap-plan.md`)
- Protocol: stream config/function block UMP covered; still missing group/terminal blocks, jitter reduction semantics wired to the scheduler, per-note pitch/pressure/timbre helpers, and MIDI 1.0 SysEx/down-conversion beyond channel voice.
- MIDI-CI: discovery/profile/property/process flows lack compression/state/error handling, MUID management, and ACK/NAK paths; property exchange helpers are limited to chunk framing.
- Validation: reserved-bit and range enforcement is partial; negative tests exist but do not yet cover malformed stream/flex/CI variants beyond current cases.
- Tooling/distribution: no dual ESM/CJS bundle or published `dist`; committed `node_modules` should be cleaned before release; coverage reporting is absent.
- Adapters: minimal demos only; per-note controllers, pitch-bend range negotiation, and disposal safety remain to be hardened.
- Docs: README and docs must track coverage as gaps close; keep DoD and the gap plan aligned with implemented features.

## Workflow
- Default commands (run from `midi2.js`): `npm run check`, `npm test`, `npm run build`. Vitest here does not support `--runInBand`.
- Add tests alongside new protocol handlers; prefer `Uint32Array`/`Uint8Array` fixtures that mirror JSON Schema/OpenAPI expectations.
- Update `AGENTS.md`, `docs/midi2-js-dod.md`, and `midi2.js/docs/gap-plan.md` when adding/removing protocol surface area or changing public APIs.
- Keep core logic in `src/*` platform-agnostic; adapters stay isolated under `src/adapters/*`.
