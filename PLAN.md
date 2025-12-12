# Current Plan

- Align implementations with canonical schema/OpenAPI: implement full SysEx7/8 decode, Data (MDS) mapping, and complete Stream/Flex message coverage in midi2.js; add schema-bridge round-trips and negative tests.
- Bring Swift stream and data helpers to schema parity: add endpoint info/device identity/name/product instance/function block name/clip support, filter bitmap, and function block flags; realign Mixed Data Set and Property Exchange bodies to the canonical shapes or document deltas.
- Normalize Property Exchange semantics across stacks: enforce schema header/encoding/flow-control/status rules, implement flow-control ACK/NAK paths, and add chunking/error/compression vectors.
- Expand validation and tests: reserved-bit/range enforcement for stream/flex/CI envelopes, oversize SysEx/invalid chunk ordering, worker-clock JR projection, and adapter negotiation (per-note controllers/pitch-bend range).
- Keep docs in sync after parity work: update DoD/gap plan equivalents and regenerate OpenAPI-derived types once schema changes land; validate via `npm run check && npm test` and Swift unit/integration suites.
