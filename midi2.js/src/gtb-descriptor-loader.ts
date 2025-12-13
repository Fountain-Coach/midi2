import { applyGtbDescriptor, GtbDescriptor } from "./gtb-descriptor";
import { StreamEvent } from "./types";

/**
 * Load a GTB descriptor from JSON (string or parsed object) and apply it to the GTB context.
 * Optional Function Block notifications can be supplied to validate coverage.
 */
export function loadGtbDescriptorFromJson(
  source: string | GtbDescriptor,
  opts?: { functionBlocks?: StreamEvent[]; allowOverlap?: boolean },
): void {
  const desc: GtbDescriptor = typeof source === "string" ? JSON.parse(source) : source;
  applyGtbDescriptor(desc, opts);
}
