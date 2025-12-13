import { describe, expect, it } from "vitest";
import { decodeMidiCiFromSysEx } from "../midici";
import { SysEx7Event } from "../types";

describe("MIDI-CI profile negative coverage", () => {
  it("rejects profile details inquiry with empty profileId", () => {
    const bytes = new Uint8Array([0x7d, 0x00, 0x00]); // empty profileId length
    const sysex: SysEx7Event = { kind: "sysex7", group: 0, manufacturerId: [0x7e], payload: bytes };
    const decoded = decodeMidiCiFromSysEx(sysex);
    expect(decoded).toBeNull();
  });
});
