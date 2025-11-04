# MIDI 2.0 Conformance Checklist (Status Quo)

This document summarizes current implementation state against the MIDI 2.0 specifications. Each item links to concrete code and tests as evidence, and highlights gaps to close.

## Property Exchange (MIDI-CI; M2-103-UM)
- Negotiation flow: Partial
  - Evidence: Sources/MIDI2/MidiCiPropertyExchangeBody.swift:1, Sources/MIDI2CI/CIHandshake.swift:1, Tests/MIDI2Tests/MidiCiHandshakeIntegrationTests.swift:23
  - Gap: No full transaction state handling for Get/Set/Subscribe; only GET/GET_REPLY in demos/tests.
- Large data transfer (chunking): Missing
  - Evidence: No chunking helpers beyond SysEx7/8 bodies; no reassembly for Property Exchange payloads.
  - Gap: Implement chunked transfers per §6 with request/response continuation.
- JSON schema ↔ serialization mapping: Prototype
  - Evidence: Sources/MIDI2CI/PropertyExchange.swift:1
  - Gap: Bind spec JSON schema to Swift types for robust validation.

## Profiles and Function Blocks (M2-102-U)
- Profile Inquiry and Enable/Disable: Minimal
  - Evidence: Sources/MIDI2/MidiCiProfilesBody.swift:1, Sources/MIDI2CI/ProfileInquiry.swift:1, Sources/MIDI2CI/CIHandshake.swift:15
  - Gap: Active handlers for enable/disable, added/removed reports; end-to-end flow coverage.
- Profile Configuration Reports: Missing
  - Evidence: No generation/parsing of configuration reports beyond body encoding.
  - Gap: Implement reports mirroring Profile Data Set.
- Function Block discovery: Partial
  - Evidence: Sources/MIDI2/Stream/FunctionBlockMessage.swift:1 (typed info: index/firstGroup/groupCount), Sources/MIDI2/Stream/FunctionBlockDiscovery.swift:1 (filterBitmap aggregate), Tests/MIDI2Tests/StreamFunctionBlockDiscoveryTests.swift:1 (roundtrip + errors)
  - Gap: Descriptor details beyond index/group range; discovery/response flow semantics; profile reports.

## UMP Stream Configuration (M2-104-UM §5)
- Endpoint Discovery (Endpoint/Device Info): Partial → Typed
  - Evidence: Sources/MIDI2/Stream/EndpointDiscoveryMessage.swift:1 (major/minor/maxGroups mapping, reserved validation), Tests/MIDI2Tests/StreamMappingTests.swift:1
  - Gap: Device Info/advertisement content (beyond version/max groups).
- Stream Configuration Request/Reply: Partial
  - Evidence: Sources/MIDI2/Stream/StreamConfigurationMessage.swift:1 (typed fields + reserved-bit validation), Sources/midi2demo/StreamConfig.swift:100 (typed request/notification), Tests/MIDI2Tests/StreamReservedBitsTests.swift:1, Tests/MIDI2Tests/StreamTypedTests.swift:1
  - Gap: GTB negotiation and additional §5 semantics.
- Group Terminal Blocks (GTB): Missing
  - Evidence: No GTB model/parse helpers.
  - Gap: Add GTB typed structures and parsing.

## Jitter Reduction (JR)
- JR Clock (sender): Implemented
  - Evidence: Sources/MIDI2/System/Utility.swift:1, Tests/MIDI2Tests/System/JitterReductionTests.swift:1, Sources/jitterdemo/JitterApp.swift:1
- JR Timestamp (receiver offset): Partial
  - Evidence: Sources/MIDI2/System/Utility.swift:1, Sources/jitterdemo/JitterApp.swift:1
  - Gap: Receiver synchronization and offset application logic in demos/tests.

## SysEx8 Packetization
- Basic fragmentation: Implemented
  - Evidence: Sources/MIDI2/Data/SysEx8.swift:1, Tests/MIDI2Tests/SysEx8Tests.swift:1
- Continuation/termination flags: Partial
  - Evidence: Sources/MIDI2/Data/SysEx8.swift:1 (validation exists), Tests/MIDI2Tests/SysEx8Tests.swift:1 (limited edge tests)
  - Gap: Add multi-frame edge/invalid sequence tests and strict validation coverage.

## UMP Format Extensions and Reserved IDs
- Utility messages beyond JR: Partial
  - Evidence: Sources/MIDI2/System/Utility.swift:1 (JR only)
  - Gap: Add Stream Configuration/Inquiry utility message variants.
- Future reserved message IDs: Missing
  - Evidence: No placeholder/handling for reserved ranges.
  - Gap: Define placeholders and graceful handling.

## Testing and Validation
- Conformance test coverage: Partial
  - Evidence: Tests cover UMP core, SysEx7/8, Flex, CI envelopes; limited CI negotiation/state.
  - Gap: Add CI negotiation, profile config, stream config end-to-end tests.
- Schema regression (PB-VRT): Partial
  - Evidence: Scripts/SchemaGen.swift:1, Scripts/inject_schema_docs.py:1
  - Gap: Visual baseline frames for CI messages, automated diffs.
- Interop with hardware: Missing
  - Evidence: No tests against external devices.
  - Gap: Capture/verify against official MIDI-CI device responses and JR sync.

