import { enforceAllowedMessageType, validateFunctionBlockLayouts } from "./gtb-validator";
import { StreamEvent, UtilityEvent } from "./types";

/**
 * Apply GTB-related guards to decoded events.
 * - Validates function block layout overlap unless allowOverlap=true.
 * - Enforces allowed MT set (stream MT=0xF, utility MT=0x0) if provided.
 */
export function applyGtbGuards(
  events: Array<StreamEvent | UtilityEvent>,
  opts?: { allowOverlap?: boolean; allowedMessageTypes?: Set<number> },
): void {
  const allowOverlap = opts?.allowOverlap ?? false;
  validateFunctionBlockLayouts(events.filter((e): e is StreamEvent => e.kind === "stream"), allowOverlap);
  if (opts?.allowedMessageTypes) {
    for (const evt of events) {
      if (evt.kind === "stream") {
        enforceAllowedMessageType(0xf, opts.allowedMessageTypes);
      } else if (evt.kind === "utility") {
        enforceAllowedMessageType(0x0, opts.allowedMessageTypes);
      }
    }
  }
}
