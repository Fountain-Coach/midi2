import { describe, expect, it, beforeEach } from "vitest";
import { clearGtbContext, setGtbAllowedMessageTypes } from "../gtb-context";
import { guardUmpWordsWithGtb } from "../gtb-guards";

describe("gtb guards on raw UMP words", () => {
  beforeEach(() => clearGtbContext());

  it("enforces allowed MT when context is present", () => {
    setGtbAllowedMessageTypes(1, new Set([0xf]));
    expect(() => guardUmpWordsWithGtb([0xf1000000])).not.toThrow();
    expect(() => guardUmpWordsWithGtb([0x21000000])).toThrow(RangeError);
  });

  it("no-ops when context missing", () => {
    expect(() => guardUmpWordsWithGtb([0x21000000])).not.toThrow();
  });
});
