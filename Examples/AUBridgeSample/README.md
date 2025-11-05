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

- Signing (first time only):
  - In Xcode, select the `AUBridgeHost` target → Signing & Capabilities → enable
    "Automatically manage signing" and choose your Apple Developer team.
  - Repeat for the `MIDI2BridgeExtension` target.
  - If bundle IDs conflict, edit them to unique values.
- Select the `AUBridgeHost` scheme.
- Choose a physical iPhone/iPad as the run destination (not "My Mac").
- Build and run to install the host app + AUv3 extension.
- Install AUM on the same device, open it, insert the “FountainCoach: MIDI2 Bridge”
  MIDI Processor. Use the plugin UI to pair via Bluetooth and pick a destination.

Notes
- The extension’s component type is `aumi` (MIDI Processor). Manufacturer code is `FCo1`.
- The extension returns a `MIDI2BridgeAudioUnit`, which forwards host MIDI to the selected
  CoreMIDI destination, using UMP when possible and down‑converting when necessary.

### Troubleshooting

- Error: “Signing … requires a development team” → set a Team on both targets as
  above, or regenerate with your team pre-set:

  ```bash
  DEVELOPMENT_TEAM=YOURTEAMID xcodegen generate
  ```

- Xcode wants to run on “My Mac (Mac Catalyst)” → project is iOS-only; pick an iOS
  device or simulator. AUM is only available on a physical device.
