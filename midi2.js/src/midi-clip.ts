import { encodeUmp } from "./ump";
import type { Midi2Event, StreamEvent, UtilityEvent } from "./types";

export const MIDI_CLIP_HEADER = new Uint8Array([0x53, 0x4d, 0x46, 0x32, 0x43, 0x4c, 0x49, 0x50]);
export const MIDI_CLIP_MAX_DELTA_TICKS = 0xfffff;

export interface MidiClipTimedEvent {
  ticks: number;
  words: ArrayLike<number>;
}

function assertInteger(name: string, value: number, min: number, max: number): void {
  if (!Number.isInteger(value) || value < min || value > max) {
    throw new RangeError(`${name} must be an integer in [${min}, ${max}], got ${value}`);
  }
}

function encodeUtility(status: UtilityEvent["status"], value = 0): number {
  const words = encodeUmp({ kind: "utility", status, value } as UtilityEvent);
  return words[0] >>> 0;
}

function encodeStream(opcode: StreamEvent["opcode"], group: number): number {
  const words = encodeUmp({ kind: "stream", opcode, group } as StreamEvent);
  return words[0] >>> 0;
}

function appendWord(bytes: number[], word: number): void {
  bytes.push((word >>> 24) & 0xff, (word >>> 16) & 0xff, (word >>> 8) & 0xff, word & 0xff);
}

function appendEventWords(bytes: number[], words: ArrayLike<number>): void {
  for (let index = 0; index < words.length; index += 1) {
    const word = words[index];
    if (!Number.isInteger(word) || word < 0 || word > 0xffffffff) {
      throw new RangeError(`event word must be an unsigned 32-bit integer, got ${word}`);
    }
    appendWord(bytes, word >>> 0);
  }
}

/** Build a MIDI 2.0 SMF2CLIP byte stream from timestamped UMP words. */
export function buildMidiClipFile(dctpq: number, events: readonly MidiClipTimedEvent[], group = 0): Uint8Array {
  assertInteger("dctpq", dctpq, 1, 0xffff);
  assertInteger("group", group, 0, 0xf);
  const bytes = Array.from(MIDI_CLIP_HEADER);
  const appendDcs = (value: number) => appendWord(bytes, encodeUtility("deltaClockstamp", value));

  appendDcs(0);
  appendWord(bytes, encodeUtility("dctpq", dctpq));
  appendDcs(0);
  appendWord(bytes, encodeStream("startOfClip", group));

  const ordered = events.map((event, index) => ({ event, index })).sort((left, right) => {
    if (left.event.ticks === right.event.ticks) return left.index - right.index;
    return left.event.ticks - right.event.ticks;
  });
  let lastTick = 0;
  for (const { event } of ordered) {
    assertInteger("event ticks", event.ticks, 0, 0xffffffff);
    let delta = event.ticks >= lastTick ? event.ticks - lastTick : 0;
    while (delta > MIDI_CLIP_MAX_DELTA_TICKS) {
      appendDcs(MIDI_CLIP_MAX_DELTA_TICKS);
      appendWord(bytes, encodeUtility("noop"));
      delta -= MIDI_CLIP_MAX_DELTA_TICKS;
      lastTick += MIDI_CLIP_MAX_DELTA_TICKS;
    }
    appendDcs(delta);
    appendEventWords(bytes, event.words);
    lastTick = event.ticks;
  }

  appendDcs(0);
  appendWord(bytes, encodeStream("endOfClip", group));
  return Uint8Array.from(bytes);
}

export function midiClipTicksForSeconds(seconds: number, dctpq: number, tempoMicrosecondsPerQuarterNote: number): number {
  if (!Number.isFinite(seconds) || seconds < 0 || dctpq <= 0 || tempoMicrosecondsPerQuarterNote <= 0) return 0;
  const ticks = seconds * dctpq * 1_000_000 / tempoMicrosecondsPerQuarterNote;
  return Math.min(Math.round(ticks), 0xffffffff);
}

export function buildMidiClipFileFromSeconds(
  dctpq: number,
  tempoMicrosecondsPerQuarterNote: number,
  events: readonly { timeSeconds: number; words: ArrayLike<number> }[],
  group = 0,
): Uint8Array {
  return buildMidiClipFile(
    dctpq,
    events.map((event) => ({ ticks: midiClipTicksForSeconds(event.timeSeconds, dctpq, tempoMicrosecondsPerQuarterNote), words: event.words })),
    group,
  );
}
