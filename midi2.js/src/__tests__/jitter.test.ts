import { describe, expect, it } from "vitest";
import { JitterReductionSynchronizer } from "../jitter";

function createMockClock(start = 0): { clock: { now: () => number }; advance: (ms: number) => void } {
  let now = start;
  return {
    clock: { now: () => now },
    advance: (ms: number) => {
      now += ms;
    },
  };
}

describe("JitterReductionSynchronizer", () => {
  it("anchors jrClock and projects jrTimestamp to host time", () => {
    const mock = createMockClock(1000);
    const jr = new JitterReductionSynchronizer(mock.clock, 1); // 1 unit = 1ms for test simplicity
    jr.handle({ kind: "utility", status: "jrClock", value: 900, timestampGroup: 0 }, mock.clock.now());
    const abs = jr.handle({ kind: "utility", status: "jrTimestamp", value: 950, timestampGroup: 0 }, mock.clock.now());
    expect(abs).toBe(1050);
    expect(jr.toAbsoluteTime(0, 960)).toBe(1060);
  });

  it("returns null if no jrClock has been observed for group", () => {
    const mock = createMockClock();
    const jr = new JitterReductionSynchronizer(mock.clock, 1);
    expect(jr.handle({ kind: "utility", status: "jrTimestamp", value: 10, timestampGroup: 1 }, mock.clock.now())).toBeNull();
    expect(jr.toAbsoluteTime(1, 10)).toBeNull();
  });
});
