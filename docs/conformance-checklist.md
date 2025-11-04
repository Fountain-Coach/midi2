# MIDI 2.0 Conformance Checklist (Status Quo)

This document summarizes current implementation state against the MIDI 2.0 specifications. Each item links to concrete code and tests as evidence, and highlights gaps to close.

## Property Exchange (MIDI-CI; M2-103-UM)
- Negotiation flow: Implemented
  - Evidence: Sources/MIDI2/MidiCiPropertyExchangeBody.swift:1, Sources/MIDI2CI/CIHandshake.swift:1, Tests/MIDI2Tests/MidiCiHandshakeIntegrationTests.swift:23
- Large data transfer (chunking): Implemented
  - Evidence: Sources/MIDI2CI/PropertyExchange.swift:60 (chunked GET/SET/NOTIFY), Tests/MIDI2Tests/PropertyExchangeChunkingTests.swift:1
- Encodings: Implemented
  - Evidence: zlib (conditional) and mcoded7 helpers in Sources/MIDI2CI/CompressionCodec.swift:1; tests in Tests/MIDI2Tests/PropertyExchangeCompressionTests.swift:1

- Profile Inquiry and Enable/Disable: Implemented
  - Evidence: Sources/MIDI2/MidiCiProfilesBody.swift:1, Sources/MIDI2CI/ProfileSession.swift:1, Sources/MIDI2CI/CIHandshake.swift:1; tests in Tests/MIDI2Tests/ProfileSessionTests.swift:1
- Profile Configuration Details: Partial
  - Evidence: Details replies include version and channel mask; PSD supported; added/removed helpers; demos print details.
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
- Group Terminal Blocks (GTB): Implemented
  - Evidence: Sources/MIDI2/Stream/GroupTerminalBlocks.swift:1; tests in Tests/MIDI2Tests/GroupTerminalBlocksTests.swift:1

## Jitter Reduction (JR)
- JR Clock (sender): Implemented
  - Evidence: Sources/MIDI2/System/Utility.swift:1, Tests/MIDI2Tests/System/JitterReductionTests.swift:1, Sources/jitterdemo/JitterApp.swift:1
- JR Timestamp (receiver offset): Implemented
  - Evidence: Sources/MIDI2/System/JitterReductionReceiver.swift:1, Tests/MIDI2Tests/System/JitterReductionTests.swift:1; PB-VRT jr/clock_timestamp.json

## SysEx8 Packetization
- Basic fragmentation: Implemented
  - Evidence: Sources/MIDI2/Data/SysEx8.swift:1, Tests/MIDI2Tests/SysEx8Tests.swift:1
- Continuation/termination flags: Implemented
  - Evidence: Strict validation + edge/invalid sequence tests (Tests/MIDI2Tests/SysEx8InvalidSequenceTests.swift:1); PB-VRT sysex8/invalid_cases.json

## UMP Format Extensions and Reserved IDs
- Utility messages beyond JR: Partial
  - Evidence: System Common/Real-Time decoders + negative tests.
- Future reserved message IDs: Partial
  - Evidence: Negative tests for unsupported statuses; gap: broaden across all decoders.

## Testing and Validation
- Conformance test coverage: Improved
  - Evidence: New negative tests for Stream §5, SysEx8, MDS, profiles reports, PE compression; CI with coverage gate.
- Schema regression (PB-VRT): Partial
  - Evidence: Scripts/SchemaGen.swift:1, Scripts/inject_schema_docs.py:1
  - Gap: Visual baseline frames for CI messages, automated diffs.
- Interop with hardware: Missing
  - Evidence: No tests against external devices.
  - Gap: Capture/verify against official MIDI-CI device responses and JR sync.
