import { describe, expect, it } from "vitest";
import {
  encodeMidiCiPEFlowControl, decodeMidiCiPEFlowControl,
  midiCiPEFlowControlStatus,
} from "../midi-ci-pe-flow-control";

describe("M2-101-UM v1.2.1 MIDI-CI PE ACK/NAK flow control", () => {
  it("encodes an ACK 0x11 to send the next chunks (Table 14)", () => {
    const source = {
      action: "sendNextChunks" as const,
      originalTransactionSubId2: 0x34,
      peStreamId: 5,
      peChunkNumber: 0x0134,
    };
    const wire = encodeMidiCiPEFlowControl(source);
    expect(wire.subId2).toBe(0x7d);
    expect(Array.from(wire.statusFields)).toEqual([
      0x34, 0x11, 0, 5, 0x34, 0x02, 0, 0,
    ]);
    expect(decodeMidiCiPEFlowControl(wire.subId2, wire.statusFields)).toEqual(source);
    expect(midiCiPEFlowControlStatus("sendNextChunks").statusData).toBe(0);
  });

  it("encodes NAK 0x12 to resend the most recent chunk (Table 16)", () => {
    const source = {
      action: "resendMostRecentChunk" as const,
      originalTransactionSubId2: 0x35,
      peStreamId: 127,
      peChunkNumber: 0x3fff,
    };
    const wire = encodeMidiCiPEFlowControl(source);
    expect(wire.subId2).toBe(0x7f);
    expect(Array.from(wire.statusFields)).toEqual([
      0x35, 0x12, 0, 0x7f, 0x7f, 0x7f, 0, 0,
    ]);
    expect(decodeMidiCiPEFlowControl(wire.subId2, wire.statusFields)).toEqual(source);
  });

  it("does not reinterpret legacy Notify as ACK/NAK", () => {
    const wire = encodeMidiCiPEFlowControl({
      action: "sendNextChunks",
      originalTransactionSubId2: 0x34,
      peStreamId: 1,
      peChunkNumber: 1,
    });
    expect(() => decodeMidiCiPEFlowControl(0x3f, wire.statusFields)).toThrow();
    expect(() => decodeMidiCiPEFlowControl(0x7f, wire.statusFields)).toThrow();
    expect(() => decodeMidiCiPEFlowControl(0x7d, Uint8Array.from([
      0x34, 0x11, 1, 1, 1, 0, 0, 0,
    ]))).toThrow();
  });

  it("rejects invalid PE classifications, 7-bit IDs and chunk sizes", () => {
    const a = { action: "sendNextChunks" as const, originalTransactionSubId2: 0x34, peStreamId: 1, peChunkNumber: 1 };
    expect(() => encodeMidiCiPEFlowControl({ ...a, originalTransactionSubId2: 0x20 })).toThrow();
    expect(() => encodeMidiCiPEFlowControl({ ...a, peStreamId: 128 })).toThrow();
    expect(() => encodeMidiCiPEFlowControl({ ...a, peChunkNumber: 0x4000 })).toThrow();
  });
});
