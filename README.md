# MIDI2 Swift & JS Libraries

This repo hosts two sibling implementations of the MIDI 2.0 stack:

- **Swift reference stack** — Swift 6 library plus the `midi2demo` CLI for UMP, SysEx7/8, MIDI‑CI, and teaching-oriented flows.
- **`midi2.js`** — CoreMIDI‑free TypeScript/JavaScript library for browsers/Node, covering UMP encode/decode, SysEx7/8, MIDI‑CI envelopes, scheduler, and adapters (WebAudio/Three.js/Cannon.js). See `midi2.js/README.md`.

Both are generated from the canonical JSON Schema and OpenAPI sources in this repo.

## Quick install

- Swift (SwiftPM):
  ```swift
  dependencies: [
      .package(url: "https://example.com/midi2.git", from: "0.6.1")
  ]
  ```
- JavaScript/TypeScript:
  ```bash
  npm install @fountain-coach/midi2
  # or pnpm add @fountain-coach/midi2
  ```

Read on for Swift details; see `midi2.js/README.md` for JS usage and API surface.

## Status

Core UMP encoding/decoding, SysEx7/SysEx8 streaming, MIDI‑CI envelope helpers, and demos/tests are implemented.

Recent progress:
- Stream §5 (mt=0xF): typed Endpoint Discovery (major/minor/maxGroups), Stream Configuration (request/notification) with reserved‑bit validation, Function Block info, FB discovery (filterBitmap) two‑packet encoding, and Group Terminal Blocks aggregate; CLI support.
- Property Exchange: chunked GET/SET/NOTIFY with transaction reassembly, error codes/messages, compression helpers, and CLI demo.
- Profiles: enable/disable/inquiry/details (version + channel mask) and Profile Specific Data (PSD) with CLI demos.
- CI Device Discovery with manufacturer ID validation; JR receiver and tests; PB‑VRT baselines; DoD checklist + CI gates.

Still in progress:
- Profiles: richer configuration reports and spontaneous added/removed sequences in demos.
- PB‑VRT frames for JR and extended SysEx8/MDS edge cases (tests exist; frames pending).

See `docs/conformance-checklist.md` and `docs/quiet-frame-gap-closure.yaml` for the conformance map and gap‑closure plan. The project also ships with the `TeatroAppleBridge` Core MIDI adapter and the `midi2demo` CLI covering `note-on`, `sysex7`, `sysex8`, `flex`, `ci-handshake`, `inspect`, `stream-config`, `pe-demo`, `profiles-demo`, and `profiles-psd`.

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
    .package(url: "https://example.com/midi2.git", from: "0.6.1")
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

### Profiles (enable/disable + inquiry)

```bash
swift run midi2demo profiles-demo --profile /org.midi/piano --channel 0
```

Emits enabled/disabled reports and inquiry replies with supported/enabled flags.

### Profiles: Profile Specific Data (PSD)

```bash
swift run midi2demo profiles-psd --profile /org.midi/piano --target channel --channels 0 01 02 03
```

Prints SysEx8 bytes and decodes them back.

## Compliance (MIDI Association Workbench)

Run conformance tests headlessly using the MIDI Association’s Workbench fork.

- Install locally and set up CI:

```bash
bash midi2-compliance/scripts/install.sh
```

- Run locally (headless Electron via Playwright):

```bash
bash midi2-compliance/scripts/run_local.sh
open out/report.json
```

- CI workflow: `.github/workflows/midi2-compliance.yml` runs on push/PR, uploads `out/report.json`, and generates a badge.
- The rig clones your fork by default: `https://github.com/Fountain-Coach/MIDI2.0Workbench`. Override with `WORKBENCH_FORK_URL`.
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
export. On Apple platforms it now includes a CoreMIDI‑backed IO layer with
MIDI 2.0 UMP send/receive and a Bluetooth pairing UI helper.

### Demos

The `Examples/` folder contains command-line demos:

- `SendCCDemo` – send CC ramps and a note burst to a destination.
- `VirtualSourceDemo` – publish a virtual source and echo incoming events.
- `SequenceExportDemo` – build a sequence and write a `.mid` file.

### Connect over Bluetooth / build an AUv3 bridge

- CoreMIDI IO helper: `AppleMIDIIO` enumerates system endpoints (BLE/Wi‑Fi/USB),
  detects MIDI 2.0 protocol support, and can send/receive UMP when supported.
  On iOS, present the Bluetooth pairing UI using
  `AppleMIDIIO.makeBluetoothPairingViewController()`.
- AUv3 bridge core: the `Packages/MIDI2BridgeAUCore` package ships a
  `MIDI2BridgeAudioUnit` (AUv3 MIDI processor) that forwards host MIDI to a
  selected CoreMIDI destination and can emit events back to the host from a
  CoreMIDI source. Pair BLE in the plugin UI via
  `MIDI2BridgeViewController(audioUnit:)`.

- Sample app + AUv3 extension (iOS): `Examples/AUBridgeSample` contains an
  XcodeGen spec and sources for a minimal host app and AUv3 extension you can
  run on device and insert in AUM. See its README for generation steps.

Down‑conversion (MIDI 2.0 → MIDI 1.0):
- Channel Voice: Note On/Off (16‑bit velocity → 7‑bit), Poly Pressure (32‑bit → 7‑bit),
  CC (32‑bit → 7‑bit), Program Change (+ optional Bank MSB/LSB via CC 0/32),
  Channel Pressure (32‑bit → 7‑bit), Pitch Bend (32‑bit → 14‑bit).
- System Common/Real‑time (UMP mt=0x1) mapped to standard status/data bytes.
- SysEx7 streaming (UMP mt=0x3) reassembled to F0 … F7.
- SysEx8 (UMP mt=0x5) converted to SysEx7 only if the payload is 7‑bit clean;
  otherwise dropped (no safe 1.0 representation).
- MIDI 2.0‑only messages (per‑note controllers/management) are ignored.

To use as an AUv3 in AUM:
- Create an iOS App + AUv3 MIDI Processor (“aumi”) extension in Xcode.
- Add `Packages/MIDI2BridgeAUCore` via SPM and use its factory as the
  `AudioComponentFactoryFunction` (see package README for a minimal example).
- In AUM, insert the plugin, open the plugin UI, pair/connect to the iPad’s
  target over Bluetooth (if needed), and select the destination by name. Host
  MIDI will forward as UMP when the destination supports MIDI 2.0.

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
