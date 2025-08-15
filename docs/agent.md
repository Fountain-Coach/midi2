# agent.md — Codex Agent Plan for `midi2` (Apple‑native bridge)

**Goal:** Equip the `midi2` Swift library with a thin, official **Core MIDI** adapter so Teatro and any Apple host (Logic/Motion/hardware) interoperate seamlessly. 

This agent creates a small Swift package inside the `midi2` repo, maps our **bar:beat:tick** timeline to Apple timestamps, and exposes **sender / virtual source / receiver** APIs using Apple’s protocol‑aware calls.  

Status target: **Apple‑native, MIDI‑2.0‑first** with **MIDI‑1.0 UMP fallback**.

---

## 0) Constraints & style

- Language: **Swift 6** only. No external binaries.
- Platforms: **macOS 13+** first; **iOS/iPadOS 16+** optional.
- Safety: no blocking I/O or allocations in real‑time paths; keep RT code minimal.
- Keep adapters thin; the **`midi2` packet model remains the truth** (UMP structs, CI helpers).
- Tests must run **headless** (no GUI, no hardware required).

---

## 1) Deliverables (what Codex must produce)

1. **Swift Package** `TeatroAppleBridge` inside the `midi2` repo:

```

midi2/
├─ Packages/
│  └─ TeatroAppleBridge/
│     ├─ Package.swift
│     ├─ Sources/TeatroAppleBridge/
│     │  ├─ AppleMIDIBridge.swift        # sender + virtual source
│     │  ├─ AppleMIDIReceiver.swift      # input receive block → our UMP parser
│     │  ├─ AppleSequencerBridge.swift   # MusicSequence builder (tempo, TS, markers, notes/CC/lyrics)
│     │  ├─ GridTime.swift               # bar:beat:tick → beats/seconds/hostTime
│     │  └─ MIDIClock.swift              # host clock helpers
│     └─ Tests/TeatroAppleBridgeTests/
│        ├─ SenderTests.swift
│        ├─ ReceiverTests.swift
│        └─ SequencerTests.swift
└─ docs/agent.md  (this file)

```

2. **Minimal API docs** (DocC comments) for each public symbol.
3. **Examples** under `Examples/`:
- `SendCCDemo/` (CLI): send CC ramps & note bursts to a named destination.
- `VirtualSourceDemo/` (CLI): publish a virtual source and echo incoming events.
- `SequenceExportDemo/` (CLI): build `.mid` from sample YAML and write to disk.
4. **CI tasks** (SwiftPM test + lint) wired into existing repo workflow.

---

## 2) High‑level behavior (compliance with Apple guidance)

- Use **protocol‑aware** Core MIDI APIs: create ports/endpoints **with protocol** (2.0 preferred; 1.0 as needed).
- Build and send **`MIDIEventList`** carrying UMP words via **`MIDISendEventList`**.
- For input, use **`MIDIInputPortCreateWithProtocol(..., MIDIReceiveBlock)`**.
- Timestamp outbound events with **future host time** for precise scheduling.
- Provide optional **MIDI‑CI** path (profile negotiation, property exchange).
- For offline/DAW workflows, generate **MusicSequence** (tempo, time signature, markers, notes/CC/lyrics) and export **SMF**.

---

## 3) Public API (surface area)

### 3.1 Sender / Virtual Source

```swift
public struct MIDIDestinationSelector {
 public var matchContains: String      // e.g., "IAC Driver" or device name
 public var group: UInt8 = 0           // UMP group (0..15)
 public var protocol: MIDIProtocolID = ._2_0  // prefer 2.0
}

public final class AppleMIDIBridge {
 public init(clientName: String = "TeatroClient") throws
 public func selectDestination(_ selector: MIDIDestinationSelector) throws
 public func sendUMP(words: [UInt32], hostTime: UInt64) throws        // 1–4 words per event
 public func sendCC(channel: UInt8, cc: UInt8, value: UInt8,
                    group: UInt8 = 0, hostTime: UInt64) throws        // convenience
 public func sendNoteOn(channel: UInt8, note: UInt8, velocity: UInt16,
                        group: UInt8 = 0, hostTime: UInt64) throws
 public func sendNoteOff(channel: UInt8, note: UInt8, velocity: UInt16,
                         group: UInt8 = 0, hostTime: UInt64) throws
 // Virtual source for other apps to subscribe
 public func startVirtualSource(name: String, protocol: MIDIProtocolID) throws
 public func publishUMP(words: [UInt32], hostTime: UInt64) throws
}
```


### 3.2 Receiver

```
public final class AppleMIDIReceiver {
    public typealias Handler = (_ group: UInt8, _ words: [UInt32], _ hostTime: UInt64) -> Void
    public init(clientName: String = "TeatroClient") throws
    public func openInput(nameMatch: String, protocol: MIDIProtocolID, handler: @escaping Handler) throws
}
```

### 3.3 Sequencer (MusicSequence)

```
public struct TempoEvent { public let beat: Double; public let bpm: Double }
public struct TimeSignature { public let numerator: UInt8; public let denominatorPow2: UInt8 } // e.g., 4/4 → (4,2)

public final class AppleSequencerBridge {
    public init(ppq: Int = 480, timeSignature: TimeSignature = .init(numerator:4, denominatorPow2:2))
    public func setTempoMap(_ events: [TempoEvent])
    public func addMarker(beat: Double, text: String)
    public func addLyric(beat: Double, text: String)
    public func addNote(track: Int, channel: UInt8, note: UInt8, velocity: UInt8,
                        startBeat: Double, durationBeats: Double)
    public func exportSMF(url: URL) throws
}
```

### 3.4 Grid & Clock helpers

```
public struct GridSpec {
    public let beatsPerBar: Int    // 4 for 4/4
    public let ticksPerBeat: Int   // e.g., 480
    public let firstBarStartSec: Double // e.g., 2.0 for a 1-bar count-in @ 120 bpm
}

public enum GridTime {
    public static func barBeatTickToBeats(bar: Int, beat: Int, tick: Int,
                                          beatsPerBar: Int, ticksPerBeat: Int) -> Double
    public static func beatsToSeconds(_ beats: Double, tempoBPM: Double) -> Double
}

public enum MIDIClock {
    public static func nowHostTime() -> UInt64
    public static func secondsToHostTime(_ seconds: Double) -> UInt64
}
```

⸻

## 4) Implementation plan (step‑by‑step)

    1.    Package skeleton (generate)
    •    Create Packages/TeatroAppleBridge/Package.swift with platforms: [.macOS(.v13)].
    •    Product type: .library(name: "TeatroAppleBridge").
    2.    Sender (AppleMIDIBridge.swift)
    •    MIDIClientCreateWithBlock + MIDIOutputPortCreate.
    •    Destination discovery: iterate MIDIGetNumberOfDestinations(); match by name.
    •    Build MIDIEventList (protocol 2.0 default) and call MIDISendEventList.
    •    Add virtual source path (MIDISourceCreateWithProtocol, MIDIReceivedEventList).
    •    Provide CC/Note convenience functions building UMP (2.0) and MIDI‑1.0‑in‑UMP.
    3.    Receiver (AppleMIDIReceiver.swift)
    •    MIDIInputPortCreateWithProtocol(..., MIDIReceiveBlock); parse UMP words and pass to handler.
    •    Unit test with loopback to our virtual source.
    4.    Sequencer (AppleSequencerBridge.swift)
    •    Build MusicSequence; add tempo (ExtendedTempo), time signature (meta 0x58), key sig (optional).
    •    Track per part (or single track); add notes/lyrics/markers; export SMF with PPQ.
    5.    Grid/Clock (GridTime.swift, MIDIClock.swift)
    •    Deterministic bar:beat:tick → beats → seconds → host time.
    •    Use mach_absolute_time mapping via AudioGetCurrentHostTime() / AudioConvertHostTimeToNanos.
    6.    Examples & Tests
    •    SenderTests: start virtual source, send 100 CC events timestamped 100ms in the future; assert reception order/time monotonicity.
    •    ReceiverTests: open input, echo back to ensure parsing of multi‑word UMP.
    •    SequencerTests: create sequence with tempo+TS; export .mid; parse back with MusicSequenceFileLoad and verify event counts.

⸻

## 5) Mapping from Teatro cue YAML

    •    Tempo map: from meta.default_tempo_bpm and any changes → Sequencer tempo events.
    •    Time signature: from meta.timesig (e.g., 4/4) → meta 0x58.
    •    Count‑in: if grid.first_bar_at > 0, treat as pre‑roll; events still use bar‑based math.
    •    Timeline MIDI: map note, chord, lyric to MusicSequence events (offline) or live UMP (sender).
    •    Visual IDs: add meta markers with cue IDs for DAW rulers.

⸻

## 6) Example: send a ramp and a chord (live)

```
import TeatroAppleBridge

let bridge = try AppleMIDIBridge()
try bridge.selectDestination(.init(matchContains: "IAC", group: 0, protocol: ._1_0)) // legacy path
let start = MIDIClock.nowHostTime()

// CC ramp 0→127 over 0.8s @ 30 Hz
for i in 0..<24 {
    let t = Double(i) * (0.8 / 24.0)
    try bridge.sendCC(channel: 0, cc: 21, value: UInt8(Double(i) * (127.0/23.0)),
                      group: 0, hostTime: MIDIClock.secondsToHostTime(t) + start)
}

// C# minor chord at +1.0s
let at = MIDIClock.secondsToHostTime(1.0) + start
try bridge.sendNoteOn(channel: 0, note: 61, velocity: 100, group: 0, hostTime: at)
try bridge.sendNoteOn(channel: 0, note: 64, velocity: 100, group: 0, hostTime: at)
try bridge.sendNoteOn(channel: 0, note: 68, velocity: 100, group: 0, hostTime: at)
```

⸻

## 7) Acceptance criteria

    •    ✅ Can create ports/endpoints with protocol 2.0 or 1.0 and send UMP via MIDISendEventList.
    •    ✅ Can start a virtual source and publish UMP with MIDIReceivedEventList.
    •    ✅ Can receive via MIDIReceiveBlock, parse multi‑word UMP, and hand it to our library.
    •    ✅ Sequencer exports a valid SMF with tempo, time signature, notes/lyrics/markers; Logic shows markers at correct bars.
    •    ✅ Grid conversion (bar:beat:tick) is exact and stable across tempo changes.
    •    ✅ Unit tests are green on CI; examples compile and run on macOS.

⸻

## 8) Non‑goals / guardrails

    •    No GUI, no DAW automation, no FxPlug. This is Core MIDI / AudioToolbox plumbing only.
    •    Don’t block in receive blocks; don’t allocate in inner loops.
    •    No third‑party MIDI wrappers; rely on Apple frameworks + our midi2 structures.

⸻

## 9) How Codex proceeds (task list)

    1.    Scaffold Packages/TeatroAppleBridge with Package.swift.
    2.    Implement AppleMIDIBridge.swift (send, virtual source).
    3.    Implement AppleMIDIReceiver.swift (receive block).
    4.    Implement GridTime.swift + MIDIClock.swift.
    5.    Implement AppleSequencerBridge.swift, export .mid.
    6.    Add unit tests + Examples/ CLIs.
    7.    Add DocC comments and a short README in the package root.
    8.    Update root docs to mention Apple‑native bridge and usage patterns (live vs offline).

⸻

## 10) Future extensions (optional)

    •    MIDI‑CI profile exchange wrappers for device‑adaptive mappings.
    •    iOS/iPadOS target for on‑device performance control.
    •    AVAudioEngine example hosting AUv3 + scheduleParameterBlock ramps (no MIDI path).

⸻

This file lives at midi2/docs/agent.md. 

Codex, create the package, compile on macOS 13+, and run tests headless.


