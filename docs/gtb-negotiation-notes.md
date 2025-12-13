# GTB Negotiation Notes (Gap 4.2.2)

This memo captures initial plan/design for implementing Group Terminal Block (GTB) negotiation semantics without changing the published UMP wire format.

## Scope
- Enforce GTB ↔ Function Block overlap validation per M2-104-UM v1.1.2 Appendix I.
- Apply MT=0xF/MT=0x0 reception restrictions when GTBs are present.
- Model protocol negotiation logic for GTB contexts.

## Design Sketch
1) **Validation**
   - Add a validator that checks GTB configurations against Function Block layout (no overlapping groups unless explicitly allowed per Appendix I).
   - Reject/flag GTB entries with invalid message-type permissions.
2) **Negotiation**
   - Extend `NegotiationSession` (Swift) with GTB context (allowed MT mask, protocol constraints).
   - Add a TS-side helper mirroring the GTB checks (schema-bridge safe-guard).
3) **Runtime Enforcement**
   - When decoding/dispatching, apply GTB reception restrictions for MT=0xF and MT=0x0 in affected groups.
4) **Fixtures/Tests**
   - Add PB-VRT metadata fixture for GTB overlap/permission cases.
   - Add negative tests for invalid GTB layouts and message-type restrictions.

## Next Steps
- Implement Swift GTB validator + enforcement hooks. ✅ (overlap + MT guards; integrated into discovery)
- Implement TS guards in decode path for GTB-restricted groups. ✅ (validator + GTB-aware decode helper + context map; wire context from negotiation/runtime)
- Add PB-VRT GTB fixture and test coverage. ✅ (`docs/pb-vrt/stream/gtb_overlap.json`, loaded in PB-VRT tests)
- Add descriptor ↔ Function Block coverage validation (TS + Swift) and enforce MT=0x0/0xF via allowed-MT guard rails. ✅
- Document protocol scheme and integration points. ✅ (`docs/gtb-protocol-negotiation-scheme.md`)
- Add PB-VRT blocked MT scenario. ✅ (`docs/pb-vrt/stream/gtb_block_mt.json` + test)

## Context Sources
- Preferred: parse USB-MIDI 2.0 GTB descriptors (class-specific interface) into the `group -> {mt}` map and feed negotiation.
- Fallback: `docs/config/gtb.context.json` mirrors descriptor shape; load via `GtbDescriptor.load` (Swift) or `applyGtbDescriptor` (TS).
- Discovery payloads do **not** advertise MT permissions, so descriptor/config input is required (see `docs/gtb-context-source.md`).
