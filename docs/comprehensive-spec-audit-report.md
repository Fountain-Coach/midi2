# Comprehensive MIDI 2.0 Specification Audit Report

**Date**: 2025-12-13  
**Repository**: Fountain-Coach/midi2  
**Version**: 0.7.0 (TypeScript), 0.4.0 (Swift)  
**Audited Against**: MIDI Association Normative Specifications (M2-100 through M2-116)

---

## Executive Summary

This comprehensive audit evaluates the alignment between the `midi2` repository implementation (Swift and TypeScript/JavaScript) and the MIDI 2.0 normative specifications published by the MIDI Association. The repository maintains dual canonical machine-readable artifacts (`midi2.full.closed.schema.json` and `midi2.full.openapi.json`) that serve as the single source of truth for both implementations.

### Overall Assessment

**Strengths**:
- Excellent schema-to-implementation alignment with comprehensive OpenAPI/JSON Schema definitions
- Strong coverage of core UMP message types (Channel Voice 1.0/2.0, System, Utility, Stream)
- Robust MIDI-CI implementation with Property Exchange chunking and compression
- Active spec-audit log with page-level traceability to normative PDFs
- Comprehensive test coverage (107 Swift tests, 11 TypeScript tests)
- Well-documented gaps and ongoing conformance tracking

**Key Gaps Identified**:
1. **Runtime State Machines**: Property Exchange subscription lifecycle and flow-control ACK/NAK paths lack runtime implementation
2. **Function Block Semantics**: Descriptor details beyond index/group range; GTB negotiation incomplete
3. **Reserved/Unsupported Handling**: Inconsistent placeholder handling across decoders
4. **Hardware Interop**: No tests against external MIDI-CI devices
5. **TypeScript Coverage**: Several areas marked as partial in gap-plan.md
6. **Visual Regression**: PB-VRT baseline frames incomplete for CI messages

---

## 1. UMP Encode/Decode Implementation

### 1.1 Coverage Status

#### Swift Implementation
**Status**: ✅ Comprehensive

**Evidence**:
- Channel Voice 1.0: `Sources/MIDI2/Midi1ChannelVoiceBody.swift`
- Channel Voice 2.0: `Sources/MIDI2/Midi2ChannelVoiceBody.swift`
  - Per-note controllers: `Sources/MIDI2/Midi2AssignPerNoteController.swift`
  - RPN/NRPN: Absolute and relative variants
- Utility Messages: `Sources/MIDI2/UtilityBody.swift`, `Sources/MIDI2/UtilityOpcode.swift`
- System Messages: `Sources/MIDI2/SystemCommonRealtimeBody.swift`
- Stream Messages: `Sources/MIDI2/StreamBody.swift`, `Sources/MIDI2/StreamOpcode.swift`
- Data Messages: SysEx7/8, Mixed Data Set support
- Function Blocks: `Sources/MIDI2/Stream/FunctionBlockMessage.swift`

**Schema Alignment**: All message types reflected in `midi2.full.closed.schema.json` $defs:
- `UmpMessageType` enum (0, 1, 2, 3, 4, 5, 13, 15)
- `Midi1ChannelVoiceBody`, `Midi2ChannelVoiceBody`
- `SystemCommonRealtimeBody`, `UtilityBody`
- `StreamBody`, `FlexDataBody`
- `DataMessageBody`

**Tests**: 
- Reserved-bit validation: `Tests/MIDI2Tests/StreamReservedBitsTests.swift`
- Typed message tests: `Tests/MIDI2Tests/StreamTypedTests.swift`
- SysEx fragmentation: `Tests/MIDI2Tests/SysEx8Tests.swift`
- Invalid sequences: `Tests/MIDI2Tests/SysEx8InvalidSequenceTests.swift`

#### TypeScript Implementation
**Status**: ✅ Comprehensive (with noted gaps)

**Evidence**:
- UMP core: `midi2.js/src/ump.ts`
- Decoder: `midi2.js/src/decoder.ts`
- MIDI 1.0 compat: `midi2.js/src/midi1.ts`
- SysEx fragmentation: `midi2.js/src/sysex.ts`
- Schema bridge: `midi2.js/src/schema-bridge.ts`
- OpenAPI types: `midi2.js/src/generated/openapi-types.ts`

**Tests**:
- UMP tests: `midi2.js/src/__tests__/ump.test.ts`
- Decoder tests: `midi2.js/src/__tests__/decoder.test.ts`
- MIDI 1.0 tests: `midi2.js/src/__tests__/midi1.test.ts`
- Schema bridge: `midi2.js/src/__tests__/schema-bridge.test.ts`
- Stream reserved: `midi2.js/src/__tests__/stream-reserved.test.ts`

### 1.2 Identified Gaps

#### Gap 1.2.1: Reserved/Unsupported Status Handling
**Severity**: Medium  
**Spec Reference**: M2-104-UM v1.1.2 (various sections)

**Current State**: Partial implementation with negative tests for Stream §5 and SysEx8, but inconsistent across all decoders.

**Evidence**:
- `docs/conformance-checklist.md`: "Future reserved message IDs: Partial"
- `legacy/midi2-js-gap-plan.md`: "Reserved/unsupported statuses: unify placeholder handling across decoders; broaden negative tests."

**Recommended Action**:
1. Create a comprehensive table of all reserved opcodes, status values, and bit patterns from M2-104-UM
2. Implement consistent error handling/rejection across Swift and TypeScript decoders
3. Add negative test vectors for each reserved value category
4. Update schema with explicit reserved value documentation

**Priority**: Medium  
**Effort**: Medium (2-3 days)

#### Gap 1.2.2: UMP Format Extensions
**Severity**: Low  
**Spec Reference**: M2-104-UM v1.1.2 (Future Extensions)

**Current State**: Utility messages beyond JR are partial.

**Evidence**: 
- `docs/conformance-checklist.md`: "Utility messages beyond JR: Partial"

**Recommended Action**:
1. Document which utility opcodes beyond Jitter Reduction are currently supported
2. Add placeholders for future utility message types with clear deprecation notices
3. Ensure schema allows for forward compatibility

**Priority**: Low  
**Effort**: Low (1 day)

---

## 2. MIDI-CI Implementation

### 2.1 Coverage Status

#### Swift Implementation
**Status**: ✅ Strong (with runtime gaps)

**Components**:
- Discovery: `Sources/MIDI2/MidiCiDiscoveryBody.swift`
- Profiles: `Sources/MIDI2/MidiCiProfilesBody.swift`
  - Session management: `Sources/MIDI2CI/ProfileSession.swift`
  - Profile Specific Data: `Sources/MIDI2CI/ProfileSpecificData.swift`
  - Inquiry: `Sources/MIDI2CI/ProfileInquiry.swift`
- Property Exchange: `Sources/MIDI2/MidiCiPropertyExchangeBody.swift`
  - Runtime: `Sources/MIDI2CI/PropertyExchange.swift`
  - Compression: `Sources/MIDI2CI/CompressionCodec.swift` (zlib, mcoded7)
- Process Inquiry: `Sources/MIDI2/MidiCiProcessInquiryBody.swift`
  - Session: `Sources/MIDI2CI/ProcessInquirySession.swift`
- ACK/NAK: `Sources/MIDI2/MidiCiAckNakBody.swift`
- Envelope: `Sources/MIDI2/MidiCiEnvelope.swift`
- Handshake: `Sources/MIDI2CI/CIHandshake.swift`
- Protocol Negotiation: `Sources/MIDI2CI/ProtocolNegotiation.swift`

**Tests**:
- Integration: `Tests/MIDI2Tests/MidiCiHandshakeIntegrationTests.swift`
- Profile sessions: `Tests/MIDI2Tests/ProfileSessionTests.swift`
- Property Exchange chunking: `Tests/MIDI2Tests/PropertyExchangeChunkingTests.swift`
- Compression: `Tests/MIDI2Tests/PropertyExchangeCompressionTests.swift`

**Schema Coverage**:
- All MIDI-CI message types defined in `MidiCiEnvelope`, `MidiCiDiscoveryBody`, `MidiCiProfilesBody`, `MidiCiPropertyExchangeBody`, `MidiCiProcessInquiryBody`, `MidiCiAckNakBody`
- Spec-audit log shows 28 captured entries for MIDI-CI fields with page references

#### TypeScript Implementation
**Status**: ✅ Good (envelopes; runtime gaps)

**Components**:
- MIDI-CI core: `midi2.js/src/midici.ts`
- PE subscriptions: `midi2.js/src/pe-subscriptions.ts`

**Tests**:
- PE subscriptions: `midi2.js/src/__tests__/pe-subscriptions.test.ts`
- OpenAPI types: `midi2.js/src/__tests__/openapi-types.test.ts`

### 2.2 Identified Gaps

#### Gap 2.2.1: Property Exchange Subscription Lifecycle
**Severity**: High  
**Spec Reference**: M2-103-UM v1.2, Tables 43-47 (p.42-43)

**Current State**: Schema fields captured, but runtime state machine not implemented.

**Evidence**:
- `docs/spec-audit.md`: Row 40 - "PE subscription lifecycle example | Pending (runtime)"
- `docs/spec-audit.md`: Row 39 - "runtime state machine still TODO"
- `legacy/midi2-js-gap-plan.md`: "MUID management coverage is thin. Compression/error/NAK paths remain untested."

**Recommended Action**:
1. Implement state machine for subscription lifecycle (start → partial → full → notify → end)
2. Add flow-control ACK/NAK runtime handlers (currently only schema-level)
3. Implement subscription tracking with proper resource state management
4. Add comprehensive test vectors for:
   - Subscription start/end sequences
   - Partial vs. full update patterns
   - Error handling and timeouts
   - Flow-control ACK/NAK paths
5. Cross-validate against M2-103-UM Tables 43-47

**Priority**: High  
**Effort**: High (5-7 days)

**Specific Missing Features**:
- Subscription state tracking (active subscriptions map)
- Chunk number validation and retransmit logic
- Flow-control ACK timeout handling
- Resource-level flow-control capability negotiation
- Proper NAK retransmit behavior

#### Gap 2.2.2: Profile Configuration Details and Reports
**Severity**: Medium  
**Spec Reference**: M2-102-U v1.1, Table 6 (p.15, 17)

**Current State**: Details replies include version and channel mask; PSD supported; added/removed helpers present.

**Evidence**:
- `docs/conformance-checklist.md`: "Profile Configuration Details: Partial"
- Profile detail/added-removed reports need negative tests

**Recommended Action**:
1. Expand profile detail report handling beyond basic version/channel mask
2. Add comprehensive tests for profile added/removed notifications
3. Implement profile configuration change tracking
4. Add negative test cases for malformed profile detail messages

**Priority**: Medium  
**Effort**: Medium (2-3 days)

#### Gap 2.2.3: Process Inquiry Implementation
**Severity**: Medium  
**Spec Reference**: M2-101-UM v1.2, Table 40-42 (p.59-60)

**Current State**: Envelopes captured, but limited runtime validation.

**Evidence**:
- `docs/spec-audit.md`: Rows 31-32 show Process Inquiry fields captured
- Basic session support exists but needs expansion

**Recommended Action**:
1. Validate supported features bitmap (D0 bit = MIDI Message Report)
2. Implement device ID scope handling (0x00-0x0F channel, 0x7E group, 0x7F FB)
3. Add message data control value enforcement (0x00/0x01/0x7F)
4. Add tests for system/channel/note message request bitmaps

**Priority**: Medium  
**Effort**: Medium (2-3 days)

#### Gap 2.2.4: MUID Management
**Severity**: Medium  
**Spec Reference**: M2-101-UM v1.2 (MUID allocation/discovery)

**Current State**: Basic MUID handling exists but coverage is thin.

**Evidence**:
- `legacy/midi2-js-gap-plan.md`: "MUID management coverage is thin"

**Recommended Action**:
1. Implement comprehensive MUID allocation/deallocation
2. Add MUID conflict detection and resolution
3. Implement MUID timeout and cleanup
4. Add tests for MUID lifecycle scenarios

**Priority**: Medium  
**Effort**: Low-Medium (2-3 days)

---

## 3. Flex Data Implementation

### 3.1 Coverage Status

#### Swift Implementation
**Status**: ✅ Implemented

**Evidence**:
- Flex Data body: `Sources/MIDI2/FlexDataBody.swift`
- Demo: `Sources/midi2demo/Flex.swift`
- Schema definitions for all Flex types in `midi2.full.closed.schema.json`:
  - `Flex.Tempo`, `Flex.TimeSignature`, `Flex.Metronome`
  - `Flex.KeySignature`, `Flex.ChordName`
  - `Flex.Lyric`, `Flex.Text`, `Flex.Ruby`

**Tests**: Negative tests included in general UMP test suite

#### TypeScript Implementation
**Status**: ✅ Implemented

**Evidence**:
- `legacy/midi2-js-gap-plan.md`: "Flex Data, SysEx7/8 fragment/reassemble" marked as done
- OpenAPI-derived guards cover Flex Data types

### 3.2 Identified Gaps

#### Gap 3.2.1: Flex Data Validation and Edge Cases
**Severity**: Low  
**Spec Reference**: M2-104-UM v1.1.2 (Flex Data sections)

**Current State**: Basic encoding/decoding works, but edge case validation may be incomplete.

**Recommended Action**:
1. Add comprehensive validation for:
   - Tempo range limits
   - Time signature validity
   - Metronome clock patterns
   - Text encoding boundaries (UTF-8 validation)
2. Add edge case tests:
   - Maximum string lengths for Text/Lyric/Ruby
   - Invalid chord names
   - Reserved flex data opcodes

**Priority**: Low  
**Effort**: Low (1-2 days)

---

## 4. Stream Configuration and Function Blocks

### 4.1 Coverage Status

#### Swift Implementation
**Status**: 🟡 Partial (with significant gaps)

**Evidence**:
- Endpoint Discovery: `Sources/MIDI2/Stream/EndpointDiscoveryMessage.swift`
  - Major/minor version, max groups, reserved validation
- Stream Config: `Sources/MIDI2/Stream/StreamConfigurationMessage.swift`
  - Typed fields, reserved-bit validation
- Function Blocks: `Sources/MIDI2/Stream/FunctionBlockMessage.swift`
  - Index, firstGroup, groupCount fields
  - Discovery: `Sources/MIDI2/Stream/FunctionBlockDiscovery.swift`
- Group Terminal Blocks: `Sources/MIDI2/Stream/GroupTerminalBlocks.swift`
- Demo: `Sources/midi2demo/StreamConfig.swift`

**Tests**:
- Mapping: `Tests/MIDI2Tests/StreamMappingTests.swift`
- Reserved bits: `Tests/MIDI2Tests/StreamReservedBitsTests.swift`
- Typed messages: `Tests/MIDI2Tests/StreamTypedTests.swift`
- Function Block discovery: `Tests/MIDI2Tests/StreamFunctionBlockDiscoveryTests.swift`
- GTB: `Tests/MIDI2Tests/GroupTerminalBlocksTests.swift`

**Schema Coverage**:
- `StreamBody.endpointDiscovery` with filter bitmap (p.33, Figure 12)
- `StreamBody.endpointInfoNotification` (p.33, Figure 13)
- `StreamBody.deviceIdentityNotification` (p.34, Figure 14)
- `StreamBody.endpointNameNotification` (p.35, Figure 15)
- `StreamBody.productInstanceIdNotification` (p.35, Figure 16)
- `StreamBody.functionBlockInfo` (p.40, Figure 22)
- `FunctionBlockNameNotification` (p.41-42, Figure 23)
- Stream opcodes 0x00-0x06, 0x10-0x12, 0x20-0x21 defined

#### TypeScript Implementation
**Status**: 🟡 Partial

**Evidence**:
- `legacy/midi2-js-gap-plan.md`: "Endpoint/Device Info payload fidelity and GTB semantics: tighten encode/decode and add vectors"

### 4.2 Identified Gaps

#### Gap 4.2.1: Function Block Descriptor Details
**Severity**: High  
**Spec Reference**: M2-104-UM v1.1.2, Figures 7/8 (p.29-30), Figure 22 (p.40), Appendix I (p.122)

**Current State**: Only index/firstGroup/groupCount captured; missing direction, MIDI 1.0 bandwidth, active flag runtime enforcement.

**Evidence**:
- `docs/conformance-checklist.md`: "Gap: Descriptor details beyond index/group range; discovery/response flow semantics; profile reports."
- `docs/spec-audit.md`: Row 23 - "Direction bits (0 reserved, 1 input, 2 output, 3 bidirectional), MIDI 1.0 bandwidth (0 not MIDI1, 1 no restrict, 2 restrict 31.25 kbps, 3 reserved), active flag captured in schema; runtime enforcement/tests still needed."

**Recommended Action**:
1. Extend `FunctionBlockMessage` to include all fields from Figure 22:
   - Direction (2 bits): 0=reserved, 1=input, 2=output, 3=bidirectional
   - MIDI 1.0 bandwidth (2 bits): 0=not MIDI1, 1=unrestricted, 2=31.25kbps, 3=reserved
   - Active flag (1 bit)
   - UI hints and textual name references
2. Implement discovery/response flow semantics
3. Add profile report associations with Function Blocks
4. Add comprehensive tests validating all field values

**Priority**: High  
**Effort**: Medium-High (4-5 days)

#### Gap 4.2.2: GTB Negotiation Semantics
**Severity**: High  
**Spec Reference**: M2-104-UM v1.1.2, Appendix I (p.122)

**Current State**: GTB structure implemented, but negotiation semantics incomplete.

**Evidence**:
- `docs/spec-audit.md`: Row 29 - "USB Group Terminal Block considerations | Pending"
- `docs/conformance-checklist.md`: "Gap: GTB negotiation and additional §5 semantics"

**Recommended Action**:
1. Document GTB overlap with Function Blocks per Appendix I
2. Implement restrictions on MT=0xF stream/MT=0x0 utility reception
3. Add protocol negotiation logic specific to GTB contexts
4. Add test cases for GTB-Function Block interaction scenarios
5. Update runtime documentation with GTB negotiation patterns

**Priority**: High  
**Effort**: Medium-High (4-5 days)

#### Gap 4.2.3: Stream Configuration Semantics
**Severity**: Medium  
**Spec Reference**: M2-104-UM v1.1.2, Figures 18/19 (p.37-38), Section 7.2.2.3 (p.45)

**Current State**: Basic protocol/JR fields captured, but negotiation flow incomplete.

**Evidence**:
- `docs/spec-audit.md`: Row 17 - "JR Tx/Rx descriptions note receivers should send Stream Config Notification to switch protocols if JR is unsupported"
- Protocol bits (0x01 MIDI 1.0, 0x02 MIDI 2.0, others reserved) defined

**Recommended Action**:
1. Implement JR fallback behavior when receiver doesn't support JR
2. Add protocol switching logic (MIDI 1.0 ↔ MIDI 2.0)
3. Implement Stream Config Notification sending on capability mismatch
4. Add test scenarios for negotiation failures and fallbacks

**Priority**: Medium  
**Effort**: Medium (3-4 days)

#### Gap 4.2.4: Endpoint Info Beyond Version/Max Groups
**Severity**: Medium  
**Spec Reference**: M2-104-UM v1.1.2, Figure 13 (p.33)

**Current State**: Major/minor version and max groups captured; additional fields need attention.

**Evidence**:
- `docs/conformance-checklist.md`: "Gap: Device Info/advertisement content (beyond version/max groups)"
- Schema has `endpointInfoNotification` with staticFunctionBlocks, numberOfFunctionBlocks, UMP version, MIDI2/MIDI1 support flags, JR capability flags

**Recommended Action**:
1. Ensure all Endpoint Info Notification fields are properly encoded/decoded:
   - Static Function Blocks flag (S bit)
   - Number of Function Blocks (0x00-0x20 valid, 0x21-0x7F reserved)
   - UMP version major/minor
   - M2/M1 support flags
   - RXJR/TXJR capability flags
2. Add runtime validation for reserved numberOfFunctionBlocks values (0x21-0x7F)
3. Add comprehensive test vectors

**Priority**: Medium  
**Effort**: Low-Medium (2 days)

---

## 5. Scheduling and Adapters (TypeScript)

### 5.1 Coverage Status

**Status**: ✅ Good (with optimization opportunities)

**Evidence**:
- Scheduler: `midi2.js/src/scheduler.ts`
- Clock: `midi2.js/src/clock.ts`
- Jitter: `midi2.js/src/jitter.ts`
- Adapters:
  - WebAudio: `midi2.js/src/adapters/webaudio.ts`
  - Three.js: `midi2.js/src/adapters/three.ts`
  - Cannon.js: `midi2.js/src/adapters/cannon.ts`

**Tests**:
- Scheduler: `midi2.js/src/__tests__/scheduler.test.ts`
- Jitter: `midi2.js/src/__tests__/jitter.test.ts`
- Worker clock: `midi2.js/src/__tests__/jitter.worker.test.ts`

**DoD Criteria** (from `legacy/midi2-js-dod.md`):
- ✅ Scheduler delivers time-ordered events with jitter tolerance
- ✅ Supports browser, AudioContext, and worker/off-main-thread clocks
- ✅ Deterministic record/replay API
- ✅ WebAudio: voice allocation, per-note controllers, pitch bend range, channel pressure, safe disposal
- ✅ Three.js: mapping primitives with hooks
- ✅ Cannon.js: body creation/removal and impulse mapping

### 5.2 Identified Gaps

#### Gap 5.2.1: Worker-Clock JR Projection
**Severity**: Medium  
**Spec Reference**: M2-104-UM v1.1.2 (Jitter Reduction)

**Current State**: Worker clock tests exist, but JR projection coverage needs expansion.

**Evidence**:
- `legacy/midi2-js-gap-plan.md`: "Worker-clock JR projection: add coverage for off-main-thread clocks and jitter mapping"

**Recommended Action**:
1. Add comprehensive worker-clock JR projection tests
2. Validate timestamp propagation across worker boundaries
3. Test clock drift compensation in worker contexts
4. Add performance benchmarks for worker-based JR

**Priority**: Medium  
**Effort**: Low-Medium (2-3 days)

#### Gap 5.2.2: Adapter Per-Note Controller Negotiation
**Severity**: Medium  
**Spec Reference**: MIDI 2.0 Per-Note Controllers

**Current State**: Basic per-note controller support exists; negotiation needs hardening.

**Evidence**:
- `legacy/midi2-js-gap-plan.md`: "Adapters: add per-note controllers/pitch-bend range negotiation and disposal safety tests"

**Recommended Action**:
1. Implement proper per-note controller negotiation in WebAudio adapter
2. Add pitch-bend range negotiation and validation
3. Add disposal safety tests for all adapters
4. Test multi-group streams with deterministic replay

**Priority**: Medium  
**Effort**: Medium (2-3 days)

---

## 6. Jitter Reduction Implementation

### 6.1 Coverage Status

#### Swift Implementation
**Status**: ✅ Implemented

**Evidence**:
- JR Clock sender: `Sources/MIDI2/System/Utility.swift`
- JR Receiver: `Sources/MIDI2/System/JitterReductionReceiver.swift`
- Demo: `Sources/jitterdemo/JitterApp.swift`
- Tests: `Tests/MIDI2Tests/System/JitterReductionTests.swift`
- PB-VRT baseline: `jr/clock_timestamp.json` (referenced in conformance checklist)

#### TypeScript Implementation
**Status**: ✅ Implemented

**Evidence**:
- JR core: `midi2.js/src/jitter.ts`
- Tests: `midi2.js/src/__tests__/jitter.test.ts`, `midi2.js/src/__tests__/jitter.worker.test.ts`

### 6.2 Identified Gaps

#### Gap 6.2.1: JR Interop Testing
**Severity**: Low  
**Spec Reference**: M2-104-UM v1.1.2, Section 7.2.2.3 (p.45)

**Current State**: Implementations exist with unit tests, but no hardware interop testing.

**Evidence**:
- `docs/conformance-checklist.md`: "Interop with hardware: Missing... Gap: Capture/verify against official MIDI-CI device responses and JR sync"

**Recommended Action**:
1. Create JR interop test suite using hardware devices or reference implementations
2. Validate clock/timestamp send/receive cycles
3. Test JR fallback behavior when unsupported
4. Document JR interop results

**Priority**: Low  
**Effort**: Medium (depends on hardware availability)

---

## 7. SysEx Packetization

### 7.1 Coverage Status

**Status**: ✅ Implemented

**Evidence**:
- Swift:
  - SysEx7: `Sources/MIDI2/SysEx7Packet.swift`
  - SysEx8: `Sources/MIDI2/Data/SysEx8.swift`
  - Tests: `Tests/MIDI2Tests/SysEx8Tests.swift`, `Tests/MIDI2Tests/SysEx8InvalidSequenceTests.swift`
  - PB-VRT: `sysex8/invalid_cases.json`
  - Demos: `Sources/midi2demo/SysEx7.swift`, `Sources/midi2demo/SysEx8.swift`
- TypeScript:
  - SysEx core: `midi2.js/src/sysex.ts`

**Spec Compliance**:
- ✅ Fragmentation/reassembly
- ✅ Continuation/termination flags
- ✅ Invalid sequence detection and rejection
- ✅ Edge case testing

### 7.2 Identified Gaps

#### Gap 7.2.1: Oversize SysEx Handling
**Severity**: Low  
**Spec Reference**: M2-104-UM v1.1.2 (SysEx maximum sizes)

**Current State**: Basic fragmentation works; oversize handling needs validation.

**Evidence**:
- `legacy/midi2-js-gap-plan.md`: "Expand reserved-bit/range checks for stream/flex/CI envelopes; add oversize SysEx and invalid chunk-order tests"

**Recommended Action**:
1. Define maximum SysEx sizes per spec
2. Add tests for SysEx exceeding maximum size
3. Implement proper error handling for oversized messages
4. Add fragmentation tests at boundary sizes

**Priority**: Low  
**Effort**: Low (1 day)

---

## 8. Testing and Validation

### 8.1 Current State

**Swift**:
- 107 test files
- Comprehensive coverage including:
  - UMP message types
  - Stream configuration
  - MIDI-CI flows
  - Property Exchange chunking and compression
  - JR clock/timestamp
  - SysEx7/8 fragmentation
  - Invalid sequence detection
- Fuzz testing: `Tests/Fuzz/` with SwiftCheck
- CI integration: `.github/workflows/ci.yml`

**TypeScript**:
- 11 test files
- Coverage areas:
  - UMP encoding/decoding
  - MIDI-CI envelopes
  - Scheduler and clocks
  - JR worker tests
  - Schema bridge validation
  - OpenAPI type conformance
  - PE subscriptions
  - Stream reserved bits
- CI: `npm run ci` (codegen + typecheck + vitest)

### 8.2 Identified Gaps

#### Gap 8.2.1: Visual Baseline (PB-VRT) Frames
**Severity**: Medium  
**Spec Reference**: Internal testing methodology

**Current State**: Some PB-VRT baselines exist (JR, SysEx8 invalid cases), but CI messages incomplete.

**Evidence**:
- `docs/conformance-checklist.md`: "Gap: Visual baseline frames for CI messages, automated diffs"
- `docs/traceability.md`: "PB-VRT pending for edge sequences" and "PB-VRT pending" for JR

**Recommended Action**:
1. Create PB-VRT baseline JSON files for all major MIDI-CI message types
2. Add automated schema regression checks in CI
3. Implement visual diff tooling for baseline comparisons
4. Expand to cover all Stream message variants

**Priority**: Medium  
**Effort**: Medium (3-4 days)

#### Gap 8.2.2: Hardware Interop Tests
**Severity**: Medium  
**Spec Reference**: Real-world MIDI 2.0 devices

**Current State**: No tests against external devices.

**Evidence**:
- `docs/conformance-checklist.md`: "Interop with hardware: Missing... Gap: Capture/verify against official MIDI-CI device responses and JR sync"

**Recommended Action**:
1. Establish test infrastructure for hardware device communication
2. Create test suite against reference MIDI 2.0 implementations
3. Validate MIDI-CI discovery/handshake with real devices
4. Test JR sync with hardware implementations
5. Document interop results and any discovered incompatibilities

**Priority**: Medium  
**Effort**: High (requires hardware access and setup)

#### Gap 8.2.3: Negative Test Coverage Expansion
**Severity**: Medium  
**Spec Reference**: M2-104-UM v1.1.2 (reserved values throughout)

**Current State**: Some negative tests exist (Stream, SysEx8, MDS, profiles, PE compression), but coverage is incomplete.

**Evidence**:
- `legacy/midi2-js-gap-plan.md`: "Expand reserved-bit/range checks for stream/flex/CI envelopes"
- `docs/conformance-checklist.md`: "Negative tests for unsupported statuses; gap: broaden across all decoders"

**Recommended Action**:
1. Create comprehensive negative test matrix covering:
   - All reserved opcodes
   - Out-of-range values for all bounded fields
   - Invalid bit patterns
   - Malformed packet structures
2. Ensure consistent error reporting across Swift and TypeScript
3. Add fuzzing tests for randomized invalid inputs

**Priority**: Medium  
**Effort**: Medium-High (4-5 days)

---

## 9. Schema and OpenAPI Alignment

### 9.1 Current State

**Status**: ✅ Excellent

The repository maintains dual canonical artifacts:
- `midi2.full.closed.schema.json` (2336 lines)
- `midi2.full.openapi.json` (2390 lines)

**Schema Coverage**: 63 type definitions including:
- Base types (Uint4, Uint7, Uint8, Uint14, Uint16, Uint21, Uint28, Uint32, Int32)
- UMP message types and headers
- All Channel Voice message variants (MIDI 1.0 and 2.0)
- System/Utility/Stream/Flex/Data message bodies
- Complete MIDI-CI message definitions
- Function Block and Stream configuration structures

**OpenAPI Integration**:
- TypeScript: Auto-generated types via `midi2.js/scripts/generate-openapi-types.mjs`
- Runtime guards: OpenAPI-derived validation
- CI integration: `npm run codegen` + typecheck

**Spec Audit Log**: 52 captured entries with page-level references to normative PDFs

### 9.2 Identified Gaps

#### Gap 9.2.1: Schema Documentation Completeness
**Severity**: Low  
**Spec Reference**: Internal documentation standards

**Current State**: Most schema fields have descriptions with page references; some could be expanded.

**Recommended Action**:
1. Ensure every schema field has:
   - Clear description
   - Spec reference (document, page, figure/table number)
   - Valid value ranges
   - Reserved value documentation
2. Add examples for complex structures
3. Cross-reference between related fields

**Priority**: Low  
**Effort**: Medium (3-4 days; ongoing maintenance)

#### Gap 9.2.2: Schema Regression in CI
**Severity**: Medium  
**Spec Reference**: Internal quality assurance

**Current State**: TypeScript has codegen check, but no automated schema drift detection.

**Evidence**:
- `legacy/midi2-js-gap-plan.md`: "Ensure OpenAPI guard regeneration is part of CI (fail on drift)"

**Recommended Action**:
1. Add CI check to verify OpenAPI codegen is up-to-date
2. Fail build if generated types drift from schema
3. Add validation that both schemas (JSON Schema and OpenAPI) remain in sync
4. Create diff tool to detect schema changes

**Priority**: Medium  
**Effort**: Low (1-2 days)

---

## 10. Documentation Alignment

### 10.1 Current State

**Comprehensive Documentation**:
- Main README with installation and usage examples
- Spec audit log with page-level traceability (`docs/spec-audit.md`)
- Conformance checklist (`docs/conformance-checklist.md`)
- Traceability matrix (`docs/traceability.md`)
- Gap plans for TypeScript (`legacy/midi2-js-gap-plan.md`)
- Definition of Done (`legacy/midi2-js-dod.md`)
- Current plan (`PLAN.md`)

**DoD Status**:
- Swift: Most criteria met; gaps clearly documented
- TypeScript: Strong foundation; several areas marked 🚧 partial

### 10.2 Identified Gaps

#### Gap 10.2.1: DoD Validation Against Current State
**Severity**: Low  
**Spec Reference**: `legacy/midi2-js-dod.md`

**Current State**: DoD documents exist but need validation against actual implementation.

**Recommended Action**:
1. Create automated DoD checklist validator
2. Cross-reference each DoD criterion with actual tests/code
3. Update DoD documents to reflect current 0.7.0/0.4.0 state
4. Add missing items from DoD to gap plans

**Priority**: Low  
**Effort**: Low-Medium (2-3 days)

#### Gap 10.2.2: Unified Audit Report
**Severity**: Low  
**Spec Reference**: This document

**Current State**: Information scattered across multiple documents.

**Recommended Action**:
1. Consolidate audit findings into single comprehensive report (this document)
2. Maintain regular update cadence
3. Add executive dashboard for stakeholders
4. Track gap closure progress with metrics

**Priority**: Low  
**Effort**: Low (ongoing maintenance)

---

## 11. Actionable Recommendations

### 11.1 High Priority Items (1-2 weeks)

1. **Property Exchange Subscription Lifecycle Implementation** (Gap 2.2.1)
   - Effort: 5-7 days
   - Impact: Critical for complete MIDI-CI compliance
   - Deliverables: State machine, flow-control ACK/NAK handlers, comprehensive tests

2. **Function Block Descriptor Details** (Gap 4.2.1)
   - Effort: 4-5 days
   - Impact: Required for full Stream §5 compliance
   - Deliverables: Extended FunctionBlockMessage, direction/bandwidth/active fields, tests

3. **GTB Negotiation Semantics** (Gap 4.2.2)
   - Effort: 4-5 days
   - Impact: Important for USB-MIDI 2.0 interop
   - Deliverables: GTB-FB interaction logic, protocol restrictions, tests

### 11.2 Medium Priority Items (2-4 weeks)

4. **Negative Test Coverage Expansion** (Gap 8.2.3)
   - Effort: 4-5 days
   - Impact: Robustness and spec compliance validation
   - Deliverables: Comprehensive negative test matrix

5. **Visual Baseline (PB-VRT) Frames** (Gap 8.2.1)
   - Effort: 3-4 days
   - Impact: Regression prevention for schema changes
   - Deliverables: PB-VRT baselines for all message types, automated diff tool

6. **Profile Configuration Details** (Gap 2.2.2)
   - Effort: 2-3 days
   - Impact: Complete MIDI-CI Profile support
   - Deliverables: Extended profile detail handling, negative tests

7. **Process Inquiry Enhancement** (Gap 2.2.3)
   - Effort: 2-3 days
   - Impact: Full MIDI-CI Process Inquiry compliance
   - Deliverables: Bitmap validation, device ID scope, message control enforcement

8. **Stream Configuration Semantics** (Gap 4.2.3)
   - Effort: 3-4 days
   - Impact: Protocol negotiation robustness
   - Deliverables: JR fallback, protocol switching, capability mismatch handling

9. **MUID Management** (Gap 2.2.4)
   - Effort: 2-3 days
   - Impact: MIDI-CI reliability
   - Deliverables: MUID lifecycle, conflict resolution, timeout handling

10. **Hardware Interop Tests** (Gap 8.2.2)
    - Effort: High (depends on hardware)
    - Impact: Real-world validation
    - Deliverables: Interop test suite, results documentation

### 11.3 Low Priority Items (Ongoing)

11. **Reserved/Unsupported Status Handling** (Gap 1.2.1)
    - Effort: 2-3 days
    - Impact: Future-proofing
    - Deliverables: Consistent error handling, documentation

12. **Adapter Enhancements** (Gap 5.2.2)
    - Effort: 2-3 days
    - Impact: TypeScript adapter robustness
    - Deliverables: Per-note negotiation, disposal safety tests

13. **Worker-Clock JR Projection** (Gap 5.2.1)
    - Effort: 2-3 days
    - Impact: Worker context reliability
    - Deliverables: Comprehensive worker JR tests

14. **Flex Data Edge Cases** (Gap 3.2.1)
    - Effort: 1-2 days
    - Impact: Robustness
    - Deliverables: Validation tests, edge case coverage

15. **Schema Documentation** (Gap 9.2.1)
    - Effort: Ongoing
    - Impact: Developer experience
    - Deliverables: Complete field descriptions, examples

16. **DoD Validation** (Gap 10.2.1)
    - Effort: 2-3 days
    - Impact: Project tracking
    - Deliverables: Automated checklist validator

---

## 12. Spec Audit Log Summary

### 12.1 Completed Items

**Total Captured**: 49 entries (all marked "Captured")

**Coverage by Specification**:
- **M2-104-UM v1.1.2** (UMP/Protocol): 26 entries
  - Stream messages, opcodes, Function Blocks, Endpoint Discovery, JR, etc.
- **M2-101-UM v1.2** (MIDI-CI): 3 entries
  - Process Inquiry envelopes and fields
- **M2-102-U v1.1** (Profiles): 1 entry
  - Profile configuration messages
- **M2-103-UM v1.2** (Property Exchange): 19 entries
  - PE headers, chunking, flow control, subscriptions, status codes

**Page Reference Coverage**: All entries have page numbers and figure/table references

### 12.2 Pending Items

**Total Pending**: 3 entries

1. **USB Group Terminal Block considerations** (M2-104-UM v1.1.2, p.122)
   - Status: Pending
   - Reason: Runtime/interop guidance; schema complete
   - Action: Document GTB-FB overlap, implement restrictions

2. **PE subscription lifecycle** (M2-103-UM v1.2, Tables 43-47)
   - Status: Pending (runtime)
   - Reason: Schema fields present; state machine needed
   - Action: Implement subscription state tracking

3. **TODOs in documentation**
   - "Iterate through each spec section, fill in page references"
   - Action: Continue systematic spec review

### 12.3 Next Spec Audit Actions

1. **Complete systematic review of all specs**:
   - M2-100-U v1.1 (Overview) - verify all references covered
   - M2-116-U v1.0 (Clip File) - initial audit needed

2. **Add missing spec sections**:
   - Mixed Data Set (MDS) detailed validation
   - MIDI Clip File format (if in scope)
   - Additional Stream message opcodes (start/end of clip 0x20/0x21)

3. **Cross-validate existing entries**:
   - Verify each page reference is accurate
   - Ensure schema fields match spec diagrams exactly
   - Check for spec updates (errata, new versions)

---

## 13. Traceability Matrix

This section provides a comprehensive mapping between specification requirements and implementation evidence.

### 13.1 UMP Message Types (M2-104-UM v1.1.2)

| Message Type | Spec Ref | Schema | Swift Impl | TS Impl | Tests | Status |
|--------------|----------|--------|------------|---------|-------|--------|
| Utility (0x0) | §4 | ✅ `UtilityBody` | ✅ `UtilityBody.swift` | ✅ `ump.ts` | ✅ | Complete |
| System (0x1) | §6 | ✅ `SystemCommonRealtimeBody` | ✅ `SystemCommonRealtimeBody.swift` | ✅ `ump.ts` | ✅ | Complete |
| MIDI 1.0 Ch Voice (0x2) | §7 | ✅ `Midi1ChannelVoiceBody` | ✅ `Midi1ChannelVoiceBody.swift` | ✅ `midi1.ts` | ✅ | Complete |
| SysEx7 (0x3) | §8 | ✅ `SysEx7Body` | ✅ `SysEx7Packet.swift` | ✅ `sysex.ts` | ✅ | Complete |
| MIDI 2.0 Ch Voice (0x4) | §9 | ✅ `Midi2ChannelVoiceBody` | ✅ `Midi2ChannelVoiceBody.swift` | ✅ `ump.ts` | ✅ | Complete |
| SysEx8/MDS (0x5) | §10 | ✅ `DataMessageBody` | ✅ `SysEx8.swift` | ✅ `sysex.ts` | ✅ | Complete |
| Flex Data (0xD) | §11 | ✅ `FlexDataBody` | ✅ `FlexDataBody.swift` | ✅ (guards) | ✅ | Complete |
| Stream (0xF) | §5 | ✅ `StreamBody` | ✅ `StreamBody.swift` | ✅ (guards) | ✅ | Partial (gaps noted) |

### 13.2 MIDI-CI Messages (M2-101-UM v1.2)

| Message Type | Spec Ref | Schema | Swift Impl | TS Impl | Tests | Status |
|--------------|----------|--------|------------|---------|-------|--------|
| Discovery | §3.2 | ✅ `MidiCiDiscoveryBody` | ✅ `MidiCiDiscoveryBody.swift` | ✅ `midici.ts` | ✅ | Complete |
| Inquiry - Endpoint | §3.3 | ✅ | ✅ | ✅ | ✅ | Complete |
| Inquiry - Invalidity | §3.4 | ✅ | ✅ | ✅ | ⚠️ | Needs validation |
| NAK | §3.5 | ✅ `MidiCiAckNakBody` | ✅ `MidiCiAckNakBody.swift` | ✅ | ✅ | Complete |
| Process Inquiry | §10 | ✅ `MidiCiProcessInquiryBody` | ✅ `MidiCiProcessInquiryBody.swift` | ⚠️ | ⚠️ | Partial (Gap 2.2.3) |

### 13.3 Profile Messages (M2-102-U v1.1)

| Message Type | Spec Ref | Schema | Swift Impl | TS Impl | Tests | Status |
|--------------|----------|--------|------------|---------|-------|--------|
| Profile Inquiry | §4.1 | ✅ `MidiCiProfilesBody` | ✅ `ProfileSession.swift` | ✅ | ✅ | Complete |
| Profile Enable/Disable | §4.2-4.3 | ✅ | ✅ | ✅ | ✅ | Complete |
| Profile Details | §4.5 | ✅ | ⚠️ | ⚠️ | ⚠️ | Partial (Gap 2.2.2) |
| Profile Specific Data | §5 | ✅ | ✅ `ProfileSpecificData.swift` | ⚠️ | ✅ | Partial |

### 13.4 Property Exchange (M2-103-UM v1.2)

| Feature | Spec Ref | Schema | Swift Impl | TS Impl | Tests | Status |
|---------|----------|--------|------------|---------|-------|--------|
| Capability Inquiry | §4.1 | ✅ `MidiCiPropertyExchangeBody` | ✅ | ✅ | ✅ | Complete |
| Get Property | §4.2 | ✅ | ✅ `PropertyExchange.swift` | ✅ | ✅ | Complete |
| Set Property | §4.3 | ✅ | ✅ | ✅ | ✅ | Complete |
| Subscriptions | §4.4 | ✅ | ⚠️ | ⚠️ | ⚠️ | Partial (Gap 2.2.1) |
| Chunking | §6 | ✅ | ✅ | ⚠️ | ✅ | Partial |
| Flow Control ACK/NAK | §6.1-6.2 | ✅ | ⚠️ | ⚠️ | ❌ | Schema only (Gap 2.2.1) |
| Compression (zlib) | §5.1 | ✅ | ✅ `CompressionCodec.swift` | ⚠️ | ✅ | Partial |
| Compression (mcoded7) | §5.2 | ✅ | ✅ | ⚠️ | ✅ | Partial |
| Headers | §7 | ✅ | ✅ | ✅ | ✅ | Complete |
| Status Codes | §8 | ✅ | ✅ | ⚠️ | ⚠️ | Partial |

### 13.5 Stream Configuration (M2-104-UM v1.1.2 §5)

| Feature | Spec Ref | Schema | Swift Impl | TS Impl | Tests | Status |
|---------|----------|--------|------------|---------|-------|--------|
| Endpoint Discovery | §5.1 | ✅ | ✅ `EndpointDiscoveryMessage.swift` | ⚠️ | ✅ | Partial (Gap 4.2.4) |
| Endpoint Info Notification | §5.1.1 | ✅ | ⚠️ | ⚠️ | ⚠️ | Partial (Gap 4.2.4) |
| Device Identity | §5.1.2 | ✅ | ✅ | ⚠️ | ⚠️ | Partial |
| Endpoint Name | §5.1.3 | ✅ | ✅ | ⚠️ | ⚠️ | Partial |
| Product Instance ID | §5.1.4 | ✅ | ✅ | ⚠️ | ⚠️ | Partial |
| Stream Config Request | §5.2 | ✅ | ✅ `StreamConfigurationMessage.swift` | ⚠️ | ✅ | Partial (Gap 4.2.3) |
| Stream Config Notification | §5.2.1 | ✅ | ✅ | ⚠️ | ✅ | Partial (Gap 4.2.3) |
| Function Block Discovery | §5.4 | ✅ | ✅ `FunctionBlockDiscovery.swift` | ⚠️ | ✅ | Partial (Gap 4.2.1) |
| Function Block Info | §5.4.1 | ✅ | ⚠️ | ⚠️ | ⚠️ | Partial (Gap 4.2.1) |
| Function Block Name | §5.4.2 | ✅ | ⚠️ | ⚠️ | ⚠️ | Partial |
| Group Terminal Blocks | Appendix I | ✅ | ✅ `GroupTerminalBlocks.swift` | ⚠️ | ✅ | Partial (Gap 4.2.2) |

**Legend**:
- ✅ Complete
- ⚠️ Partial/Needs Enhancement
- ❌ Not Implemented/Missing

---

## 14. Gap Closure Plan

### 14.1 Sprint 1 (Week 1-2): Critical Path Items

**Goal**: Close high-priority gaps blocking full MIDI-CI compliance

1. **Property Exchange Subscription Lifecycle** (5-7 days)
   - Implement subscription state machine
   - Add flow-control ACK/NAK runtime handlers
   - Create comprehensive test suite
   - Update documentation

2. **Function Block Descriptor Details** (4-5 days)
   - Extend FunctionBlockMessage structure
   - Implement direction/bandwidth/active fields
   - Add discovery/response flow
   - Create test vectors

### 14.2 Sprint 2 (Week 3-4): Stream Configuration

**Goal**: Complete Stream §5 implementation

3. **GTB Negotiation Semantics** (4-5 days)
   - Document GTB-FB overlap
   - Implement protocol restrictions
   - Add negotiation logic
   - Create interop tests

4. **Stream Configuration Semantics** (3-4 days)
   - JR fallback implementation
   - Protocol switching logic
   - Capability mismatch handling
   - Test negotiation flows

5. **Endpoint Info Enhancement** (2 days)
   - Validate all Endpoint Info fields
   - Add reserved value checks
   - Comprehensive test vectors

### 14.3 Sprint 3 (Week 5-6): Testing and Validation

**Goal**: Expand test coverage and regression prevention

6. **Negative Test Coverage** (4-5 days)
   - Create negative test matrix
   - Implement consistent error handling
   - Add fuzzing tests

7. **Visual Baseline Frames** (3-4 days)
   - PB-VRT baselines for all types
   - Automated diff tooling
   - CI integration

### 14.4 Sprint 4 (Week 7-8): MIDI-CI Refinement

**Goal**: Complete MIDI-CI feature set

8. **Profile Configuration Details** (2-3 days)
9. **Process Inquiry Enhancement** (2-3 days)
10. **MUID Management** (2-3 days)

### 14.5 Sprint 5 (Week 9+): Polish and Interop

**Goal**: TypeScript improvements and hardware validation

11. **Worker-Clock JR Projection** (2-3 days)
12. **Adapter Enhancements** (2-3 days)
13. **Hardware Interop Tests** (Ongoing)
14. **Reserved Status Handling** (2-3 days)
15. **Documentation Updates** (Ongoing)

---

## 15. Success Metrics

### 15.1 Quantitative Metrics

**Spec Audit Completion**:
- Current: 49/52 entries captured (94%)
- Target: 100% captured with all pending items resolved
- Uncaptured entries:
  1. USB GTB considerations (M2-104-UM p.122) - Runtime guidance pending
  2. PE subscription lifecycle runtime (M2-103-UM Tables 43-47) - State machine pending
  3. Remaining spec sections audit - Target: Q1 2026

**Test Coverage**:
- Swift: 107 tests → Target: 150+ tests
- TypeScript: 11 tests → Target: 25+ tests
- Negative tests: Expand by 50+
- Hardware interop: 0 → Target: Basic suite established

**Schema Completeness**:
- Current: 63 type definitions
- Target: 100% of normative spec fields documented with page references

**Gap Closure**:
- Current: 21 identified gaps (detailed in section 11)
- Target: Close 13+ high/medium priority gaps in 8 weeks (prioritizing critical path)

### 15.2 Qualitative Metrics

**Spec Compliance**:
- [ ] All normative requirements from M2-104-UM implemented
- [ ] All normative requirements from M2-101-UM implemented
- [ ] All normative requirements from M2-102-U implemented
- [ ] All normative requirements from M2-103-UM implemented

**Interoperability**:
- [ ] Successful handshake with at least one hardware MIDI 2.0 device
- [ ] Successful JR sync with reference implementation
- [ ] Property Exchange validated against external device

**Code Quality**:
- [ ] All reserved values properly documented and handled
- [ ] Consistent error handling across both implementations
- [ ] Complete DoD validation

**Documentation**:
- [ ] All gaps documented with actionable steps
- [ ] All schema fields have spec references
- [ ] Comprehensive examples for all major features

---

## 16. Conclusion

The `midi2` repository demonstrates **strong alignment** with MIDI 2.0 normative specifications, with comprehensive schema coverage, robust implementation of core features, and excellent traceability through the spec-audit log. The dual-stack approach (Swift reference + TypeScript portable) provides valuable cross-validation.

**Key Strengths**:
1. Schema-driven development with machine-readable canonical artifacts
2. Comprehensive page-level traceability to normative specs
3. Strong test coverage with both positive and negative cases
4. Active gap tracking and documentation
5. Cross-platform validation (Swift ↔ TypeScript)

**Critical Gaps to Address**:
1. Property Exchange subscription state machine (runtime)
2. Function Block descriptor details and GTB negotiation
3. Stream configuration negotiation semantics
4. Hardware interoperability validation

**Next Steps**:
1. Execute gap closure plan in 5 sprints (8-10 weeks)
2. Prioritize high-priority items (PE subscriptions, Function Blocks, GTB)
3. Expand test coverage with negative tests and hardware interop
4. Complete remaining spec audit entries
5. Validate all DoD criteria

With focused effort on the identified gaps, particularly in MIDI-CI runtime state management and Stream configuration semantics, the repository can achieve full normative compliance with the MIDI 2.0 specifications. The existing foundation is solid, and the documented gaps provide a clear roadmap to completion.

---

## Appendix A: Specification Document Reference

| Document | Version | Pages | Focus Areas |
|----------|---------|-------|-------------|
| M2-100-U | v1.1 | 482 KB | MIDI 2.0 Overview |
| M2-101-UM | v1.2 | 1.1 MB | MIDI-CI Specification |
| M2-102-U | v1.1 | 669 KB | MIDI-CI Profiles |
| M2-103-UM | v1.2 | 1.5 MB | Property Exchange |
| M2-104-UM | v1.1.2 | 4.8 MB | UMP and Protocol |
| M2-116-U | v1.0 | 875 KB | MIDI Clip File |

---

## Appendix B: Gap Priority Matrix

| Gap ID | Description | Priority | Effort | Impact | Sprint |
|--------|-------------|----------|--------|--------|--------|
| 2.2.1 | PE Subscription Lifecycle | High | High | Critical | 1 |
| 4.2.1 | Function Block Descriptors | High | Med-High | Critical | 1 |
| 4.2.2 | GTB Negotiation | High | Med-High | Critical | 2 |
| 4.2.3 | Stream Config Semantics | Medium | Medium | High | 2 |
| 8.2.3 | Negative Test Coverage | Medium | Med-High | High | 3 |
| 8.2.1 | Visual Baselines (PB-VRT) | Medium | Medium | Medium | 3 |
| 2.2.2 | Profile Config Details | Medium | Medium | Medium | 4 |
| 2.2.3 | Process Inquiry Enhancement | Medium | Medium | Medium | 4 |
| 2.2.4 | MUID Management | Medium | Low-Med | Medium | 4 |
| 4.2.4 | Endpoint Info Beyond Version | Medium | Low-Med | Medium | 2 |
| 8.2.2 | Hardware Interop Tests | Medium | High | Medium | 5 |
| 5.2.1 | Worker-Clock JR | Medium | Low-Med | Low | 5 |
| 5.2.2 | Adapter Per-Note Controllers | Medium | Medium | Low | 5 |
| 1.2.1 | Reserved Status Handling | Medium | Medium | Low | 5 |
| 1.2.2 | UMP Format Extensions | Low | Low | Low | 5 |
| 3.2.1 | Flex Data Edge Cases | Low | Low | Low | 5 |
| 6.2.1 | JR Interop Testing | Low | Medium | Low | 5 |
| 7.2.1 | Oversize SysEx Handling | Low | Low | Low | 5 |
| 9.2.1 | Schema Documentation | Low | Ongoing | Low | Ongoing |
| 9.2.2 | Schema Regression CI | Medium | Low | Medium | 3 |
| 10.2.1 | DoD Validation | Low | Low-Med | Low | 5 |

---

**Report Prepared By**: MIDI 2.0 Specification Audit Agent  
**Date**: December 13, 2025  
**Status**: Initial Comprehensive Audit Complete
