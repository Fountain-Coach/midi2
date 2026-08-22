import { describe, expect, it } from "vitest";
import { buildMidiClipFile, buildMidiClipFileFromSeconds, MIDI_CLIP_HEADER, MIDI_CLIP_MAX_DELTA_TICKS, midiClipTicksForSeconds } from "../midi-clip";

function words(bytes: Uint8Array): number[] {
  const result: number[] = [];
  for (let index = 8; index + 3 < bytes.length; index += 4) {
    result.push(((bytes[index] << 24) | (bytes[index + 1] << 16) | (bytes[index + 2] << 8) | bytes[index + 3]) >>> 0);
  }
  return result;
}

describe("MIDI 2.0 SMF2CLIP writer", () => {
  it("writes the clip header, configuration, boundaries, and stable event order", () => {
    const clip = buildMidiClipFile(480, [
      { ticks: 20, words: [0x22222222] },
      { ticks: 10, words: [0x11111111] },
      { ticks: 10, words: [0x33333333] },
    ], 2);
    expect(Array.from(clip.slice(0, 8))).toEqual(Array.from(MIDI_CLIP_HEADER));
    const packetWords = words(clip);
    expect(packetWords.slice(0, 4)).toEqual([0x00400000, 0x003001e0, 0x00400000, 0xf2200000]);
    expect(packetWords).toContain(0x11111111);
    expect(packetWords).toContain(0x33333333);
    expect(packetWords).toContain(0x22222222);
    expect(packetWords.at(-1)).toBe(0xf2210000);
  });

  it("chunks deltas at the protocol maximum", () => {
    const clip = buildMidiClipFile(96, [{ ticks: MIDI_CLIP_MAX_DELTA_TICKS + 2, words: [0xabcdef01] }]);
    const packetWords = words(clip);
    expect(packetWords).toContain(0x004fffff);
    expect(packetWords).toContain(0x00000000);
    expect(packetWords).toContain(0x00400002);
    expect(packetWords).toContain(0xabcdef01);
  });

  it("converts seconds using DCTPQ and tempo", () => {
    expect(midiClipTicksForSeconds(0.5, 480, 500000)).toBe(480);
    const clip = buildMidiClipFileFromSeconds(480, 500000, [{ timeSeconds: 0.5, words: [0x12345678] }]);
    expect(words(clip)).toContain(0x12345678);
  });

  it("rejects invalid clip configuration and words", () => {
    expect(() => buildMidiClipFile(0, [])).toThrow(RangeError);
    expect(() => buildMidiClipFile(480, [], 16)).toThrow(RangeError);
    expect(() => buildMidiClipFile(480, [{ ticks: 0, words: [-1] }])).toThrow(RangeError);
  });
});
