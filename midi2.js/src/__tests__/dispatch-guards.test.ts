import { describe, expect, it } from "vitest";
import { applyGtbGuards } from "../dispatch-guards";
import { setGtbAllowedMessageTypes, clearGtbContext } from "../gtb-context";
import { StreamEvent, UtilityEvent } from "../types";

describe("dispatch guards", () => {
  it("validates layout and allowed MTs", () => {
    const evts: StreamEvent[] = [
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 0, firstGroup: 0, groupCount: 2 } },
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 1, firstGroup: 2, groupCount: 2 } },
    ];
    expect(() => applyGtbGuards(evts, { allowedMessageTypes: new Set([0xf]) })).not.toThrow();
    expect(() => applyGtbGuards(evts, { allowOverlap: false, allowedMessageTypes: new Set([0x5]) })).toThrow(RangeError);
  });

  it("enforces MT permissions for utility events", () => {
    const utility: UtilityEvent = { kind: "utility", status: "noop", group: 0 };
    expect(() => applyGtbGuards([utility], { allowedMessageTypes: new Set([0xf]) })).toThrow(RangeError);
    expect(() => applyGtbGuards([utility], { allowedMessageTypes: new Set([0x0, 0xf]) })).not.toThrow();
  });

  it("uses GTB context map when no allowed set provided", () => {
    clearGtbContext();
    setGtbAllowedMessageTypes(2, new Set([0xf]));
    const streamEvt: StreamEvent = { kind: "stream", group: 2, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 0, firstGroup: 0, groupCount: 1 } };
    expect(() => applyGtbGuards([streamEvt])).not.toThrow();
    const utilityEvt: UtilityEvent = { kind: "utility", status: "noop", group: 2 };
    expect(() => applyGtbGuards([utilityEvt])).toThrow(RangeError);
  });
});
