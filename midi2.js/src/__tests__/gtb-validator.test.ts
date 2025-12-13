import { describe, expect, it } from "vitest";
import { enforceAllowedMessageType, validateDescriptorGroupsAgainstFunctionBlocks, validateFunctionBlockLayouts } from "../gtb-validator";
import { StreamEvent } from "../types";

describe("GTB validator", () => {
  it("passes non-overlapping blocks", () => {
    const events: StreamEvent[] = [
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 0, firstGroup: 0, groupCount: 2 } },
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 1, firstGroup: 2, groupCount: 2 } },
    ];
    expect(() => validateFunctionBlockLayouts(events)).not.toThrow();
  });

  it("rejects overlapping blocks", () => {
    const events: StreamEvent[] = [
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 0, firstGroup: 0, groupCount: 4 } },
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 1, firstGroup: 3, groupCount: 2 } },
    ];
    expect(() => validateFunctionBlockLayouts(events)).toThrow(RangeError);
  });

  it("enforces allowed message types", () => {
    expect(() => enforceAllowedMessageType(0x5, new Set([0x5, 0xf]))).not.toThrow();
    expect(() => enforceAllowedMessageType(0x2, new Set([0x5, 0xf]))).toThrow(RangeError);
  });

  it("validates descriptor groups against function blocks", () => {
    const events: StreamEvent[] = [
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 0, firstGroup: 0, groupCount: 2 } },
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 1, firstGroup: 2, groupCount: 2 } },
    ];
    expect(() => validateDescriptorGroupsAgainstFunctionBlocks({ groups: { 0: [0xf], 3: [0xf] } }, events)).not.toThrow();
    expect(() => validateDescriptorGroupsAgainstFunctionBlocks({ groups: { 4: [0xf] } }, events)).toThrow(RangeError);
  });
});
