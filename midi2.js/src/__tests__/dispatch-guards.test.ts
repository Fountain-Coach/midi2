import { describe, expect, it } from "vitest";
import { applyGtbGuards } from "../dispatch-guards";
import { StreamEvent } from "../types";

describe("dispatch guards", () => {
  it("validates layout and allowed MTs", () => {
    const evts: StreamEvent[] = [
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 0, firstGroup: 0, groupCount: 2 } },
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 1, firstGroup: 2, groupCount: 2 } },
    ];
    expect(() => applyGtbGuards(evts, { allowedMessageTypes: new Set([0xf]) })).not.toThrow();
    expect(() => applyGtbGuards(evts, { allowOverlap: false, allowedMessageTypes: new Set([0x5]) })).toThrow(RangeError);
  });
});
