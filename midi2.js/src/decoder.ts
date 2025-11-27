import { UmpPacket } from "./generated/openapi-types";
import { decodeUmp } from "./ump";
import { Midi2Event } from "./types";
import { eventToSchemaPacket } from "./schema-bridge";

export interface DecodedUmp {
  packet: UmpPacket | null;
  event: Midi2Event | null;
}

/**
 * Decode a UMP word array into both the OpenAPI `UmpPacket` shape (validated via generated guards)
 * and the high-level `Midi2Event` when available.
 */
export function decodeToPacketAndEvent(words: ArrayLike<number>): DecodedUmp | null {
  const event = decodeUmp(words);
  if (!event) return null;
  const packet = eventToSchemaPacket(event);
  return { packet, event };
}
