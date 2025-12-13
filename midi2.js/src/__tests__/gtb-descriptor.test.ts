import { describe, expect, it, beforeEach } from "vitest";
import { applyGtbDescriptor } from "../gtb-descriptor";
import { clearGtbContext, getGtbAllowedMessageTypesForGroup } from "../gtb-context";

describe("GTB descriptor application", () => {
  beforeEach(() => clearGtbContext());

  it("applies per-group allowed MTs", () => {
    applyGtbDescriptor({ groups: { "1": ["0xf", "0x5"], "2": [0xf] } });
    expect(getGtbAllowedMessageTypesForGroup(1)).toEqual(new Set([0xf, 0x5]));
    expect(getGtbAllowedMessageTypesForGroup(2)).toEqual(new Set([0xf]));
  });
});
