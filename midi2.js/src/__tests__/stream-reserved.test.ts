import { describe, expect, it } from "vitest";
import { decodeStreamWord } from "../schema-bridge";

describe("stream reserved bits", () => {
  it("rejects stream packet when reserved bit 3 is set", () => {
    const word = 0xf0000008; // reserved bit 3 set
    expect(decodeStreamWord(word)).toBeNull();
  });

  it("rejects stream endpoint discovery with reserved high nibble set", () => {
    const word = 0xf00001f0; // endpoint opcode with reserved high nibble in byte3
    expect(decodeStreamWord(word)).toBeNull();
  });

  it("rejects stream config with reserved flag bits set", () => {
    // flags include reserved bits (0x80)
    const word = 0xf0000180;
    expect(decodeStreamWord(word)).toBeNull();
  });

  it("rejects unknown stream opcode", () => {
    const word = 0xf00f0000;
    expect(decodeStreamWord(word)).toBeNull();
  });
});
