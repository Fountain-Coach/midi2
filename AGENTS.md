# AGENTS

## Scope and standards
- Repository spans the Swift MIDI 2.0 reference stack and the CoreMIDI-free `midi2.js` TypeScript port. Treat `midi2.js` as the browser/runtime-facing library; keep it decoupled from platform APIs.
- Definition of Done for `midi2.js` lives in `docs/midi2-js-dod.md`; design intent is outlined in `docs/midi2-stack-essay.md` and the normative schema/OpenAPI at the repo root.
- Local gates to run before pushing `midi2.js` changes: `npm run check` and `npm test` (working directory `midi2.js`). CI workflow `.github/workflows/midi2-js.yml` mirrors this.
- Keep documentation in sync: update this file, `midi2.js/AGENTS.md`, and the gap plan when protocol coverage or public APIs shift.

## Active workstreams
- `midi2.js`: see `midi2.js/AGENTS.md` for day-to-day expectations, current gaps, and DoD alignment.
- `midi2demo` CLI (Swift): goal is a teaching CLI that round-trips UMP, SysEx7/8, Flex Data, and MIDI-CI flows. Expected commands: `note-on`, `sysex7/8`, `flex`, `ci-handshake`, and `inspect`, with ArgumentParser wiring, integration tests, and README/man-page coverage.

## Maintenance rules
- Prefer ESM + type-safe exports; avoid platform-specific globals in the core library.
- Keep release notes and conformance artifacts current when closing DoD items; avoid introducing new vendored artifacts (e.g., `node_modules` or built `dist/`) without a clear reason.
- When adding protocol surface area, mirror coverage in tests and update `docs/midi2-js-dod.md` and `midi2.js/docs/gap-plan.md`.

## Recent midi2.js history (for audit)
- 40caf31 — Flex Data coverage expanded (key signature, lyric/text handling).
- 56541bd — Utility MT=0 and MIDI 1.0 channel voice encode/decode; Flex tempo/time signature added.
- 0b07551 — Initial `midi2.js` drop: UMP helpers, SysEx7/8, MIDI-CI envelopes, scheduler, adapters, and DoD doc.
