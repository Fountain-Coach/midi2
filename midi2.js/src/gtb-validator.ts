import { StreamEvent } from "./types";

/**
 * Metadata-only validator for GTB/Function Block layouts.
 * Ensures no overlapping group ranges for functionBlockInfoNotification events when allowOverlap=false.
 */
export function validateFunctionBlockLayouts(events: StreamEvent[], allowOverlap = false): void {
  if (allowOverlap) return;
  const ranges: Array<{ index: number; start: number; end: number }> = [];
  for (const evt of events) {
    if (evt.kind === "stream" && evt.opcode === "functionBlockInfoNotification") {
      const fb = evt.functionBlockInfoNotification ?? {};
      const idx = fb.index ?? 0;
      const start = (fb.firstGroup ?? 0) & 0x0f;
      const count = (fb.groupCount ?? 0) & 0x0f;
      const end = start + Math.max(0, count - 1);
      ranges.push({ index: idx, start, end });
    }
  }
  for (let i = 0; i < ranges.length; i++) {
    for (let j = i + 1; j < ranges.length; j++) {
      const a = ranges[i];
      const b = ranges[j];
      if (a.start <= b.end && b.start <= a.end) {
        throw new RangeError(`GTB/function block overlap between index ${a.index} and ${b.index}`);
      }
    }
  }
}

/**
 * Enforce allowed message types for a GTB context.
 * Throws RangeError if the message type nibble is disallowed.
 */
export function enforceAllowedMessageType(mt: number, allowed: Set<number>): void {
  const nibble = mt & 0xf;
  if (!allowed.has(nibble)) {
    throw new RangeError(`GTB disallows message type 0x${nibble.toString(16)}`);
  }
}
