import { enforceAllowedMessageType, validateFunctionBlockLayouts } from "./gtb-validator";
import { StreamEvent } from "./types";

/**
 * Apply GTB-related guards to a decoded Stream event list.
 * - Validates function block layout overlap unless allowOverlap=true.
 * - Enforces allowed MT set if provided.
 */
export function applyGtbGuards(events: StreamEvent[], opts?: { allowOverlap?: boolean; allowedMessageTypes?: Set<number> }): void {
  const allowOverlap = opts?.allowOverlap ?? false;
  validateFunctionBlockLayouts(events, allowOverlap);
  if (opts?.allowedMessageTypes) {
    for (const evt of events) {
      if (evt.kind === "stream") {
        const mt = 0xf; // stream MT
        enforceAllowedMessageType(mt, opts.allowedMessageTypes);
      }
    }
  }
}
