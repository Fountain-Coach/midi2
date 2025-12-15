# AGENTS

> **📦 ARCHIVED**: This document is retained for historical reference. The current maintenance policy is in:
> - [`AGENTS.md`](../AGENTS.md) - Comprehensive repository maintenance policy
> - [`MAINTENANCE.md`](../MAINTENANCE.md) - Practical maintenance procedures
> - [`CONTRIBUTING.md`](../CONTRIBUTING.md) - Development workflow and guidelines
>
> **Superseded**: December 2025

## Scope and standards
- Repository spans the Swift MIDI 2.0 reference stack and the CoreMIDI-free `midi2.js` TypeScript port. Treat `midi2.js` as the browser/runtime-facing library; keep it decoupled from platform APIs.
- Definition of Done for `midi2.js` lives in `docs/midi2-js-dod.md`; design intent is outlined in `docs/midi2-stack-essay.md` and the normative schema/OpenAPI at the repo root.
- Local gates to run before pushing `midi2.js` changes: `npm run check` and `npm test` (working directory `midi2.js`). CI workflow `.github/workflows/midi2-js.yml` mirrors this.
- Keep documentation in sync: update this file, `midi2.js/AGENTS.md`, and the gap plan when protocol coverage or public APIs shift. When code moves ahead of the spec PDFs, reconcile `midi2.full.closed.schema.json` / `midi2.full.openapi.json` or document the delta and source page.
- When using PDF specs to inform implementation, extract the relevant pages to images and map them back to the canonical JSON artifacts (`midi2.full.closed.schema.json`, `midi2.full.openapi.json`). Any protocol facts derived from PDFs must be reflected in those JSON sources or documented as a pending delta; do not land code based on PDFs alone without updating/annotating the canonical sources.

## Active workstreams
- `midi2.js`: see `midi2.js/AGENTS.md` for day-to-day expectations, current gaps, and DoD alignment.
- `midi2demo` CLI (Swift): goal is a teaching CLI that round-trips UMP, SysEx7/8, Flex Data, and MIDI-CI flows. Expected commands: `note-on`, `sysex7/8`, `flex`, `ci-handshake`, and `inspect`, with ArgumentParser wiring, integration tests, and README/man-page coverage.

## Maintenance rules
- Prefer ESM + type-safe exports; avoid platform-specific globals in the core library.
- Keep release notes and conformance artifacts current when closing DoD items; avoid introducing new vendored artifacts (e.g., `node_modules` or built `dist/`) without a clear reason.
- When adding protocol surface area, mirror coverage in tests and update `docs/midi2-js-dod.md` and `midi2.js/docs/gap-plan.md`.
- PDF-to-JSON mapping procedure:
  1) Render the specific spec page(s) to PNG (e.g., `gs -sDEVICE=png16m -o /tmp/page.png -dFirstPage=N -dLastPage=N M2-104-UM_v1-1-2_UMP_and_MIDI_2-0_Protocol_Specification.pdf`).
  2) Manually read/verify the bit layout or field definitions from the image.
  3) Update `midi2.full.closed.schema.json` and `midi2.full.openapi.json` to reflect the extracted facts, with comments in AGENTS noting the source page/section.
  4) Only then implement code/tests against the updated canonical JSON; document any gaps if the schema cannot be updated immediately.

## Recent midi2.js history (for audit)
- 40caf31 — Flex Data coverage expanded (key signature, lyric/text handling).
- 56541bd — Utility MT=0 and MIDI 1.0 channel voice encode/decode; Flex tempo/time signature added.
- 0b07551 — Initial `midi2.js` drop: UMP helpers, SysEx7/8, MIDI-CI envelopes, scheduler, adapters, and DoD doc.
