import { UmpPacket } from "./generated/openapi-types";
import { decodeUmp } from "./ump";
import { Midi2Event } from "./types";
import { eventToSchemaPacket, decodeStreamWord } from "./schema-bridge";
import { enforceAllowedMessageType } from "./gtb-validator";
import { getGtbAllowedMessageTypesForGroup } from "./gtb-context";

export interface DecodedUmp {
  packet: UmpPacket | null;
  event: Midi2Event | null;
}

/**
 * Decode UMP words into both the OpenAPI `UmpPacket` (when mappable) and a high-level `Midi2Event`.
 * Stream MT=0xF packets are translated into `StreamEvent` when possible.
 */
export function decodeToPacketAndEvent(words: ArrayLike<number>): DecodedUmp | null {
  let event = decodeUmp(words);
  if (!event) return null;
  const word0 = words[0] ?? 0;
  const mt = (word0 >>> 28) & 0xf;
  if (event.kind === "rawUMP" && mt === 0xf) {
    const stream = decodeStreamWord(word0);
    if (stream) {
      event = stream;
    }
  }
  const packet = eventToSchemaPacket(event);
  return { packet, event };
}

/**
 * Decode with optional GTB guards.
 * - `allowedMessageTypes`: set of MT nibbles allowed in the current GTB context.
 */
export function decodeToPacketAndEventWithGuards(
  words: ArrayLike<number>,
  opts?: { allowedMessageTypes?: Set<number> },
): DecodedUmp | null {
  const word0 = words[0] ?? 0;
  if (opts?.allowedMessageTypes) {
    const mt = (word0 >>> 28) & 0xf;
    enforceAllowedMessageType(mt, opts.allowedMessageTypes);
  }
  return decodeToPacketAndEvent(words);
}

/**
 * Decode with GTB context-aware MT enforcement (per-group).
 * Falls back to plain decode if no GTB context is registered for the group.
 */
export function decodeWithGtbContext(words: ArrayLike<number>): DecodedUmp | null {
  const word0 = words[0] ?? 0;
  const group = (word0 >>> 24) & 0xf;
  const mt = (word0 >>> 28) & 0xf;
  const allowed = getGtbAllowedMessageTypesForGroup(group);
  if (allowed) {
    enforceAllowedMessageType(mt, allowed);
  }
  return decodeToPacketAndEvent(words);
}
