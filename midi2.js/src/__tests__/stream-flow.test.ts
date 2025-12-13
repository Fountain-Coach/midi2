import { describe, expect, it } from "vitest";
import { decodeUmp } from "../ump";
import { StreamEvent } from "../types";

function fbNameWords(group: number, index: number, name: string): Uint32Array {
  const bytes = Array.from(new TextEncoder().encode(name)).slice(0, 12);
  while (bytes.length < 12) bytes.push(0);
  const w0 = (0xf << 28) | ((group & 0xf) << 24) | (0x12 << 16);
  const w1 = (index << 24) | (bytes[0] << 16) | (bytes[1] << 8) | bytes[2];
  const w2 = (bytes[3] << 24) | (bytes[4] << 16) | (bytes[5] << 8) | bytes[6];
  const w3 = (bytes[7] << 24) | (bytes[8] << 16) | (bytes[9] << 8) | bytes[10];
  const w4 = bytes[11] << 24;
  return new Uint32Array([w0 >>> 0, w1 >>> 0, w2 >>> 0, w3 >>> 0, w4 >>> 0]);
}

describe("stream discovery/response flow", () => {
  it("decodes function block info and name sequence", () => {
    const group = 1;
    const fbInfo = new Uint32Array([0xf0110113, 0x80010200]); // index=1, firstGroup=1, groupCount=3
    const fbName = fbNameWords(group, 1, "FB 1 (Out)");
    const events: StreamEvent[] = [];
    const decodedInfo = decodeUmp(fbInfo) as any;
    events.push(decodedInfo);
    const decodedName = decodeUmp(fbName) as any;
    events.push(decodedName);
    expect(events[0]).toMatchObject({ opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 1, firstGroup: 1, groupCount: 3, active: true } });
    expect(events[1]).toMatchObject({ opcode: "functionBlockNameNotification" });
  });
});
