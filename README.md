# MIDI2 Swift Library

Work‑in‑progress Swift 6 library for building and parsing **MIDI 2.0 Universal MIDI
Packets (UMP)**. The package is generated from the normative JSON Schema and
OpenAPI definitions and currently provides core UMP structures, SysEx7/SysEx8
streaming utilities, MIDI‑CI envelope helpers, and an evolving
`midi2demo` CLI for experimenting with the specification.

## Status Quo

Active development: core UMP structures and SysEx helpers exist. The `midi2demo` CLI now implements all planned subcommands—`note-on`, `sysex7`, `sysex8`, `flex` (tempo, time signature, key, lyric), `ci-handshake`, and `inspect`. A `midi2demo.1` man page and enhanced `--help` output accompany the tool. Full spec coverage and comprehensive tests remain in progress.

## Features

- Core UMP message structures with binary encoder/decoder.
- SysEx7 and SysEx8 streaming helpers.
- MIDI‑CI envelope support.
- Teaching‑oriented `midi2demo` CLI.
- Examples and XCTest test suite.

## Roadmap

- Expand implementation to cover the entire MIDI 2.0 specification.
- Expand the `midi2demo` CLI with additional streaming, Flex Data, and packet inspection commands.
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

## midi2demo CLI

Build and run the teaching-oriented CLI to experiment with MIDI 2.0 messages.
Examples:

```bash
swift run midi2demo note-on 60 100
swift run midi2demo sysex7 --manufacturer 7D "01 02 03"
swift run midi2demo sysex8 --manufacturer 00,20,33 "01 02 03 04"
swift run midi2demo flex tempo --group 0 120
swift run midi2demo ci-handshake
swift run midi2demo inspect 0x40107D00 0x00640000
```

Each command prints the encoded Universal MIDI Packet and decodes it back to
human-readable fields.

### Man page

Install the man page:

```bash
sudo install -m 0644 Sources/midi2demo/midi2demo.1 /usr/local/share/man/man1/
man midi2demo
```

### CLI tests

Run the CLI tests with SwiftPM:

```bash
swift test --filter midi2demo
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

