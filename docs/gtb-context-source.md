# GTB Context Source & Config (Gap 4.2.2)

This doc captures where GTB message-type permissions come from, how we inject them into the stack, and what to do when discovery payloads do not advertise them.

## Source of Truth (priority order)
- **USB-MIDI 2.0 descriptors (preferred)**: Class-specific GTB descriptors on the streaming interface carry per-group allowed MTs. Parse these into a `group -> {mt}` map and feed negotiation.
- **Out-of-band config (fallback)**: `docs/config/gtb.context.json` mirrors the descriptor shape (`{ "groups": { "0": ["0xf", 5] } }`) and seeds the same map when descriptors are absent or incomplete.
- **Manual override (debug)**: Tests/fixtures can inject GTB context directly via the negotiation session helpers.

The current spec does **not** put MT permissions in the MIDI-CI discovery payload, so a descriptor/config source is required.

## Injection Points
- **Swift**: `GtbDescriptor.load(from:)` reads the JSON shape above; `StreamNegotiationSession.apply(gtbDescriptor:)` (validated against Function Blocks) seeds the per-group allowed MT map for enforcement (`enforceAllowedMessageType`).
- **TypeScript**: `applyGtbDescriptor` (in `midi2.js/src/gtb-descriptor.ts`) applies the same map into the shared GTB context consumed by the guarded decoders.

## Proposed scheme
1. Parse USB descriptors when available and emit the JSON shape above (keeping group/index nibble-masked).
2. Store that artifact alongside device metadata (drop-in replacement for `docs/config/gtb.context.json`).
3. Load it at startup for both Swift and TS runtimes to seed GTB enforcement; fall back to the bundled example when hardware descriptors are missing during development.

## Notes / Blocker Avoidance
- If hardware descriptors are unavailable, we can publish our own GTB descriptor example (same JSON shape) to unblock negotiation work; update `docs/config/gtb.context.json` and reference it in tests/fixtures.
- Appendix I (M2-104-UM v1.1.2) remains the reference for MT permission semantics; the map should only contain MT nibbles allowed for each group.
