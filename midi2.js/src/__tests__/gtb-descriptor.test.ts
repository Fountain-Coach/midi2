import { describe, expect, it, beforeEach } from "vitest";
import { applyGtbDescriptor } from "../gtb-descriptor";
import { clearGtbContext, getGtbAllowedMessageTypesForGroup } from "../gtb-context";
import { StreamEvent } from "../types";

describe("GTB descriptor application", () => {
  beforeEach(() => clearGtbContext());

  it("applies per-group allowed MTs", () => {
    applyGtbDescriptor({ groups: { "1": ["0xf", "0x5"], "2": [0xf] } });
    expect(getGtbAllowedMessageTypesForGroup(1)).toEqual(new Set([0xf, 0x5]));
    expect(getGtbAllowedMessageTypesForGroup(2)).toEqual(new Set([0xf]));
  });

  it("validates descriptor groups against function blocks when provided", () => {
    const fbs: StreamEvent[] = [
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 0, firstGroup: 0, groupCount: 2 } },
    ];
    expect(() => applyGtbDescriptor({ groups: { 1: [0xf] } }, { functionBlocks: fbs })).not.toThrow();
    expect(() => applyGtbDescriptor({ groups: { 3: [0xf] } }, { functionBlocks: fbs })).toThrow(RangeError);
  });
});
