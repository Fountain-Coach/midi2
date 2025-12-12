# Spec Audit Log (PDF → JSON schema/OpenAPI)

Goal: ensure every normative fact in the MIDI Association specs is reflected in the canonical machine-readable artifacts (`midi2.full.closed.schema.json`, `midi2.full.openapi.json`) and cited by page/section.

Process (per AGENTS):
- Render the relevant spec pages to PNG (e.g., `gs -sDEVICE=png16m -o /tmp/page.png -dFirstPage=N -dLastPage=N <pdf>`).
- If text is needed for search, use `Scripts/find_spec_page.py` (Ghostscript `txtwrite`) to locate pages by phrase.
- Manually read/verify the bit layout or field definitions from the image/text.
- Update both JSON artifacts in lockstep; record the page/section reference here and in commit notes.

Current log:

| Spec | Section/topic | Page(s) | JSON/OpenAPI mapping | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| M2-104-UM v1.1.2 | Stream Process Inquiry / Reply fields | 121 | `midi2.full.closed.schema.json` → `$defs.StreamBody.processInquiry`, `$defs.StreamBody.processInquiryReply`; `midi2.full.openapi.json` mirrors via `components.schemas.StreamBody.*` | Captured | Located via `Scripts/find_spec_page.py "Process Inquiry"`; added to closed schema to match OpenAPI. |
| M2-104-UM v1.1.2 | Stream Configuration Request/Notification bit layout | 37–38 | `$defs.StreamBody.streamConfigRequest`, `$defs.StreamBody.streamConfigNotification` | Captured | Figure 18/19 show protocol bits (0x01 MIDI 1.0, 0x02 MIDI 2.0; others reserved) and JR Rx/Tx flags; matches current schema fields. |
| M2-104-UM v1.1.2 | JR timestamp fallback guidance | 45 (7.2.2.3) | `$defs.StreamBody.streamConfigRequest` | Captured | JR Tx/Rx descriptions note receivers should send Stream Config Notification to switch protocols if JR is unsupported. |
| M2-104-UM v1.1.2 | UMP message types/Stream opcodes bit layout | TODO | `$defs.StreamBody`, `$defs.StreamOpcode`, `$defs.UmpPacket32` | Pending | Verify opcode ranges, reserved bits, and protocol selection/jitter flags against pages §5.x; note any deltas. |
| M2-104-UM v1.1.2 | Function Block discovery/descriptor semantics (GTB) | TODO | `$defs.StreamBody.functionBlockDiscovery` / `functionBlockInfo`; `GroupTerminalBlocks` encoding | Pending | Confirm filter bitmap semantics, GTB encoding, and reserved bits. |
| M2-104-UM v1.1.2 | Protocol selection overview | 24 | `$defs.StreamBody.streamConfigRequest` (protocol enum), `$defs.StreamOpcode` | Captured | Section 3 notes protocol selection via Stream Configuration Request; allowed protocols MIDI1 (0x01) and MIDI2 (0x02), others reserved. |
| M2-104-UM v1.1.2 | Stream opcode map (mt=0xF) | 120 (Figure) | `$defs.StreamOpcode`, `$defs.StreamBody.*`, `$defs.UmpPacket32` | Captured | Figure shows endpoint discovery (0x00), stream config (0x01), function block info/notify (0x02), start/end of clip (0x20/0x21) marked reserved; matches current opcode enum (0x00–0x02) and reserved handling. |
| M2-104-UM v1.1.2 | Function Block features/topology | 29–30 (Figures 7/8) | `$defs.StreamBody.functionBlockDiscovery`/`functionBlockInfo`; `GroupTerminalBlocks` | Captured | Function Blocks span 1–16 groups, up to 32 per endpoint; group numbers monotonic within a block; block indices map to group ranges. No schema gaps identified for bitmap+info pair, but GTB semantics remain to validate. |
| M2-104-UM v1.1.2 | Function Block Info Notification fields | 40 (Figure 22) | `Stream.FunctionBlockMessage` consumers | Captured | Direction bits (0 reserved, 1 input, 2 output, 3 bidirectional), MIDI 1.0 bandwidth (0 not MIDI1, 1 no restrict, 2 restrict 31.25 kbps, 3 reserved), active flag captured in schema; runtime enforcement/tests still needed. |
| M2-104-UM v1.1.2 | Endpoint Discovery filter bitmap | 33 (Figure 12) | `$defs.StreamBody.endpointDiscovery.filter` | Captured | Added endpointInfo/deviceIdentity/endpointName/productInstanceId/streamConfig bits to schema. |
| M2-104-UM v1.1.2 | Endpoint Info Notification | 33 (Figure 13) | `$defs.StreamBody.endpointInfoNotification` | Captured | Static Function Blocks flag, number of Function Blocks (0–32, 0x21–0x7F reserved), UMP version major/minor, M2/M1 support, RXJR/TXJR capability flags captured. |
| M2-104-UM v1.1.2 | Device Identity Notification | 34 (Figure 14) | `$defs.StreamBody.deviceIdentityNotification` | Captured | Manufacturer ID (1- or 3-byte, padded), device family, model, software revision mirrored from SysEx Device Inquiry. |
| M2-104-UM v1.1.2 | Endpoint Name Notification | 35 (Figure 15) | `$defs.StreamBody.endpointNameNotification` | Captured | UTF-8 name up to 98 bytes across Complete/Start/Continue/End forms; trailing bytes zeroed when terminating mid-UMP. |
| M2-104-UM v1.1.2 | Product Instance Id Notification | 35 (Figure 16) | `$defs.StreamBody.productInstanceIdNotification` | Captured | ASCII (0x20–0x7E) product instance/serial, up to 42 bytes across Complete/Start/Continue/End forms. |
| M2-104-UM v1.1.2 | USB Group Terminal Block considerations | 122 (Appendix I) | (runtime/interop guidance) | Pending | Notes on GTB overlap with Function Blocks, restrictions on MT=0xF stream/MT=0x0 utility reception, and protocol negotiation; no schema changes yet. |
| M2-101-UM v1.2 | MIDI-CI Process Inquiry (Inquiry/Reply) envelopes | 59 | `MidiCiProcessInquiryBody` (command enum) | Captured (layout) | Table 40/41 define SysEx8 envelope: F0 7E 7F 0D 40/41, version byte, 4B src MUID, 4B dst MUID; destination must be 0x7F (Function Block). Payload fields captured in following rows. |
| M2-101-UM v1.2 | Process Inquiry Supported Features bitmap | 60 (Table 42) | `MidiCiProcessInquiryBody.supportedFeatures` | Captured | Added `supportedFeatures.messageReport` boolean to both schemas to mirror the defined bitmap (D0 bit = MIDI Message Report). |
| M2-101-UM v1.2 | MIDI Message Report request/reply bitmaps | 61–63 (Tables 43/45) | `MidiCiProcessInquiryBody.deviceId`, `.messageDataControl`, `.systemMessages`, `.channelControllerMessages`, `.noteDataMessages` | Captured | Device ID scope (0x00–0x0F channel, 0x7E group, 0x7F FB), message data control values (0x00/0x01/0x7F) and per-field bitmaps for system/channel/note message requests are now encoded in schemas. |
| M2-104-UM v1.1.2 | Function Block Name Notification | 41–42 (Figure 23) | `FunctionBlockNameNotification` | Captured | Added schema entry with `functionBlock` (Uint7) and UTF-8 `name` (max 91 bytes), noting start/continue/end framing per Figure 23. |
| M2-102-U v1.1 | MIDI-CI Profiles (added/removed/detail reports) | 15, 17 | `MidiCiProfilesBody`, `ProfileSession` | Captured (envelopes) | Table 6 lists Profile config messages (added/removed/details/etc.); channel mask bits already enforced in code/tests; details now constrained to structured maps (cmL/cmH/ok) in schema. |
| M2-103-UM v1.2 | Property Exchange JSON schema and chunking | 69–73 | `MidiCiPropertyExchangeBody` | Captured | Flow control/ACK/NAK with chunk numbers, status codes (406/407), and subscription commands are in schemas; runtime chunk state remains in implementation scope. |
| M2-103-UM v1.2 | Property Exchange headers (resource/encoding/status/flow control) | 28–29 | `MidiCiPropertyExchangeBody.header` | Captured | Added structured header fields (resource, resId, encoding enum, flowControl, status/message, cacheTime) per Tables 13–15. |
| M2-103-UM v1.2 | PE status codes / timeout ACK (notify) | 47–48 | `MidiCiPropertyExchangeBody.statusCodes` | Captured | Added statusCodes array with 100–599 range description noting timeout wait via ACK (Table 16). |
| M2-103-UM v1.2 | PE mediaType for non-JSON payloads | 31 | `MidiCiPropertyExchangeBody.header.mediaType` | Captured | Added `mediaType` (max 75 chars) header property for non-JSON payloads per Table 16. |
| M2-103-UM v1.2 | PE subscriptions partial/full/notify commands | 42 | (future) Subscription command handling | Pending | Command property usage (`start`, `partial`, `full`, `notify`, `end`) for subscription flows; no schema change yet—needs mapping to runtime subscription handling. |
| M2-103-UM v1.2 | PE subscription lifecycle example | 43 | (future) Subscription data flow | Pending | Tables 43–47 show subscription start/ack and data flow; implement subscription state machine and schema/runtime support accordingly. |
| M2-103-UM v1.2 | PE deprecated timeout notify statuses | 49 | `MidiCiPropertyExchangeBody.timeoutStatus` | Captured | Added deprecated notify status codes (100, 408) for backward compatibility; ACK timeout wait preferred. |
| M2-103-UM v1.2 | PE Flow Control ACK (chunking) | 69 | `MidiCiPropertyExchangeBody.flowControlAck` | Captured | Added flow-control ACK status const 0x11 plus requestId (Uint8) and chunkNumber (Uint16) for chunked PE transfers (Table 94). |
| M2-103-UM v1.2 | PE Flow Control NAK retransmit | 72 | `MidiCiPropertyExchangeBody.flowControlNak` | Captured | Added flow-control NAK status const 0x12 for retransmit of last chunk (Table 97). |
| M2-103-UM v1.2 | PE chunk numbering/resend semantics | 69–72 | `MidiCiPropertyExchangeBody.flowControlAck/flowControlNak` | Captured | Chunk numbers captured in ACK/NAK; statuses 406/407 captured for unsupported flow control; resend behavior to be enforced in runtime. |
| M2-103-UM v1.2 | PE flow-control ACK message length | 69–70 | `MidiCiPropertyExchangeBody.flowControlAck.messageLength` | Captured | Added messageLength field from Table 94/95 (0 when no message, reserved otherwise). |
| M2-103-UM v1.2 | PE flowControl header flag usage | 69–71 | `MidiCiPropertyExchangeBody.header.flowControl` | Captured | Header flag `flowControl` indicates flow-control ACKs between chunks; error if resource doesn't support flow control (status 406/407 guidance). |
| M2-103-UM v1.2 | PE flow-control error statuses | 69–71 | `MidiCiPropertyExchangeBody.flowControlError` | Captured | Added explicit flow-control error statuses 406/407 when flowControl is requested on unsupported resources. |
| M2-103-UM v1.2 | PE terminate/timeout notify guidance | 47–49 | `MidiCiPropertyExchangeBody.timeoutStatus` | Captured | ACK/NAK replaces deprecated Notify for terminate/timeout; deprecated statuses (100/408) kept for compatibility. |
| M2-104-UM v1.1.2 | Delta Clockstamp Ticks Per Quarter Note | 45 (Figure 33) | `MidiCiPropertyExchangeBody.deltaClockstampTicksPerQuarterNote` | Captured | DCTPQ field added to schema (0 reserved, max 65535). |
| M2-103-UM v1.2 | cacheTime header property | 30–31 | `MidiCiPropertyExchangeBody.cacheTime` | Captured | Added cacheTime (seconds) to schema for PE responses. |
| M2-103-UM v1.2 | PE flow-control NAK chunk number | 72 | `MidiCiPropertyExchangeBody.flowControlNak.chunkNumber` | Captured | NAK includes chunkNumber to retransmit (LSB first). |
| M2-103-UM v1.2 | PE subscription commands | 42–43 | `MidiCiPropertyExchangeBody.subscriptionCommand` | Captured | Enumerated subscription commands (start/partial/full/notify/end) added to schema. |

Next actions:
- Iterate through each spec section, fill in page references, and close the TODO rows; add rows as new sections are audited.
- For any gaps, update both JSON artifacts and cite the page(s) here.
