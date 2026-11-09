# Network MIDI 2.0 over UDP — candidate transport work

**Source:** MIDI Association / AMEI M2-124-UM v1.0.1 (published 2025-12-03). Exact source hash, prior-version comparison and source-page references are recorded in [the machine-readable transport source manifest](network-midi2-udp-source.json). This is a separately scoped transport addendum; it does not silently change the six-document MIDI2 core semantic corpus.

## What exists

The `MIDI2Transports` package now has a standalone **stateless datagram framing codec**:

- `Sources/MIDI2Transports/NetworkMidi2PacketCodec.swift` — M2-124 big-endian signature and command headers, multiple command packets, bounded UMP Data payloads and invitation identity encoding.
- `Tests/MIDI2Tests/NetworkMidi2PacketCodecTests.swift` — exact-byte appendix vectors, reserved-bits rejection, invalid lengths, identity bounds, sequence values and sender/receiver size-policy distinction.
- `Tests/Scenarios/network-midi2-udp-peer.yaml` — versioned *candidate* system-boundary scenario, with a generated JSON projection, a source manifest parity gate, negative cases and independent-peer terminal evidence requirements.

The existing RTPMidiSession remains unchanged. No application IDL topic, package dependency or Fountain authorisation rule is added.

## Important source version differences

The 1.0.1 source review compared separately hash-pinned v1.0 and v1.0.1 PDFs. Among the checked changes, section 6.4 (p. 29) explicitly adds non-empty Endpoint Name and Product Instance Id requirements, while the new section 8 (p. 48) describes a shared host UDP port, per-client session identity and over-capacity handling. The framing description in sections 5.1–5.4 (pp. 21–24) and UMP Data in section 7.1 (p. 42) were also compared, with no changed wire behavior found *in those inspected paragraphs*. This does **not** certify that every change across the documents has been audited.

## What does not exist yet

There is **no** released `NetworkMidi2Session: MIDITransport` UDP session implementation, no admitted end-to-end scenario run, no independent software-peer interoperability proof, and no physical-device evidence. Network discovery by itself is neither MIDI-CI capability negotiation nor Fountain instrument admission. An independently tested source-bound session state machine, source-backed UDP transport, and second implementation as peer are still required.

The source PDF itself is intentionally **not** in this repository because the third-party redistribution rights are not independently established. Tests and machine-readable traceability carry only derived fields and short implementation summaries. Passing a codec test never establishes general conformance to M2-124-UM or certification by the MIDI Association.
