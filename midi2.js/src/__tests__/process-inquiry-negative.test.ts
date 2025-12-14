import { describe, expect, it } from "vitest";
import { decodeMidiCiFromSysEx } from "../midici";
import { SysEx7Event } from "../types";

describe("Process Inquiry negatives", () => {
  it("rejects filter values outside 0/1", () => {
    const json = new TextEncoder().encode('{"noteOn":2}');
    const payload = new Uint8Array([0x7e, 0x0d, 0x06, 0x01, ...json]);
    const evt: SysEx7Event = { kind: "sysex7", group: 0, manufacturerId: [0x7e], payload };
    expect(decodeMidiCiFromSysEx(evt)).toBeNull();
  });

  it("rejects messageDataControl outside allowed set", () => {
    const json = new TextEncoder().encode('{"messageDataControl":5}');
    const payload = new Uint8Array([0x7e, 0x0d, 0x06, 0x01, ...json]);
    const evt: SysEx7Event = { kind: "sysex7", group: 0, manufacturerId: [0x7e], payload };
    expect(decodeMidiCiFromSysEx(evt)).toBeNull();
  });
});
