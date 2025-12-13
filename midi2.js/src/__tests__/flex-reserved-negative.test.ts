import { describe, expect, it } from "vitest";
import { encodeEventPackets } from "../ump";

describe("flex reserved class/status negatives", () => {
  it("rejects flex packets with reserved status class", () => {
    // mt=0xD, status class = 0x7F (reserved)
    const word0 = (0xd << 28) | (0x0 << 24) | (0x7f << 16);
    expect(() => encodeEventPackets([{ kind: "rawUMP", words: new Uint32Array([word0, 0, 0, 0]) } as any])).toThrow();
  });

  it("rejects flex packets with reserved channel address byte", () => {
    // addrByte channel nibble out of range (0x1F)
    const word0 = (0xd << 28) | (0x0 << 24) | (0x10 << 16) | 0x1f;
    expect(() => encodeEventPackets([{ kind: "rawUMP", words: new Uint32Array([word0, 0, 0, 0]) } as any])).toThrow();
  });
});
