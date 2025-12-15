# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
### Changed
- Docs: Comprehensive documentation audit - updated test counts (198 TS tests), version references (0.8.0), gap-closure status (11/21 complete), and archived legacy docs with proper cross-references.
- Docs: Updated SECURITY.md supported versions to reflect v0.8.x as current stable.
- Docs: Updated PLAN.md to reflect completed v0.8.0 work and remaining gaps.
- Docs: Updated spec-compliance-dashboard.md with accurate TypeScript test metrics.

## [0.8.0] - 2025-12-15
### Added
- Docs: Marked Property Exchange subscription runtime implemented; spec audit/traceability updated.
- CI: Added CodeQL workflow (manual/scheduled and main pushes), removed duplicate midi2.js workflow; JavaScript CI fixed coverage dependency.
- Governance: CODEOWNERS set to @Contexter; security contact updated; issue/PR templates in place.
### Changed
- Compliance workflows continue-on-error; CodeQL skipped on PRs (non-blocking) for now.
- README documents required midi2demo CLI examples to satisfy DoD checks.

## [0.7.0] - 2025-11-28
### Added
- JS/TS: Introduced `midi2.js`, a CoreMIDI-free TypeScript/JavaScript library for MIDI 2.0 UMP, SysEx7/8 fragmentation/reassembly, MIDI‑CI envelopes, jitter-aware scheduler, and adapters (WebAudio/Three.js/Cannon.js). Bundled ESM+CJS+types via tsup; npm-ready package with `files: ["dist"]`.
- Validation: Stream opcode coverage extended to process inquiry; system status typing tightened; Node typings added for test fixtures.
### Changed
- Tooling: Upgraded vitest to 3.2.4 (resolving esbuild/vite advisories); added Node types to tsconfig and tests to satisfy type-checking; regenerated OpenAPI-derived guards.
- Docs: Root README now reflects both Swift and `midi2.js`; gap-plan/agents updated to current JS feature set and packaging status.

## [0.6.1] - 2025-11-04
### Added
- CI: Harden MIDI Association Workbench compliance runner
  - Explicit Electron install and native module rebuild via @electron/rebuild
  - Playwright system deps install on Linux; improved caching/retries
  - Headless controller resolves Electron from Workbench tree
### Changed
- Tests: Align JR receiver wrap semantics and Property Exchange error codes; update System Real-Time error expectation

## [0.4.0] - 2025-11-04
### Added
- Stream §5: Typed Endpoint Discovery, Stream Configuration (request/notification), Function Block info; FB discovery (filterBitmap) two-packet encoding; Group Terminal Blocks aggregate; CLI commands and tests.
- Strict reserved-bit validation and negative tests for Stream §5.
- Property Exchange: chunked GET/SET/NOTIFY with transaction reassembly; error codes/messages; zlib compression helpers; CLI demo; tests.
- Profiles: enable/disable/inquiry/details (version + channel mask); Profile Specific Data (PSD) SysEx7/8; CLI demos; tests.
- CI Device Discovery encode/decode and validation; manufacturer ID validation and tests.
- JR receiver for clock/timestamp reconstruction with wrap handling; tests.
- PB‑VRT baselines for Stream, Profiles, and Property Exchange flows.
- DoD checklist + traceability; CI workflow with warnings-as-errors, tests, coverage gate (≥80%), and PB‑VRT/doc verification.
### Changed
- README and man page updated with new CLI subcommands and examples.

## [0.3.0] - 2025-08-15
### Added
- Completed `TeatroAppleBridge` Core MIDI adapter with sender, receiver, and sequencer APIs plus grid/clock utilities.
- Added command-line demos and unit tests for the Apple bridge components.

## [0.2.0] - 2025-08-14
### Added
- Full implementation of the MIDI 2.0 specification.
- Auto-generated API documentation.
- Installation and upgrade instructions.

### Breaking
- None.

## [0.1.0] - 2024-04-01
### Added
- Initial release with core UMP structures and `midi2demo` CLI scaffold.
