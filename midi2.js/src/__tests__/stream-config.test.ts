import { describe, expect, it } from "vitest";
import { decodeUmp, encodeUmp } from "../ump";
import { StreamEvent } from "../types";

describe("Stream config semantics", () => {
  it("roundtrips stream config request (protocol midi2, JR tx/rx)", () => {
    const req: StreamEvent = {
      kind: "stream",
      group: 1,
      opcode: "streamConfigRequest",
      streamConfigRequest: {
        protocol: "midi2",
        jrTimestampsTx: true,
        jrTimestampsRx: true,
      },
    };
    const words = encodeUmp(req);
    const decoded = decodeUmp(words) as StreamEvent;
    expect(decoded).toMatchObject(req);
  });

  it("roundtrips stream config notification (protocol midi1, JR disabled)", () => {
    const note: StreamEvent = {
      kind: "stream",
      group: 0,
      opcode: "streamConfigNotification",
      streamConfigNotification: {
        protocol: "midi1",
        jrTimestampsTx: false,
        jrTimestampsRx: false,
      },
    };
    const words = encodeUmp(note);
    const decoded = decodeUmp(words) as StreamEvent;
    expect(decoded).toMatchObject(note);
  });

  it("rejects stream config with reserved bits set", () => {
    const word0 = (0xf << 28) | (0x0 << 24) | (0x05 << 16) | (0xd9 << 8); // reserved mask triggers
    expect(() => decodeUmp(new Uint32Array([word0]))).toThrow(RangeError);
  });
});
