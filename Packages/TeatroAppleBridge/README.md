# TeatroAppleBridge

Adapter package that bridges the `midi2` Universal MIDI Packet model to
Apple's Core MIDI and MusicSequence APIs.

The implementation provided here is a lightweight, cross‑platform stub
that mirrors Core MIDI behavior so the package can be built and tested on
Linux. On Apple platforms the same API can be backed by the native Core
MIDI calls.

## Modules

- ``AppleMIDIBridge`` – discover destinations, send UMP words, or publish a
  virtual source.
- ``AppleMIDIReceiver`` – open an input and receive UMP words via a handler
  callback.
- ``AppleSequencerBridge`` – build a tempo map, add markers/lyrics/notes and
  export a Standard MIDI File.
- ``GridTime`` and ``MIDIClock`` – helper utilities for grid conversions and
  host‑time calculations.

## Example

```swift
import TeatroAppleBridge

let bridge = try AppleMIDIBridge()
try bridge.startVirtualSource(name: "DemoDest", protocol: ._1_0)
try bridge.selectDestination(.init(matchContains: "DemoDest"))

let start = MIDIClock.nowHostTime()
try bridge.sendCC(channel: 0, cc: 21, value: 64,
                  group: 0, hostTime: start)
```

The example sends a single Control Change message through a virtual
connection using the stubbed router. Replace the virtual hooks with real
Core MIDI calls when running on macOS.
