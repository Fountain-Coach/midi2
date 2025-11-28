import { MidiClock } from "./clock";
import { UtilityEvent } from "./types";

type GroupState = {
  baseMs: number;
  clockValue: number;
  lastTimestamp?: number;
};

/**
 * Tracks Jitter Reduction (JR) clock/timestamp messages and projects them into the host clock domain.
 * Assumes JR units are expressed in milliseconds unless overridden via `unitMs`.
 * This is a minimal helper; callers must wire incoming utility events (jrClock/jrTimestamp) into `handle`.
 */
export class JitterReductionSynchronizer {
  private readonly clock: MidiClock;
  private readonly unitMs: number;
  private readonly groups = new Map<number, GroupState>();

  constructor(clock: MidiClock, unitMs = 1) {
    this.clock = clock;
    this.unitMs = unitMs;
  }

  /**
    * Handle a utility event (jrClock or jrTimestamp) and update internal state.
    * Returns an absolute host time (ms) when a jrTimestamp is processed and a base clock is known; otherwise null.
    */
  handle(event: UtilityEvent, receivedAtMs = this.clock.now()): number | null {
    if (event.kind !== "utility") return null;
    if (event.status === "jrClock") {
      const state: GroupState = {
        baseMs: receivedAtMs - (event.value ?? 0) * this.unitMs,
        clockValue: event.value ?? 0,
        lastTimestamp: undefined,
      };
      this.groups.set(event.timestampGroup ?? 0, state);
      return null;
    }
    if (event.status === "jrTimestamp") {
      const group = event.timestampGroup ?? 0;
      const state = this.groups.get(group);
      if (!state) return null;
      state.lastTimestamp = event.value ?? 0;
      return state.baseMs + (event.value ?? 0) * this.unitMs;
    }
    return null;
  }

  /**
   * Convert a JR timestamp value into an absolute host time (ms) for the given group.
   * Returns null if no JR clock has been observed for the group.
   */
  toAbsoluteTime(group: number, jrTimestampValue?: number): number | null {
    const state = this.groups.get(group);
    if (!state) return null;
    const value = jrTimestampValue ?? state.lastTimestamp;
    if (value === undefined) return null;
    return state.baseMs + value * this.unitMs;
  }
}
