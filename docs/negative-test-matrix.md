# Negative Test Matrix (Reserved/Invalid Values)

**Scope**: Gap 8.2.3 – expand negative coverage across MIDI 2.0 decoders/encoders.  
**Status**: 🟡 In Progress (stream section seeded; remaining message families pending).

| Area | Spec Ref | Cases Added | Outcome |
|------|----------|-------------|---------|
| Stream – Endpoint Info | M2-104-UM Fig.13 | Reserved `numberOfFunctionBlocks > 0x20` | Rejected (Swift + TS) |
| Stream – Stream Config | M2-104-UM Fig.18/19 | Reserved flag bits set | Rejected (TS; Swift covered via StreamReservedBitsTests) |
| Stream – Function Block Info | M2-104-UM Fig.22 | Reserved `midi1Bandwidth=3`, reserved bits | Rejected (Swift + TS) |
| Stream – Reserved bit in mt=0xF word | M2-104-UM §5.1 | Low reserved bit set | Rejected (TS) |
| Utility – Groupless + status | M2-104-UM §5.1 | Group nibble non-zero; unsupported status | Rejected (Swift + TS) |
| SysEx7/SysEx8 – Oversize payload | M2-104-UM §4.2 | Payload > 0xFFFF | Rejected (Swift + TS) |
| Flex – Tempo / Time Signature | Flex spec | BPM < 1; denominatorPow2 > 0x1F | Rejected (TS; Swift validated via throwing inits) |
| MIDI-CI Process Inquiry | M2-101-UM v1.2 | Invalid command byte; length overrun | Rejected (Swift throwing validator) |
| MIDI-CI Profiles Details | M2-102-U v1.1 Table 6 | Missing profileId in details inquiry; unsupported setOn | Rejected (Swift replies disabled/empty) |
| Flex – Reserved status class | Flex spec | Status class ≠ 0x10 | Rejected (Swift + TS) |
| MIDI 1 Ch Voice – Data bounds | MIDI 1.0 | Data bytes >0x7F, invalid statuses | Rejected (Swift + TS) |
| MIDI-CI Profiles – Channel/target bounds | M2-102-U v1.1 | Channel count overflow; invalid target nibble | Rejected (Swift decode nil/empty; TS envelope drops) |
| Process Inquiry – messageDataControl | M2-101-UM v1.2 | messageDataControl not in {0x00,0x01,0x7F} | Rejected (Swift + TS) |

## Next Targets
- SysEx8/SysEx7 reserved/oversize edge cases (already partially covered; add matrix entries).
- Utility/Channel Voice reserved opcodes and out-of-range fields.
- Flex Data reserved status classes and invalid channel addressing.
- MIDI-CI Process Inquiry/profile/detail negative cases.

## Usage Notes
- Swift: see `Tests/MIDI2Tests/NegativeTests/StreamNegativeTests.swift`.
- TypeScript: see `midi2.js/src/__tests__/negative.test.ts`.
