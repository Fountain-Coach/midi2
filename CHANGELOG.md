# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- (none)
### Changed
- (none)

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
