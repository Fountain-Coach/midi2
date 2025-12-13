import { describe, expect, it, beforeEach } from "vitest";
import { clearGtbContext, getGtbAllowedMessageTypesForGroup } from "../gtb-context";
import { loadGtbDescriptorFromJson } from "../gtb-descriptor-loader";
import { StreamEvent } from "../types";

describe("GTB descriptor loader", () => {
  beforeEach(() => clearGtbContext());

  it("loads from JSON string and applies to context", () => {
    const json = `{"groups": {"0": ["0xf", 5], "1": ["0xf"]}}`;
    loadGtbDescriptorFromJson(json);
    expect(getGtbAllowedMessageTypesForGroup(0)).toEqual(new Set([0xf, 0x5]));
    expect(getGtbAllowedMessageTypesForGroup(1)).toEqual(new Set([0xf]));
  });

  it("validates against Function Blocks when provided", () => {
    const fbs: StreamEvent[] = [
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 0, firstGroup: 0, groupCount: 2 } },
    ];
    expect(() => loadGtbDescriptorFromJson({ groups: { 1: [0xf] } }, { functionBlocks: fbs })).not.toThrow();
    expect(() => loadGtbDescriptorFromJson({ groups: { 3: [0xf] } }, { functionBlocks: fbs })).toThrow(RangeError);
  });
});
