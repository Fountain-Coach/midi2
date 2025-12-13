import { describe, expect, it, beforeEach } from "vitest";
import { clearGtbContext, getGtbAllowedMessageTypesForGroup } from "../gtb-context";
import { guardIngress, negotiateGtbContext, validateGtbDescriptor } from "../gtb-negotiation";
import { StreamEvent } from "../types";

describe("GTB negotiation helpers", () => {
  beforeEach(() => clearGtbContext());

  it("negotiates descriptor into context", () => {
    negotiateGtbContext({ groups: { 1: [0xf] } });
    expect(getGtbAllowedMessageTypesForGroup(1)).toEqual(new Set([0xf]));
  });

  it("validates against function blocks", () => {
    const fbs: StreamEvent[] = [
      { kind: "stream", group: 0, opcode: "functionBlockInfoNotification", functionBlockInfoNotification: { index: 0, firstGroup: 0, groupCount: 2 } },
    ];
    expect(() => validateGtbDescriptor({ groups: { 0: [0xf] } }, fbs)).not.toThrow();
    expect(() => validateGtbDescriptor({ groups: { 3: [0xf] } }, fbs)).toThrow(RangeError);
  });

  it("guards ingress words using negotiated context", () => {
    negotiateGtbContext({ groups: { 2: [0xf] } });
    expect(() => guardIngress([0xf2000000])).not.toThrow();
    expect(() => guardIngress([0x22000000])).toThrow(RangeError);
  });
});
