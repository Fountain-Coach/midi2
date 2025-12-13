import { describe, expect, it } from "vitest";
import { getProfileAssociations, getProfileAssociationsWithTimestamp, setProfileAssociations } from "../stream-profiles";

describe("stream profile associations", () => {
  it("stores and returns profile ids per function block", () => {
    setProfileAssociations(2, ["/org.midi/piano", "/org.midi/organ"]);
    expect(getProfileAssociations(2)).toEqual(["/org.midi/piano", "/org.midi/organ"]);
    const { profiles, lastUpdated } = getProfileAssociationsWithTimestamp(2);
    expect(profiles).toEqual(["/org.midi/piano", "/org.midi/organ"]);
    expect(typeof lastUpdated === "number" || lastUpdated === null).toBe(true);
  });

  it("masks index to byte", () => {
    setProfileAssociations(0x1ff, ["/org.midi/piano"]);
    expect(getProfileAssociations(0x1ff)).toEqual(["/org.midi/piano"]);
    expect(getProfileAssociations(0xff)).toEqual(["/org.midi/piano"]);
  });
});
