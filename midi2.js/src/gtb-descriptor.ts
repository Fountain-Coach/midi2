import { setGtbAllowedMessageTypes } from "./gtb-context";
import { validateDescriptorGroupsAgainstFunctionBlocks } from "./gtb-validator";
import { StreamEvent } from "./types";

export type GtbDescriptor = {
  groups: Record<string | number, Array<number | string>>;
};

/**
 * Apply a GTB descriptor (e.g., parsed from USB descriptors) to the GTB context map.
 * Values are MT nibbles; non-hex strings are parsed with Number(...).
 */
export function applyGtbDescriptor(
  desc: GtbDescriptor,
  opts?: { functionBlocks?: StreamEvent[]; allowOverlap?: boolean },
): void {
  if (opts?.functionBlocks) {
    validateDescriptorGroupsAgainstFunctionBlocks(desc, opts.functionBlocks, opts.allowOverlap ?? false);
  }
  for (const [groupKey, mts] of Object.entries(desc.groups ?? {})) {
    const g = Number(groupKey) & 0xf;
    const allowed = new Set<number>();
    for (const mt of mts) {
      const n = typeof mt === "string" ? Number(mt) : mt;
      allowed.add((n ?? 0) & 0xf);
    }
    setGtbAllowedMessageTypes(g, allowed);
  }
}
