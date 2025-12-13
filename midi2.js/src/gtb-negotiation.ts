import { applyGtbDescriptor, GtbDescriptor } from "./gtb-descriptor";
import { guardUmpWordsWithGtb } from "./gtb-guards";
import { validateDescriptorGroupsAgainstFunctionBlocks } from "./gtb-validator";
import { StreamEvent } from "./types";

export type GtbNegotiationOptions = {
  functionBlocks?: StreamEvent[];
  allowOverlap?: boolean;
};

/**
 * Apply a GTB descriptor (JSON object) into the GTB context map, validating against Function Blocks if provided.
 */
export function negotiateGtbContext(desc: GtbDescriptor, opts?: GtbNegotiationOptions): void {
  applyGtbDescriptor(desc, { functionBlocks: opts?.functionBlocks, allowOverlap: opts?.allowOverlap });
}

/**
 * Validate a descriptor against Function Block notifications without mutating GTB context.
 */
export function validateGtbDescriptor(desc: GtbDescriptor, functionBlocks: StreamEvent[], allowOverlap = false): void {
  validateDescriptorGroupsAgainstFunctionBlocks(desc, functionBlocks, allowOverlap);
}

/**
 * Guard ingress/egress UMP words using the current GTB context map.
 * No-op when no GTB context is registered for the target group.
 */
export function guardIngress(words: ArrayLike<number>): void {
  guardUmpWordsWithGtb(words);
}

export const guardEgress = guardIngress;
