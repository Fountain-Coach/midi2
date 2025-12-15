import { describe, expect, it } from "vitest";
import { decodeUmp } from "../ump";

function expectThrow(words: number[]) {
  expect(() => decodeUmp(new Uint32Array(words.map(w => w >>> 0)))).toThrow();
}

describe("fuzzed invalid channel voice/status values", () => {
  it("rejects random undefined channel-voice statuses", () => {
    for (let i = 0; i < 100; i++) {
      const group = Math.floor(Math.random() * 16) & 0xf;
      const statusNibble = 0x7; // undefined for MIDI 2 channel voice
      const word0 = (0x4 << 28) | (group << 24) | (statusNibble << 20);
      expectThrow([word0, 0]);
    }
  });

  // Additional fuzz cases can be added as decoding guards expand.
});
