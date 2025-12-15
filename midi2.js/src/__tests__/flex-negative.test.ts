import { describe, expect, it } from "vitest";
import { encodeEventPackets } from "../ump";
import { FlexMetronomeEvent, FlexTempoEvent, FlexTextEvent, FlexTimeSignatureEvent } from "../types";

describe("flex negative coverage", () => {
  it("rejects tempo below 1 bpm", () => {
    const evt: FlexTempoEvent = { kind: "flexTempo", group: 0, bpm: 0 };
    expect(() => encodeEventPackets(evt)).toThrow(RangeError);
  });

  it("rejects tempo beyond 16.16 fixed-point range", () => {
    const evt: FlexTempoEvent = { kind: "flexTempo", group: 0, bpm: 70000 };
    expect(() => encodeEventPackets(evt)).toThrow(RangeError);
  });

  it("rejects time signature with invalid denominator", () => {
    const evt: FlexTimeSignatureEvent = { kind: "flexTimeSignature", group: 0, numerator: 4, denominatorPow2: 0x20 };
    expect(() => encodeEventPackets(evt)).toThrow(RangeError);
  });

  it("rejects flex text payloads longer than 12 bytes", () => {
    const evt: FlexTextEvent = { kind: "flexText", group: 0, text: "abcdefghijklmn" };
    expect(() => encodeEventPackets(evt)).toThrow(RangeError);
  });

  it("rejects metronome accent patterns longer than 10 bytes", () => {
    const evt: FlexMetronomeEvent = { kind: "flexMetronome", group: 0, clicksPerBeat: 4, accentPattern: "12345678901" };
    expect(() => encodeEventPackets(evt)).toThrow(RangeError);
  });
});
