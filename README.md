# MIDI2 Swift Library

Swift 6 library for MIDI 2.0 based on the normative JSON Schema and OpenAPI spec.

## Features
- Full MIDI 2.0 UMP message support.
- Binary encoder/decoder.
- MIDI-CI message support.
- SysEx7, SysEx8, MDS, Flex Data support.
- XCTest test suite.

## Usage
```swift
import MIDI2

let noteOn = Midi2ChannelVoice.NoteOn(...)
let encoded = UmpCodec.encode(noteOn)
let decoded = try UmpCodec.decode(encoded)
```
