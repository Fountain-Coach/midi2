# midi2.js (prototype)

Early TypeScript core for the cross-browser, CoreMIDI-free MIDI 2.0 stack described in `docs/midi2-stack-essay.md`.

## What is here
- Channel Voice events: note on/off, poly pressure, control change, program change, channel pressure, pitch bend; plus `rawUMP`.
- SysEx helpers: fragment/reassemble SysEx7 and SysEx8 UMP streams.
- Minimal `MidiClock` implementations: browser, AudioContext-aligned, and worker-backed.
- `Midi2Scheduler` for time-ordered delivery with a jitter coalescing window.
- UMP helpers to encode/decode MIDI 2.0 Channel Voice messages, including RPN/NRPN (absolute/relative) and per-note management/controllers (reg/assignable), plus Utility (MT=0x0), System Common/Real-Time (MT=0x1), MIDI 1.0 channel voice (MT=0x2), and initial Flex Data (tempo/time signature/key signature/lyric).
- Host adapters: simple WebAudio poly-synth, Three.js mesh spawner, and Cannon.js rigid-body mapper.

## Quick start
```ts
import {
  Midi2Scheduler,
  createBrowserClock,
  decodeUmp,
  encodeNoteOn,
  Midi2NoteOnEvent,
} from "@fountain-coach/midi2";

const clock = createBrowserClock();
const scheduler = new Midi2Scheduler(clock);

scheduler.onEvent(evt => {
  console.log("midi2 event", evt);
});

const noteOn: Midi2NoteOnEvent = {
  kind: "noteOn",
  group: 0,
  channel: 0,
  note: 60,
  velocity: 48000,
};

const at = clock.now() + 50;
scheduler.schedule(noteOn, at);

// Round-trip UMP encode/decode.
const ump = encodeNoteOn(noteOn);
const decoded = decodeUmp(ump, at);
console.log(decoded);
```

### SysEx7 / SysEx8 helpers
```ts
import { fragmentSysEx7, reassembleSysEx7 } from "@fountain-coach/midi2";

const packets = fragmentSysEx7([0x7D], [0x01, 0x02, 0x03, 0x04], 0);
const { manufacturerId, payload } = reassembleSysEx7(packets);
```

### Host adapters
```ts
import { createWebAudioAdapter } from "@fountain-coach/midi2";

const audioAdapter = createWebAudioAdapter(audioContext);
scheduler.onEvent(audioAdapter);
```

Three.js and Cannon.js adapters expect a `scene` or `world` object with `add/remove`/`addBody/removeBody` and will use global `THREE`/`CANNON` if available.

## Scripts
- `npm run --prefix midi2.js codegen` – regenerate TypeScript types + guards from `midi2.full.openapi.json` into `src/generated/openapi-types.ts`.
- `npm run --prefix midi2.js build` – compile TypeScript to `dist/`.
- `npm run --prefix midi2.js check` – type-check without emit.
- `npm test --prefix midi2.js` – run vitest suite against UMP encoders/decoders and SysEx helpers.

## Next steps
- Extend UMP coverage (per-note controllers, MIDI-CI envelopes) from the JSON Schema/OpenAPI definitions.
- Harden adapters and add worker/off-main-thread scheduling options for real scenes.
- Import Swift test vectors and conformance cases to mirror the reference library.

## Definition of Done
See `docs/midi2-js-dod.md` for the acceptance criteria for a full spec-aligned release.
