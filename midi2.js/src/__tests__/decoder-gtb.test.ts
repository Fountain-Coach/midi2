import { describe, expect, it } from "vitest";
import { decodeToPacketAndEventWithGuards } from "../decoder";

describe("decoder GTB guards", () => {
  it("allows permitted message types", () => {
    const words = new Uint32Array([0xf0000000]); // stream packet skeleton
    expect(() => decodeToPacketAndEventWithGuards(words, { allowedMessageTypes: new Set([0xf]) })).not.toThrow();
  });

  it("rejects disallowed message types", () => {
    const words = new Uint32Array([0x20000000]); // MIDI 1.0 channel voice mt=0x2
    expect(() => decodeToPacketAndEventWithGuards(words, { allowedMessageTypes: new Set([0xf]) })).toThrow(RangeError);
  });
});
