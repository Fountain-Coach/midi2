# MIDI2 Swift Library

Swift 6 library for building and parsing **MIDI 2.0 Universal MIDI Packets (UMP)**.
The package is generated from the normative JSON Schema and OpenAPI definition and
offers strongly typed models for MIDI 2.0 messages, utilities for SysEx7/SysEx8
streaming, and helpers for MIDI-CI workflows.

## Features

- Full MIDI 2.0 UMP message support.
- Binary encoder/decoder.
- MIDI-CI message support.
- SysEx7, SysEx8, MDS, Flex Data support.
- XCTest test suite.

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

