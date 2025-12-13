import { describe, expect, it } from "vitest";
import { encodeEventPackets } from "../ump";
import { FlexTempoEvent, FlexTimeSignatureEvent } from "../types";

describe("flex negative coverage", () => {
  it("rejects tempo below 1 bpm", () => {
    const evt: FlexTempoEvent = { kind: "flexTempo", group: 0, bpm: 0 };
    expect(() => encodeEventPackets(evt)).toThrow(RangeError);
  });

  it("rejects time signature with invalid denominator", () => {
    const evt: FlexTimeSignatureEvent = { kind: "flexTimeSignature", group: 0, numerator: 4, denominatorPow2: 0x20 };
    expect(() => encodeEventPackets(evt)).toThrow(RangeError);
  });
});
