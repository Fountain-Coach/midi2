# MIDI 2.0 Gap Closure Tracker

**Last Updated**: 2025-12-13  
**Related Documents**: 
- `comprehensive-spec-audit-report.md` - Full audit analysis
- `spec-audit.md` - Page-level spec references
- `conformance-checklist.md` - Implementation status
- `legacy/midi2-js-gap-plan.md` - TypeScript gap plan

---

## Status Legend

- 🔴 **Not Started** - Gap identified but no work begun
- 🟡 **In Progress** - Active development
- 🟢 **Complete** - Gap closed and validated
- ⏸️ **Blocked** - Waiting on external dependency

---

## High Priority Gaps (Critical Path)

### Gap 2.2.1: Property Exchange Subscription Lifecycle
**Status**: 🔴 Not Started  
**Priority**: High | **Effort**: 5-7 days | **Target Sprint**: 1

**Spec Reference**: M2-103-UM v1.2, Tables 43-47 (p.42-43)

**Current State**:
- ✅ Schema fields captured (`MidiCiPropertyExchangeBody.subscriptionCommand`)
- ❌ Runtime state machine not implemented
- ❌ Flow-control ACK/NAK handlers missing
- ❌ Subscription tracking absent

**Acceptance Criteria**:
- [ ] Subscription state machine implemented (start → partial → full → notify → end)
- [ ] Flow-control ACK handler with chunk number tracking
- [ ] Flow-control NAK handler with retransmit logic
- [ ] Resource-level flow-control capability negotiation
- [ ] Active subscription map/tracker
- [ ] Comprehensive test suite covering:
  - [ ] Subscription lifecycle sequences
  - [ ] Partial vs. full update patterns
  - [ ] Flow-control ACK timeout handling
  - [ ] NAK retransmit scenarios
  - [ ] Error conditions (406/407 status codes)
- [ ] Documentation updated

**Implementation Steps**:
1. Design subscription state machine
2. Implement `SubscriptionTracker` class (Swift) / module (TS)
3. Add flow-control ACK/NAK message handlers
4. Implement chunk validation and retransmit
5. Add resource capability checking
6. Create test fixtures from M2-103-UM Tables 43-47
7. Update PropertyExchange.swift and pe-subscriptions.ts

**Files to Modify**:
- Swift: `Sources/MIDI2CI/PropertyExchange.swift`
- TypeScript: `midi2.js/src/pe-subscriptions.ts`
- Tests: Add `PropertyExchangeSubscriptionTests.swift` and update `pe-subscriptions.test.ts`

**Dependencies**: None

---

### Gap 4.2.1: Function Block Descriptor Details
**Status**: 🟡 In Progress  
**Priority**: High | **Effort**: 4-5 days | **Target Sprint**: 1

**Spec Reference**: M2-104-UM v1.1.2, Figure 22 (p.40), Appendix I (p.122)

**Current State**:
- ✅ Basic fields (index, firstGroup, groupCount)
- 🟡 TypeScript decode validation for active/direction/midi1Bandwidth + reserved bits (2025-12-13)
- 🟡 Swift typed `FunctionBlockInfoNotification` wrapper (64-bit) with direction/bandwidth/active validation (2025-12-13)
- ❌ UI hints not captured
- ❌ Discovery/response flow semantics incomplete

**Acceptance Criteria**:
- [ ] Extended `FunctionBlockMessage` structure with:
  - [ ] `direction: Direction` enum (.reserved, .input, .output, .bidirectional)
  - [ ] `midi1Bandwidth: Bandwidth` enum (.notMidi1, .unrestricted, .restrict31_25kbps, .reserved)
  - [ ] `active: Bool`
  - [ ] UI hints field
- [ ] Runtime validation of all field values
- [ ] Discovery/response flow implementation
- [ ] Profile report associations
- [ ] Tests validating:
  - [ ] All direction values
  - [ ] All bandwidth values
  - [ ] Active flag transitions
  - [ ] Reserved value rejection
  - [ ] Discovery flow sequences
- [ ] Documentation with Figure 22 cross-reference

**Implementation Steps**:
1. Add Direction and Bandwidth enums
2. Extend FunctionBlockMessage bit field parsing
3. Add validation for reserved values
4. Implement discovery request/response handling
5. Create profile-FB association logic
6. Add comprehensive tests per Figure 22
7. Update schema documentation

**Files to Modify**:
- Swift: `Sources/MIDI2/Stream/FunctionBlockMessage.swift`
- Swift: `Sources/MIDI2/Stream/FunctionBlockDiscovery.swift`
- TypeScript: Schema bridge for OpenAPI types
- Tests: `Tests/MIDI2Tests/StreamFunctionBlockDiscoveryTests.swift`
- Schema: `midi2.full.closed.schema.json` (add direction/bandwidth/active)

**Dependencies**: None

---

### Gap 4.2.2: GTB Negotiation Semantics
**Status**: 🔴 Not Started  
**Priority**: High | **Effort**: 4-5 days | **Target Sprint**: 2

**Spec Reference**: M2-104-UM v1.1.2, Appendix I (p.122)

**Current State**:
- ✅ GTB structure defined (`GroupTerminalBlocks.swift`)
- ✅ Basic GTB tests
- ❌ GTB-Function Block overlap logic missing
- ❌ MT=0xF/MT=0x0 reception restrictions not enforced
- ❌ Protocol negotiation for GTB contexts incomplete

**Acceptance Criteria**:
- [ ] GTB-Function Block overlap documented and validated
- [ ] MT=0xF stream message reception restrictions enforced
- [ ] MT=0x0 utility message reception restrictions enforced
- [ ] Protocol negotiation logic for GTB contexts
- [ ] Tests covering:
  - [ ] GTB-FB overlap scenarios
  - [ ] Message type restriction enforcement
  - [ ] Protocol negotiation with GTB
  - [ ] Invalid GTB configurations
- [ ] Documentation updated with Appendix I guidance

**Implementation Steps**:
1. Document GTB-FB overlap rules from Appendix I
2. Add GTB validation against Function Block configuration
3. Implement message type reception restrictions
4. Add protocol negotiation state machine for GTB
5. Create test scenarios from Appendix I examples
6. Update runtime documentation

**Files to Modify**:
- Swift: `Sources/MIDI2/Stream/GroupTerminalBlocks.swift`
- Swift: Add `Sources/MIDI2/Stream/GTBNegotiation.swift` (new)
- Tests: `Tests/MIDI2Tests/GroupTerminalBlocksTests.swift`
- Docs: Add GTB negotiation guide

**Dependencies**: Gap 4.2.1 (Function Block details)

---

## Medium Priority Gaps (Sprint 2-4)

### Gap 4.2.3: Stream Configuration Semantics
**Status**: 🔴 Not Started  
**Priority**: Medium | **Effort**: 3-4 days | **Target Sprint**: 2

**Spec Reference**: M2-104-UM v1.1.2, Figures 18/19 (p.37-38), Section 7.2.2.3 (p.45)

**Current State**:
- ✅ Protocol bits defined (0x01 MIDI 1.0, 0x02 MIDI 2.0)
- ✅ JR Tx/Rx flags in schema
- ❌ JR fallback behavior not implemented
- ❌ Protocol switching logic incomplete
- ❌ Stream Config Notification on mismatch missing

**Acceptance Criteria**:
- [ ] JR fallback when receiver doesn't support JR
- [ ] Protocol switching (MIDI 1.0 ↔ MIDI 2.0)
- [ ] Stream Config Notification sending on capability mismatch
- [ ] Tests for negotiation failures and fallbacks
- [ ] Documentation of negotiation flows

**Implementation Steps**:
1. Implement JR capability checking
2. Add JR fallback to non-timestamped mode
3. Implement protocol switching state machine
4. Add Stream Config Notification generation
5. Create negotiation test scenarios
6. Document negotiation patterns

**Files to Modify**:
- Swift: `Sources/MIDI2/Stream/StreamConfigurationMessage.swift`
- Swift: Add `Sources/MIDI2/Stream/NegotiationSession.swift` updates
- Tests: Add negotiation test cases

**Dependencies**: None

---

### Gap 8.2.3: Negative Test Coverage Expansion
**Status**: 🔴 Not Started  
**Priority**: Medium | **Effort**: 4-5 days | **Target Sprint**: 3

**Spec Reference**: M2-104-UM v1.1.2 (reserved values throughout)

**Current State**:
- ✅ Some negative tests (Stream, SysEx8, MDS, profiles, PE compression)
- ❌ Incomplete coverage across all decoders
- ❌ No comprehensive reserved value matrix

**Acceptance Criteria**:
- [ ] Negative test matrix covering:
  - [ ] All reserved opcodes per message type
  - [ ] Out-of-range values for bounded fields
  - [ ] Invalid bit patterns
  - [ ] Malformed packet structures
- [ ] Consistent error reporting Swift ↔ TypeScript
- [ ] Fuzzing tests for randomized invalid inputs
- [ ] Documentation of reserved value handling

**Implementation Steps**:
1. Create comprehensive reserved value matrix from specs
2. Add negative tests for each message type
3. Implement consistent error types/messages
4. Add fuzzing test suite
5. Document reserved value handling strategy

**Files to Modify**:
- Tests: `Tests/MIDI2Tests/NegativeTests/` (new directory)
- Tests: `midi2.js/src/__tests__/negative.test.ts` (new)
- Tests: `Tests/Fuzz/` - expand fuzzing

**Dependencies**: None

---

### Gap 8.2.1: Visual Baseline (PB-VRT) Frames
**Status**: 🔴 Not Started  
**Priority**: Medium | **Effort**: 3-4 days | **Target Sprint**: 3

**Spec Reference**: Internal testing methodology

**Current State**:
- ✅ Some PB-VRT baselines (JR, SysEx8 invalid cases)
- ❌ CI message baselines incomplete
- ❌ No automated diff tooling

**Acceptance Criteria**:
- [ ] PB-VRT baseline JSON files for:
  - [ ] All MIDI-CI message types
  - [ ] All Stream message variants
  - [ ] Function Block messages
  - [ ] Flex Data types
- [ ] Automated schema regression checks in CI
- [ ] Visual diff tooling for baseline comparisons
- [ ] Documentation of PB-VRT methodology

**Implementation Steps**:
1. Create baseline JSON files in `docs/pb-vrt/`
2. Implement schema diff tool
3. Add CI check for baseline regression
4. Document PB-VRT process

**Files to Create**:
- `docs/pb-vrt/midici/*.json`
- `docs/pb-vrt/stream/*.json`
- `docs/pb-vrt/flex/*.json`
- `Scripts/verify_pb_vrt.py` (new)

**Dependencies**: None

---

### Gap 2.2.2: Profile Configuration Details
**Status**: 🔴 Not Started  
**Priority**: Medium | **Effort**: 2-3 days | **Target Sprint**: 4

**Spec Reference**: M2-102-U v1.1, Table 6 (p.15, 17)

**Current State**:
- ✅ Basic details replies (version, channel mask)
- ✅ PSD supported
- ✅ Added/removed helpers
- ❌ Negative tests for detail reports missing
- ❌ Profile detail report handling incomplete

**Acceptance Criteria**:
- [ ] Expanded profile detail report handling
- [ ] Comprehensive tests for added/removed notifications
- [ ] Profile configuration change tracking
- [ ] Negative test cases for malformed messages
- [ ] Documentation updates

**Implementation Steps**:
1. Review M2-102-U Table 6 requirements
2. Expand ProfileSession detail handling
3. Add profile change tracking
4. Create negative test suite
5. Update documentation

**Files to Modify**:
- Swift: `Sources/MIDI2CI/ProfileSession.swift`
- Tests: `Tests/MIDI2Tests/ProfileSessionTests.swift`

**Dependencies**: None

---

### Gap 2.2.3: Process Inquiry Enhancement
**Status**: 🔴 Not Started  
**Priority**: Medium | **Effort**: 2-3 days | **Target Sprint**: 4

**Spec Reference**: M2-101-UM v1.2, Tables 40-42 (p.59-60)

**Current State**:
- ✅ Envelopes captured
- ✅ Basic session support
- ❌ Supported features bitmap validation incomplete
- ❌ Device ID scope handling missing
- ❌ Message data control enforcement incomplete

**Acceptance Criteria**:
- [ ] Supported features bitmap validation (D0 bit = MIDI Message Report)
- [ ] Device ID scope handling (0x00-0x0F, 0x7E, 0x7F)
- [ ] Message data control value enforcement (0x00/0x01/0x7F)
- [ ] Tests for system/channel/note message request bitmaps
- [ ] Documentation updates

**Implementation Steps**:
1. Implement features bitmap validation
2. Add device ID scope checking
3. Add message data control enforcement
4. Create test vectors from Tables 40-42
5. Update ProcessInquirySession

**Files to Modify**:
- Swift: `Sources/MIDI2CI/ProcessInquirySession.swift`
- Swift: `Sources/MIDI2/MidiCiProcessInquiryBody.swift`
- Tests: Add ProcessInquiry tests

**Dependencies**: None

---

### Gap 2.2.4: MUID Management
**Status**: 🔴 Not Started  
**Priority**: Medium | **Effort**: 2-3 days | **Target Sprint**: 4

**Spec Reference**: M2-101-UM v1.2 (MUID allocation/discovery)

**Current State**:
- ✅ Basic MUID handling
- ❌ Comprehensive lifecycle management missing
- ❌ Conflict detection missing
- ❌ Timeout/cleanup missing

**Acceptance Criteria**:
- [ ] MUID allocation/deallocation logic
- [ ] MUID conflict detection and resolution
- [ ] MUID timeout and cleanup
- [ ] Tests for MUID lifecycle scenarios
- [ ] Documentation of MUID management

**Implementation Steps**:
1. Implement MUID allocator
2. Add conflict detection
3. Add timeout tracking
4. Create lifecycle tests
5. Document MUID strategy

**Files to Modify**:
- Swift: `Sources/MIDI2CI/MuidManager.swift` (new)
- Tests: Add MUID tests

**Dependencies**: None

---

### Gap 4.2.4: Endpoint Info Beyond Version/Max Groups
**Status**: 🟢 Complete  
**Priority**: Medium | **Effort**: 2 days | **Target Sprint**: 2

**Spec Reference**: M2-104-UM v1.1.2, Figure 13 (p.33)

**Current State**:
- ✅ Schema has all fields defined
- 🟢 TypeScript runtime validation/tests added (reserved bit and NFB guard) 2025-12-13
- 🟢 Swift runtime validation/tests added 2025-12-13

**Acceptance Criteria**:
- [x] All Endpoint Info fields properly encoded/decoded
- [x] Reserved numberOfFunctionBlocks validation (0x21-0x7F) — TypeScript + Swift decode guard + tests
- [x] Comprehensive test vectors (Swift + cross-impl)
- [x] Documentation updates (tracker + test references)

**Implementation Steps**:
1. Add full field encoding/decoding
2. Add reserved value validation
3. Create test vectors
4. Update documentation

**Files to Modify**:
- Swift: `Sources/MIDI2/Stream/EndpointDiscoveryMessage.swift`
- Swift: `Sources/MIDI2/Stream/EndpointInfoMessage.swift` ✅
- Swift Tests: `Tests/MIDI2Tests/StreamMappingTests.swift` ✅
- TypeScript: `midi2.js/src/ump.ts` (decode validation) ✅
- TypeScript Tests: `midi2.js/src/__tests__/ump.test.ts` ✅

**Dependencies**: None

---

### Gap 8.2.2: Hardware Interop Tests
**Status**: 🔴 Not Started  
**Priority**: Medium | **Effort**: High (ongoing) | **Target Sprint**: 5

**Spec Reference**: Real-world MIDI 2.0 devices

**Current State**:
- ❌ No hardware interop tests

**Acceptance Criteria**:
- [ ] Test infrastructure for hardware communication
- [ ] Reference MIDI 2.0 device test suite
- [ ] MIDI-CI discovery/handshake validation
- [ ] JR sync testing
- [ ] Interop results documented

**Implementation Steps**:
1. Set up hardware test environment
2. Identify reference devices
3. Create interop test suite
4. Run validation tests
5. Document results and incompatibilities

**Files to Create**:
- `Tests/HardwareInterop/` (new directory)
- `docs/hardware-interop-results.md`

**Dependencies**: Hardware access

---

## Low Priority Gaps (Sprint 5+)

### Gap 1.2.1: Reserved/Unsupported Status Handling
**Status**: 🔴 Not Started  
**Priority**: Medium | **Effort**: 2-3 days | **Target Sprint**: 5

**Acceptance Criteria**:
- [ ] Comprehensive reserved opcode table
- [ ] Consistent error handling across decoders
- [ ] Negative test vectors
- [ ] Schema documentation of reserved values

---

### Gap 5.2.2: Adapter Per-Note Controller Negotiation
**Status**: 🔴 Not Started  
**Priority**: Medium | **Effort**: 2-3 days | **Target Sprint**: 5

**Acceptance Criteria**:
- [ ] Per-note controller negotiation in WebAudio
- [ ] Pitch-bend range negotiation/validation
- [ ] Disposal safety tests for all adapters
- [ ] Multi-group deterministic replay tests

---

### Gap 5.2.1: Worker-Clock JR Projection
**Status**: 🔴 Not Started  
**Priority**: Medium | **Effort**: 2-3 days | **Target Sprint**: 5

**Acceptance Criteria**:
- [ ] Comprehensive worker-clock JR tests
- [ ] Timestamp propagation validation
- [ ] Clock drift compensation tests
- [ ] Performance benchmarks

---

### Gap 3.2.1: Flex Data Edge Cases
**Status**: 🔴 Not Started  
**Priority**: Low | **Effort**: 1-2 days | **Target Sprint**: 5

**Acceptance Criteria**:
- [ ] Comprehensive Flex Data validation
- [ ] Edge case tests (max lengths, invalid values)
- [ ] Reserved opcode handling

---

### Gap 1.2.2: UMP Format Extensions
**Status**: 🔴 Not Started  
**Priority**: Low | **Effort**: 1 day | **Target Sprint**: 5

**Acceptance Criteria**:
- [ ] Document supported utility opcodes
- [ ] Placeholders for future types
- [ ] Forward compatibility in schema

---

### Gap 6.2.1: JR Interop Testing
**Status**: 🔴 Not Started  
**Priority**: Low | **Effort**: Medium | **Target Sprint**: 5

**Acceptance Criteria**:
- [ ] JR interop test suite
- [ ] Clock/timestamp validation
- [ ] Fallback behavior testing

---

### Gap 7.2.1: Oversize SysEx Handling
**Status**: 🔴 Not Started  
**Priority**: Low | **Effort**: 1 day | **Target Sprint**: 5

**Acceptance Criteria**:
- [ ] Maximum SysEx size validation
- [ ] Oversize error handling
- [ ] Boundary fragmentation tests

---

### Gap 9.2.1: Schema Documentation Completeness
**Status**: 🔴 Not Started  
**Priority**: Low | **Effort**: Ongoing | **Target Sprint**: Ongoing

**Acceptance Criteria**:
- [ ] All fields with descriptions
- [ ] All fields with spec references
- [ ] Examples for complex structures

---

### Gap 9.2.2: Schema Regression CI
**Status**: 🔴 Not Started  
**Priority**: Medium | **Effort**: 1-2 days | **Target Sprint**: 3

**Acceptance Criteria**:
- [ ] CI check for OpenAPI codegen drift
- [ ] Schema sync validation (JSON Schema ↔ OpenAPI)
- [ ] Diff tool for schema changes

---

### Gap 10.2.1: DoD Validation
**Status**: 🔴 Not Started  
**Priority**: Low | **Effort**: 2-3 days | **Target Sprint**: 5

**Acceptance Criteria**:
- [ ] Automated DoD checklist validator
- [ ] Cross-reference tests/code with DoD
- [ ] Updated DoD documents

---

## Progress Dashboard

### Overall Statistics
- **Total Gaps Identified**: 21
- **High Priority**: 3
- **Medium Priority**: 10
- **Low Priority**: 8

### Status Summary
**Note**: Updated December 13, 2025 after starting Gap 4.2.1 validation work.

- 🔴 Not Started: 18 (86%)
- 🟡 In Progress: 1 (5%)
- 🟢 Complete: 2 (10%)
- ⏸️ Blocked: 0 (0%)

### Sprint Allocation
- **Sprint 1** (Week 1-2): 2 gaps
- **Sprint 2** (Week 3-4): 3 gaps
- **Sprint 3** (Week 5-6): 3 gaps
- **Sprint 4** (Week 7-8): 3 gaps
- **Sprint 5+** (Week 9+): 10 gaps

### Effort Distribution
- **1-2 days**: 5 gaps (24%)
- **2-3 days**: 7 gaps (33%)
- **3-5 days**: 5 gaps (24%)
- **5-7 days**: 1 gap (5%)
- **Ongoing**: 3 gaps (14%)

---

## Update Log

| Date | Gap ID | Status Change | Notes |
|------|--------|---------------|-------|
| 2025-12-13 | 4.2.1 | 🟡 Started | Added TS/Swift validation for Function Block Info (direction/bandwidth/active + reserved bits) |
| 2025-12-13 | 4.2.4 | 🟢 Complete | Added Swift endpoint info validation + tests; TS validation already in place |
| 2025-12-13 | 4.2.4 | 🟡 Started | Added TypeScript endpoint info reserved-bit validation and Vitest coverage |
| 2025-12-13 | All | 🔴 Initial | Comprehensive audit completed |

---

**Maintained By**: MIDI 2.0 Development Team  
**Review Frequency**: Weekly during active sprints
