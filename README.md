# MIDI2 Swift Library

Work‑in‑progress Swift 6 library for building and parsing **MIDI 2.0 Universal MIDI
Packets (UMP)**. The package is generated from the normative JSON Schema and
OpenAPI definitions and currently provides core UMP structures, SysEx7/SysEx8
streaming utilities, and MIDI‑CI envelope helpers. Coverage of the full
specification and a teaching‑oriented CLI are still in progress.

## Features

- Core UMP message structures with binary encoder/decoder.
- SysEx7 and SysEx8 streaming helpers.
- MIDI‑CI envelope support.
- Examples and XCTest test suite.

## Roadmap

- Expand implementation to cover the entire MIDI 2.0 specification.
- Provide a `midi2demo` CLI showcasing encoding, streaming, Flex Data,
  MIDI‑CI handshake, and packet inspection.
- Harden the codebase with additional documentation and integration tests.

## Installation

Add `MIDI2` to your project using the [Swift Package Manager](https://www.swift.org/package-manager/):

```swift
dependencies: [
    .package(url: "https://example.com/midi2.git", from: "0.1.0")
]
```

Then import the library:

```swift
import MIDI2
```

## Examples

See the `Examples/` directory for Swift Playgrounds demonstrating common tasks:

- [Basic usage](Examples/BasicUsage.playground)
- [Streaming SysEx7 data](Examples/SysEx7.playground)
- [Streaming SysEx8 data](Examples/SysEx8.playground)
- [Mixed Data Set chunk transfer](Examples/MDS.playground)
- [Flex tempo message](Examples/FlexTiming.playground)
- [MIDI-CI handshake](Examples/MIDICIHandshake.playground)

### Encoding a Channel Voice Message

```swift
import MIDI2

let group = Uint4(0)!
let channel = Uint4(0)!
let control = Uint7(64)!
let message = ControlChange(group: group, channel: channel, control: control, value: 0x7F)
let ump = message.ump()
```

### Streaming SysEx7 Data

```swift
import MIDI2

let payload: [UInt8] = [0x7D, 0x01, 0x02]
let packets = try SysEx7.fragment(manufacturerID: [0x7D], payload: payload)
```

