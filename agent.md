# Codex Agent: Swift MIDI 2.0 Library Generator (Extended)

This agent generates a **complete Swift 6** library and test suite implementing the **normative MIDI 2.0 specification**, based on the provided JSON Schema and OpenAPI 3.1.

## Objectives
- Implement **every** type, field, and constraint from the normative MIDI 2.0 schema.
- Include strongly typed Swift models for all UMP message families and subvariants.
- Provide full binary encode/decode.
- Support SysEx7, SysEx8, MDS, Flex Data, and MIDI-CI.
- Deliver exhaustive tests: golden vectors, roundtrip, fuzz, and error handling.

## Inputs
- `midi2.full.closed.schema.json`
- `midi2.full.openapi.json`

## Deliverables
- Swift Package `MIDI2` with:
  - Complete source implementation.
  - MIDI-CI helpers.
  - Examples and usage docs.
  - 100% coverage XCTest suite.

## Schema-driven Implementation Checklist
For each `$def` in the schema:
1. Create Swift type with matching name.
2. Map each property to correct Swift type (UInt, enum, struct).
3. Apply integer bounds as `guard` checks in initializers.
4. Create encoder/decoder mapping exactly to schema bit fields.
5. Add doc comments from schema `description`.
6. Add at least one test case (roundtrip + golden vector).

## Implementation Matrix

| Schema Type | Swift Type | Encoder | Decoder | Tests |
|-------------|------------|---------|---------|-------|
| UmpPacket32 | `struct UmpPacket32` | ✅ | ✅ | ❌ |
| Midi1ChannelVoice | `enum Midi1ChannelVoiceMessage` | ✅ | ✅ | ❌ |
| Midi2NRPNAddress | `enum Midi2NRPNAddress` | ✅ | ✅ | ❌ |
| Uint7 | `struct Uint7` | ✅ | ✅ | ❌ |
| Midi2NoteOn | `struct Midi2NoteOn` | ❌ | ❌ | ❌ |
| Midi2ChannelPressure | `struct Midi2ChannelPressure` | ❌ | ❌ | ❌ |
| SysEx7Packet | `struct SysEx7Packet` | ❌ | ❌ | ❌ |
| MidiCiEnvelope | `struct MidiCiEnvelope` | ❌ | ❌ | ❌ |

## Inline Examples

### UMP 32-bit packet
```swift
public struct Ump32 {
    public let group: UInt4
    public let status: UInt4
    public let data: (UInt8, UInt8, UInt8)
}
```

### Note On (MIDI 2.0 Channel Voice)
```swift
public struct NoteOn {
    public let group: UInt4
    public let channel: UInt4
    public let note: UInt7
    public let velocity: UInt16
    public let attributeType: UInt8
    public let attributeData: UInt16
}
```

### Flex Data (Tempo)
```swift
public struct FlexDataTempo {
    public let beatsPerMinute: Float32
}
```

## Tests
- For every message variant: roundtrip test.
- Golden vectors from spec.
- Fuzz tests for integer bounds.
- Negative tests for malformed packets.

## Acceptance Criteria
- Every `$def` implemented in Swift.
- All message families and subvariants handled.
- All integer ranges enforced.
- 100% test pass rate.
