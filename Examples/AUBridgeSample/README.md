# AUBridgeSample (iOS)

Minimal iOS host app + AUv3 MIDI Processor extension for AUM.

- AU extension embeds the `MIDI2BridgeAUCore` classes to bridge host MIDI to CoreMIDI
  BLE/Wi‑Fi/USB destinations with full MIDI 2.0 ↔ 1.0 conversion.
- UI lets you refresh endpoints, select a destination, and open Bluetooth MIDI pairing.

## Generate Xcode project

This sample uses XcodeGen to keep the project small and reproducible.

- Install XcodeGen (once):

```bash
brew install xcodegen
```

- Generate and open the project:

```bash
cd Examples/AUBridgeSample
xcodegen generate
open AUBridgeSample.xcodeproj
```

## Build & run

- Select the AUBridgeHost scheme, a physical iOS device (recommended), and run.
- Install AUM on the same device, open it, insert the “FountainCoach: MIDI2 Bridge”
  MIDI Processor. Use the plugin UI to pair via Bluetooth and pick a destination.

Notes
- The extension’s component type is `aumi` (MIDI Processor). Manufacturer code is `FCo1`.
- The extension returns a `MIDI2BridgeAudioUnit`, which forwards host MIDI to the selected
  CoreMIDI destination, using UMP when possible and down‑converting when necessary.
