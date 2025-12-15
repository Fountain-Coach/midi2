import { describe, expect, it } from "vitest";
import { decodeUmp } from "../ump";
import { reassembleSysEx7, reassembleSysEx8, umpBytesToWords } from "../sysex";

function decode(words: number[]) {
  return () => decodeUmp(new Uint32Array(words.map(w => w >>> 0)));
}

describe("negative decode coverage (reserved/invalid values)", () => {
  it("rejects MIDI 2 channel voice per-note mgmt with note above 0x7F", () => {
    const word0 = (0x4 << 28) | (0x0 << 24) | (0xf << 20) | (0x0 << 16) | (0xff << 8);
    expect(decode([word0, 0])).toThrow(RangeError);
  });

  it("rejects MIDI 2 channel voice per-note assignable controller with note above 0x7F", () => {
    const word0 = (0x4 << 28) | (0x0 << 24) | (0xf << 20) | (0x0 << 16) | (0xff << 8) | 0x80;
    expect(decode([word0, 0])).toThrow(RangeError);
  });

  it("rejects MIDI 2 channel voice per-note reg controller with note above 0x7F", () => {
    const word0 = (0x4 << 28) | (0x0 << 24) | (0xf << 20) | (0x0 << 16) | (0xff << 8) | 0x01;
    expect(decode([word0, 0])).toThrow(RangeError);
  });

  it("rejects MIDI 2 channel voice per-note pitch bend with note above 0x7F", () => {
    const word0 = (0x4 << 28) | (0x0 << 24) | (0x0 << 20) | (0x0 << 16) | (0xff << 8);
    expect(decode([word0, 0])).toThrow(RangeError);
  });

  it("rejects stream packets with reserved bit set", () => {
    const word0 = (0xf << 28) | 0x8; // reserved low bit set
    expect(decode([word0])).toThrow(RangeError);
  });

  it("rejects endpoint info with reserved numberOfFunctionBlocks", () => {
    const word0 = (0xf << 28) | (0x01 << 16) | (0x21 << 8); // opcode=endpointInfo, nfb=0x21
    expect(decode([word0])).toThrow(RangeError);
  });

  it("rejects stream config with reserved flag bits set", () => {
    const word0 = (0xf << 28) | (0x05 << 16) | (0x08 << 8); // opcode=request, reserved bit3 in data1
    expect(decode([word0])).toThrow(RangeError);
  });

  it("rejects function block info with reserved midi1Bandwidth", () => {
    const word0 = (0xf << 28) | (0x11 << 16) | (0x00 << 8) | 0x01; // opcode=fb info, groupCount=1
    const word1 = (1 << 16) | (3 << 8); // direction=input, midi1Bandwidth=3 (reserved)
    expect(decode([word0, word1])).toThrow(RangeError);
  });

  it("rejects utility packets with non-zero group nibble", () => {
    const word0 = (0x0 << 28) | (0x1 << 24); // mt=0, group=1
    expect(decode([word0])).toThrow(RangeError);
  });

  it("rejects utility packets with unsupported status", () => {
    const word0 = (0x0 << 28) | (0x0 << 24) | (0x7f << 16);
    expect(decode([word0])).toThrow(RangeError);
  });

  it("rejects MIDI 1 channel voice with invalid status byte", () => {
    // status 0x70 is below MIDI1 channel voice range
    const word0 = (0x2 << 28) | (0x0 << 24) | (0x70 << 16);
    expect(decode([word0])).toThrow(RangeError);
  });

  it("rejects MIDI 1 channel voice with data bytes out of range", () => {
    const word0 = (0x2 << 28) | (0x0 << 24) | (0x90 << 16) | (0xff << 8); // data1=0xFF
    expect(decode([word0])).toThrow(RangeError);
  });

  it("rejects MIDI 2 channel voice with note outside 7-bit range", () => {
    const word0 = (0x4 << 28) | (0x0 << 24) | (0x9 << 20) | (0x0 << 16) | (0xff << 8);
    expect(decode([word0, 0])).toThrow(RangeError);
  });

  it("rejects MIDI 2 channel voice with unsupported status nibble", () => {
    const word0 = (0x4 << 28) | (0x0 << 24) | (0x7 << 20);
    expect(decode([word0, 0])).toThrow(RangeError);
  });

  it("rejects MIDI 2 system with unsupported status", () => {
    const word0 = (0x1 << 28) | (0x0 << 24) | (0xf4 << 16);
    expect(decode([word0])).toThrow(RangeError);
  });

  it("rejects SysEx7 packets with invalid status, oversize chunk, or empty payload", () => {
    const invalidStatus = [umpBytesToWords(Uint8Array.from([0x30, 0x40, 0, 0, 0, 0, 0, 0]))];
    expect(() => reassembleSysEx7(invalidStatus)).toThrow(RangeError);

    const oversizeCount = [umpBytesToWords(Uint8Array.from([0x30, 0x17, 0, 0, 0, 0, 0, 0]))]; // count nibble 7 > 6
    expect(() => reassembleSysEx7(oversizeCount)).toThrow(RangeError);

    const emptyPayload = [umpBytesToWords(Uint8Array.from([0x30, 0x00, 0, 0, 0, 0, 0, 0]))];
    expect(() => reassembleSysEx7(emptyPayload)).toThrow(RangeError);
  });

  it("rejects SysEx8 packets with invalid status or empty payload", () => {
    const invalidStatus = [umpBytesToWords(Uint8Array.from([0x50, 0x40, ...Array(14).fill(0)]))];
    expect(() => reassembleSysEx8(invalidStatus)).toThrow(RangeError);

    const emptyPayload = [umpBytesToWords(Uint8Array.from([0x50, 0x00, ...Array(14).fill(0)]))];
    expect(() => reassembleSysEx8(emptyPayload)).toThrow(RangeError);
  });

  it("rejects utility noop with non-zero payload", () => {
    const word0 = (0x0 << 28) | (0x00 << 16) | 0x1234;
    expect(decode([word0])).toThrow(RangeError);
  });
});
