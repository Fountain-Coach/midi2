# Current Plan

**Version**: 0.9.0 | **Last Updated**: 2025-12-16

## Completed (v0.9.0)
- ✅ Schema/OpenAPI alignment: Data (MDS), Stream, Flex, and SysEx coverage complete in midi2.js with schema-bridge round-trips and negative tests
- ✅ Swift stream and data helpers at schema parity: endpoint info, device identity, name, product instance, function block name/flags, filter bitmap
- ✅ Property Exchange semantics normalized: flow-control ACK/NAK paths, subscription lifecycle state machine, chunking/error/compression vectors
- ✅ Validation expanded: reserved-bit/range enforcement for stream/flex/CI envelopes (11 gaps closed)
- ✅ Stream/Function Block/Process Inquiry runtime gaps closed (GTB negotiation, TS stream config round-trips, Process Inquiry session runtime helper)
- ✅ Docs synchronized for v0.9.0: gap-closure-tracker, spec-compliance-dashboard, comprehensive-spec-audit-report updated

## In Progress
- 🟡 Negative test coverage expansion (Gap 8.2.3): reserved value matrix seeded, stream negative tests added
- 🟡 PB-VRT visual baselines (Gap 8.2.1): baseline generator and fixtures in place, full coverage pending

## Remaining Work
- Worker-clock JR projection tests (Gap 5.2.1)
- Adapter per-note controller negotiation (Gap 5.2.2)
- Hardware interop testing (Gap 8.2.2)
- Oversize SysEx handling (Gap 7.2.1)
- Schema documentation completeness (Gap 9.2.1)
- Schema regression CI (Gap 9.2.2)
- DoD validation automation (Gap 10.2.1)
- UMP format extensions documentation (Gap 1.2.2)

## Maintenance
- Keep docs in sync: regenerate OpenAPI-derived types when schema changes; validate via `npm run check && npm test` and Swift unit/integration suites
- Follow release process in RELEASE.md for version bumps
- Track gaps in docs/gap-closure-tracker.md
