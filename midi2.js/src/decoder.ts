import { UmpPacket } from "./generated/openapi-types";
import { decodeUmp } from "./ump";
import { Midi2Event } from "./types";
import { eventToSchemaPacket, decodeStreamWord } from "./schema-bridge";

export interface DecodedUmp {
  packet: UmpPacket | null;
  event: Midi2Event | null;
}

/**
 * Decode a UMP word array into both the OpenAPI `UmpPacket` shape (validated via generated guards)
 * and the high-level `Midi2Event` when available.
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
