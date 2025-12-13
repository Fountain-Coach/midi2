import { enforceAllowedMessageType } from "./gtb-validator";
import { getGtbAllowedMessageTypesForGroup } from "./gtb-context";

/**
 * Enforce GTB allowed MTs for a raw UMP word array using the shared GTB context map.
 * No-op when no context is registered for the group.
 */
export function guardUmpWordsWithGtb(words: ArrayLike<number>): void {
  const word0 = words[0] ?? 0;
  const group = (word0 >>> 24) & 0xf;
  const mt = (word0 >>> 28) & 0xf;
  const allowed = getGtbAllowedMessageTypesForGroup(group);
  if (allowed) {
    enforceAllowedMessageType(mt, allowed);
  }
}
