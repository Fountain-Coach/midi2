# GTB Protocol Negotiation Scheme (Gap 4.2.2)

Target: enforce Appendix I GTB semantics without changing UMP wire format.

## Inputs
- USB-MIDI 2.0 GTB descriptor (preferred) or JSON artifact (`docs/config/gtb.context.json` shape).
- Function Block layout from discovery (64-bit notifications).

## Flow (receiver side)
1. **Load GTB descriptor**  
   - Swift: `GtbDescriptor.load(...)` → `StreamNegotiationSession.apply(gtbDescriptor:)`.  
   - TS: `loadGtbDescriptorFromJson` / `applyGtbDescriptor`.
2. **Validate coverage**  
   - Descriptor groups must be covered by Function Blocks; overlap allowed only when explicitly configured.
3. **Publish Function Blocks**  
   - Existing discovery path unchanged; validator runs before advertising blocks.
4. **Ingress enforcement**  
   - Stream (MT=0xF) and Utility (MT=0x0) packets must pass GTB allowed-MT checks per group:  
     - Swift helper: `StreamNegotiationSession.enforceAllowedMessageType(for ump)`  
     - TS decode: `decodeWithGtbContext` / `applyGtbGuards` (dispatch)
5. **Egress (optional)**  
   - Before sending stream/utility packets, apply the same allowed-MT check to avoid emitting disallowed traffic.

## Open items
- Wire GTB context into runtime negotiation/session state so ingress/egress automatically invoke enforcement helpers.
- Add PB-VRT scenarios for MT=0x0/0xF blocking by GTB.
- Document explicit GTB/Function Block overlap policy when allowOverlap=true (per Appendix I examples).
