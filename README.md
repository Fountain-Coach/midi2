# MIDI2 Swift Library

Swift 6 library for building and parsing **MIDI 2.0 Universal MIDI
Packets (UMP)**. The package is generated from the normative JSON Schema and
OpenAPI definitions and provides broad MIDI 2.0 coverage, including core UMP structures, SysEx7/SysEx8
streaming utilities, MIDI‑CI envelope helpers, and a teaching‑oriented
`midi2demo` CLI for experimenting with the specification.

## Status

Core UMP encoding/decoding, SysEx7/SysEx8 streaming, MIDI‑CI envelope helpers, and demos/tests are implemented.

Recent progress:
- Stream messages (mt=0xF): typed Endpoint Discovery (major/minor/maxGroups) and Stream Configuration request/notification with reserved‑bit validation.
- Function Blocks: typed info (index/firstGroup/groupCount) and discovery `filterBitmap` aggregate with two‑packet encoding; CLI support.

Still in progress:
- Property Exchange: full transaction/state handling and chunking.
- Profiles: configuration reports and end‑to‑end enable/disable flows.
- Stream Configuration §5: Group Terminal Blocks (GTB) and extended device info semantics.

See `docs/conformance-checklist.md` and `docs/quiet-frame-gap-closure.yaml` for the conformance map and gap‑closure plan. The project also ships with the `TeatroAppleBridge` Core MIDI adapter and the `midi2demo` CLI covering `note-on`, `sysex7`, `sysex8`, `flex`, `ci-handshake`, `inspect`, and `stream-config` subcommands.

## Features

- Broad MIDI 2.0 coverage with binary encoder/decoder (see docs/conformance-checklist.md).
- SysEx7 and SysEx8 streaming helpers.
- MIDI‑CI envelope support.
- Teaching‑oriented `midi2demo` CLI.
- [API documentation](midi2.full.openapi.json).
- Examples and XCTest test suite.

## Roadmap

- Close gaps identified in docs/quiet-frame-gap-closure.yaml (Property Exchange state + chunking; Stream Configuration §5; Function Blocks; Profile reports).
- Track spec updates and maintain conformance.
- Expand the `midi2demo` CLI with additional streaming, Flex Data, and packet inspection commands.
- Harden the codebase with additional documentation and integration tests.

## Installation

Add `MIDI2` to your project using the [Swift Package Manager](https://www.swift.org/package-manager/):

```swift
dependencies: [
    .package(url: "https://example.com/midi2.git", from: "0.3.0")
]
```

Then import the library:

```swift
import MIDI2
```

### Upgrading

To upgrade from an earlier release, update the version in your package manifest and run:

```bash
swift package update MIDI2
```

## midi2demo CLI

Build and run the teaching-oriented CLI to experiment with MIDI 2.0 messages.
Examples:

```bash
swift run midi2demo note-on --group 0 --channel 0 60 100
swift run midi2demo sysex7 --group 0 --manufacturer 7D "01 02 03"
swift run midi2demo sysex8 --group 0 --manufacturer 00,20,33 "01 02 03 04"
swift run midi2demo flex tempo --group 0 120
swift run midi2demo flex time --group 0 4 4
swift run midi2demo flex key --group 0 C#m
swift run midi2demo flex lyric --group 0 "Hello world"
swift run midi2demo ci-handshake --no-common-protocol --unsupported-profile --missing-property
swift run midi2demo inspect 0x40107D00 0x00640000
swift run midi2demo stream-config endpoint --group 0 --data1 0x12 --data2 0x34
swift run midi2demo stream-config configure --group 0 --data1 0x01 --data2 0x00
swift run midi2demo stream-config fb --group 0 --data1 0x80 --data2 0x01
swift run midi2demo stream-config fb-discover --group 0 --filter 0xA5A5F00D
swift run midi2demo stream-config gtb --group 0 0:0,4 1:4,4

### Property Exchange (chunked Set/Get/Notify)

Simulate a chunked Property Exchange flow using the in‑memory session:

```bash
swift run midi2demo pe-demo --resource /clip/title --size 120 --chunk 50
```

The demo:
- Subscribes to the resource.
- Sends a chunked Set that the session reassembles and stores.
- Prints chunked Notify packets and reassembles them.
- Issues a Get and reassembles the chunked GetReply to verify integrity.
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

### Code Coverage

Generate a coverage report using the Swift toolchain's `llvm-cov` to avoid
profile format mismatches:

```bash
swift test --enable-code-coverage
LLVM_COV="$(dirname $(dirname $(which swift)))/usr/bin/llvm-cov"
$LLVM_COV report .build/x86_64-unknown-linux-gnu/debug/MIDI2PackageTests.xctest \
  --instr-profile .build/x86_64-unknown-linux-gnu/debug/codecov/default.profdata
```

## TeatroAppleBridge (Core MIDI adapter)

`TeatroAppleBridge` is a small package that bridges the library's Universal MIDI
Packet model to Apple's Core MIDI and MusicSequence APIs. It exposes
`AppleMIDIBridge` for sending or publishing UMP, `AppleMIDIReceiver` for
receiving via a handler block, and `AppleSequencerBridge` for offline sequence
export.

### Demos

The `Examples/` folder contains command-line demos:

- `SendCCDemo` – send CC ramps and a note burst to a destination.
- `VirtualSourceDemo` – publish a virtual source and echo incoming events.
- `SequenceExportDemo` – build a sequence and write a `.mid` file.

## Jitter Reduction

MIDI 2.0 introduces Jitter Reduction (JR) Clock and Timestamp messages to
preserve precise scheduling over links that may introduce transmission
variation. The library exposes these as `Utility.jrClock` and
`Utility.jrTimestamp`, which encode 16‑bit values representing a sender’s
timebase and per‑message offsets for jitter‑corrected playback.

Run the demo executable to observe the packets and their reconstructed times:

```bash
swift run jitterdemo
```

For background on the JR mechanism, see the MIDI 2.0 Universal MIDI Packet
specification (Section 4, “Jitter Reduction (JR) Clock and Timestamps”) in
`M2-104-UM_v1-1-2_UMP_and_MIDI_2-0_Protocol_Specification.pdf`.

## Examples

See the `Examples/` directory for Swift Playgrounds demonstrating common tasks:

- [Basic usage](Examples/BasicUsage.playground)
- [Streaming SysEx7 data](Examples/SysEx7.playground)
- [Streaming SysEx8 data](Examples/SysEx8.playground)
- [Mixed Data Set chunk transfer](Examples/MDS.playground)
- [Flex tempo message](Examples/FlexTiming.playground)
- [MIDI-CI handshake](Examples/MIDICIHandshake.playground)

CLI demos built with `TeatroAppleBridge`:

- [SendCCDemo](Examples/SendCCDemo)
- [VirtualSourceDemo](Examples/VirtualSourceDemo)
- [SequenceExportDemo](Examples/SequenceExportDemo)

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
