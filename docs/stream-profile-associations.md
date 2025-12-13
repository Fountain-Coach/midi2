# Function Block ↔ Profile Associations (Metadata Layer)

This document describes how we associate MIDI-CI Profile IDs with Function Block descriptors **without changing the UMP wire format**. The goal is to surface profile information alongside Function Block discovery/response flows while keeping UMP packets compliant with M2-104-UM Figure 22.

## Approach

- **On-wire:** Function Block Info packets remain unchanged (index, firstGroup, groupCount, active, direction, midi1Bandwidth, uiHints).
- **Metadata store:** We maintain an in-memory map keyed by Function Block index:
  - Swift: `StreamNegotiationSession` (`profileMap`) seeds from `GroupTerminalBlocks` and can be updated at runtime.
  - TypeScript: `stream-profiles.ts` provides `setProfileAssociations` / `getProfileAssociations` (with timestamp).
- **Sources of truth:** Static config (optional fixture), plus runtime updates from Profile enable/disable/report flows. Host APIs can override for testing or diagnostics.
- **Discovery responses:** When handling Function Block Discovery, the negotiation layer overlays any known profiles in the returned `GroupTerminalBlocks` structure (metadata only; UMP payload unchanged).
- **Fixtures/diagnostics:** PB-VRT metadata fixture `docs/pb-vrt/stream/function_block_profiles.json` supplies example associations for tests and tooling.

## APIs

- Swift:
  - `profileAssociations(for index: UInt8) -> [String]`
  - `setProfileAssociations(for index: UInt8, profiles: [String])`
- TypeScript:
  - `setProfileAssociations(index: number, profiles: string[])`
  - `getProfileAssociations(index: number): string[]`
  - `getProfileAssociationsWithTimestamp(index: number)`
  - `updateProfileAssociation(index: number, profileId: string, enabled: boolean)`

## Testing

- TS: `stream-profiles.test.ts` (map behavior) and PB-VRT test loads the fixture.
- Swift: `StreamNegotiationTests` cover discovery flags and profile association updates.

## Next Steps

- Wire runtime updates from actual Profile enable/disable/report handlers into the profile map (hook available via `ProfileSession.onProfileAssociationChange`; map function block index from target/functionBlock scope as needed).
- Optionally expose profile associations in CLI/diagnostics outputs alongside Function Block info.
