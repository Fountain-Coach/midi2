# MIDI2BridgeAUCore

Core classes to build an AUv3 MIDI processor that bridges host MIDI to external
CoreMIDI destinations (Bluetooth/Wi‑Fi/USB) using MIDI 2.0 Universal MIDI
Packets where available, falling back to 1.0 when necessary.

- `MIDI2BridgeAudioUnit` – AUAudioUnit subclass that routes host MIDI events to
  a selected CoreMIDI destination and can emit events back to the host when
  subscribed to a CoreMIDI source.
- `MIDI2BridgeViewController` – lightweight UIKit UI to select a destination and
  open Apple’s Bluetooth MIDI pairing sheet.

## Integrate in an AUv3 project

1. Create an Xcode iOS App project with an AUv3 Audio Unit extension target of
   type MIDI Processor (`aumi`).
2. Add this package to the app via SPM and link `MIDI2BridgeAUCore` to the
   extension target.
3. In the extension’s principal class, instantiate `MIDI2BridgeAudioUnit` and
   return it from the factory.
4. If you have a UI, present `MIDI2BridgeViewController(audioUnit:)`.

Minimal factory example:

```swift
import AudioToolbox
import MIDI2BridgeAUCore

public func AUFactory(_ componentDescription: AudioComponentDescription) -> AUAudioUnit? {
    return try? MIDI2BridgeAudioUnit(componentDescription: componentDescription)
}
```

Ensure the extension’s `Info.plist` contains:

- `NSExtensionPointIdentifier = com.apple.AudioUnit`
- `AudioComponentFactoryFunction` symbol pointing at your factory
- `AudioUnitType = aumi`

Run the host (e.g. AUM), insert the plugin, pick a destination, and send MIDI
from the host to forward over BLE/Wi‑Fi/USB.

---

Note: Bluetooth pairing UI uses `CoreAudioKit.CABTMIDICentralViewController`.
Hosts may manage BLE themselves; the UI is optional and can be omitted.
