import { describe, expect, it, beforeEach } from "vitest";
import { decodeToPacketAndEvent, decodeWithGtbContext } from "../decoder";
import { clearGtbContext, setGtbAllowedMessageTypes } from "../gtb-context";

describe("decoder with GTB context", () => {
  beforeEach(() => clearGtbContext());

  it("allows MTs for configured group", () => {
    setGtbAllowedMessageTypes(1, new Set([0xf]));
    const words = new Uint32Array([0xf1000000]); // group=1, mt=0xF
    expect(decodeWithGtbContext(words)).not.toBeNull();
  });

  it("rejects disallowed MTs for configured group", () => {
    setGtbAllowedMessageTypes(1, new Set([0xf]));
    const words = new Uint32Array([0x21903c64]); // group=1, mt=0x2, valid midi1 note on
    expect(() => decodeWithGtbContext(words)).toThrow(RangeError);
  });

  it("enforces GTB context via default decoder", () => {
    setGtbAllowedMessageTypes(1, new Set([0xf]));
    const words = new Uint32Array([0x21903c64]); // group=1, mt=0x2, valid midi1 note on
    expect(() => decodeToPacketAndEvent(words)).toThrow(RangeError);
  });

  it("falls back when no GTB context is set", () => {
    const words = new Uint32Array([0x21903c64]); // mt=0x2, no context -> no guard
    expect(() => decodeWithGtbContext(words)).not.toThrow();
  });
});
