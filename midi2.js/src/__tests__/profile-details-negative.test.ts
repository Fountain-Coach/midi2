import { describe, expect, it } from "vitest";
import { decodeMidiCiFromSysEx } from "../midici";
import { SysEx7Event } from "../types";

describe("profile details malformed payloads", () => {
  it("ignores profile details with truncated body", () => {
    // Command=detailsReply (0x09), only header present (no payload)
    const payload = Uint8Array.from([0x7e, 0x0d, 0x09, 0x01]);
    const evt: SysEx7Event = { kind: "sysex7", group: 0, manufacturerId: [0x7e], payload };
    const decoded = decodeMidiCiFromSysEx(evt);
    expect(decoded).toBeNull();
  });

  it("ignores profile details when channel count exceeds 0x10", () => {
    const payload = Uint8Array.from([0x7e, 0x0d, 0x09, 0x01, 0x10, 0xFF]);
    const evt: SysEx7Event = { kind: "sysex7", group: 0, manufacturerId: [0x7e], payload };
    const decoded = decodeMidiCiFromSysEx(evt);
    expect(decoded).toBeNull();
  });
});
