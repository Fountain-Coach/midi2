import { describe, expect, it } from "vitest";
import { decodeStreamWord } from "../schema-bridge";

describe("stream reserved bits", () => {
  it("rejects stream packet when reserved bit 3 is set", () => {
    const word = 0xf0000800; // reserved bit 3 set
    expect(decodeStreamWord(word)).toBeNull();
  });
});
