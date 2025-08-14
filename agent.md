# Codex Agent: MIDI2 Demo CLI Implementation Roadmap

## Status
The current project status is tracked in [README.md](README.md). Update that file's
"Status" section whenever significant changes occur.

## Gap to finish line
- Deliver a complete, canonical implementation of the entire MIDI 2.0 specification—every message type, schema, encoder/decoder, and helper must exist in the library.
- Harden the codebase with exhaustive unit/integration tests, coverage tracking, and documentation that proves spec fidelity.
- Expose the library through a teaching-oriented CLI tool with comprehensive help/man page that demonstrates the *full* spec in practice.
- Maintain a passing test suite and integrate coverage checks.

## Reference CLI concept (`midi2demo`)
Purpose: teach MIDI 2.0 packet structure and MIDI-CI workflows while showcasing that the library implements the *entire* spec and behaves as a hardened, canonical reference.

Command summary:
- `note-on` – encode/decode a channel voice Note On message.
- `sysex7` / `sysex8` – fragment and reassemble payloads.
- `flex` – emit Flex Data messages (tempo, key, lyric, etc.).
- `ci-handshake` – simulate MIDI-CI discovery and profile/property exchange.
- `inspect` – decode arbitrary UMP hex into human-readable form.

## Implementation task matrix
1. Scaffold executable target `midi2demo` in `Package.swift` and create `Sources/midi2demo`.
2. Integrate Swift ArgumentParser with subcommands listed above.
3. Implement `note-on` command demonstrating encode/decode roundtrip.
4. Implement `sysex7` and `sysex8` commands for streaming helpers.
5. Implement Flex Data subcommands (tempo, time signature, key, lyric, ...).
6. Simulate MIDI-CI handshake in `ci-handshake` command.
7. Implement `inspect` command to decode arbitrary UMP hex.
8. Provide rich `--help` output and a `midi2demo.1` man page.
9. Add integration tests invoking each subcommand.
10. Update README with CLI usage examples and build instructions.

