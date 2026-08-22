/** Software-only projections for the remaining modeled MIDI 2.0 frontiers. */

export type CompatibilitySelection = {
  compatible: boolean;
  selected: string[];
  missing: string[];
};

export function selectCompatibleFeatures(requested: Iterable<string>, supported: Iterable<string>): CompatibilitySelection {
  const available = new Set(supported);
  const requestedList = [...new Set(requested)];
  const selected = requestedList.filter(feature => available.has(feature));
  return { compatible: selected.length === requestedList.length, selected, missing: requestedList.filter(feature => !available.has(feature)) };
}

export type MidiCiTransactionState = "idle" | "request-sent" | "awaiting-response" | "completed" | "failed" | "timed-out";

export class MidiCiTransaction {
  state: MidiCiTransactionState = "idle";
  failureReason?: string;

  private requireState(...allowed: MidiCiTransactionState[]): void {
    if (!allowed.includes(this.state)) throw new Error(`invalid MIDI-CI transaction state: ${this.state}`);
  }

  sendRequest(): void { this.requireState("idle"); this.state = "request-sent"; }
  acceptRequest(): void { this.requireState("request-sent"); this.state = "awaiting-response"; }
  receiveResponse(): void { this.requireState("awaiting-response"); this.state = "completed"; }
  timeout(): void { this.requireState("awaiting-response"); this.state = "timed-out"; this.failureReason = "timeout"; }
  reject(reason = "rejected"): void { this.requireState("request-sent", "awaiting-response"); this.state = "failed"; this.failureReason = reason; }
}

export type ProfileChannelAllocationState = "unallocated" | "inquiry" | "negotiating" | "allocated" | "released" | "rejected";

export class ProfileChannelAllocation {
  readonly profileId: string;
  readonly channels: number[];
  state: ProfileChannelAllocationState = "unallocated";

  constructor(profileId: string, channels: Iterable<number>) {
    if (!profileId) throw new RangeError("profileId must not be empty");
    const unique = [...new Set(channels)];
    if (!unique.length || unique.some(channel => !Number.isInteger(channel) || channel < 0 || channel > 15)) {
      throw new RangeError("channels must contain MIDI channels in [0, 15]");
    }
    this.profileId = profileId;
    this.channels = unique.sort((a, b) => a - b);
  }

  inquire(): void { if (this.state !== "unallocated" && this.state !== "released" && this.state !== "rejected") throw new Error(`invalid allocation state: ${this.state}`); this.state = "inquiry"; }
  beginNegotiation(): void { if (this.state !== "inquiry") throw new Error(`allocation requires inquiry, got ${this.state}`); this.state = "negotiating"; }
  accept(): void { if (this.state !== "negotiating") throw new Error(`allocation requires negotiation, got ${this.state}`); this.state = "allocated"; }
  reject(): void { if (this.state !== "negotiating") throw new Error(`allocation requires negotiation, got ${this.state}`); this.state = "rejected"; }
  release(): void { if (this.state !== "allocated") throw new Error(`only an allocated profile can be released, got ${this.state}`); this.state = "released"; }
}

export type PropertyExchangeResourceState = "idle" | "requested" | "accepted" | "responding" | "completed" | "rejected" | "invalid";

export class PropertyExchangeResourceTransaction {
  readonly resource: string;
  readonly requestId: number;
  state: PropertyExchangeResourceState = "idle";
  failureReason?: string;

  constructor(resource: string, requestId: number) {
    if (!resource || !Number.isInteger(requestId) || requestId < 0 || requestId > 0xffffffff) throw new RangeError("resource and requestId are required");
    this.resource = resource;
    this.requestId = requestId;
  }
  request(): void { if (this.state !== "idle") throw new Error(`invalid resource transaction state: ${this.state}`); this.state = "requested"; }
  accept(): void { if (this.state !== "requested") throw new Error(`resource request is not pending: ${this.state}`); this.state = "accepted"; }
  beginResponse(): void { if (this.state !== "accepted" && this.state !== "responding") throw new Error(`resource response is not allowed: ${this.state}`); this.state = "responding"; }
  complete(): void { if (this.state !== "responding") throw new Error(`resource response is not active: ${this.state}`); this.state = "completed"; }
  reject(reason = "rejected"): void { if (this.state !== "requested" && this.state !== "accepted") throw new Error(`resource rejection is not allowed: ${this.state}`); this.state = "rejected"; this.failureReason = reason; }
  invalidate(reason = "invalid-resource"): void { if (this.state === "completed") throw new Error("completed resource transaction cannot be invalidated"); this.state = "invalid"; this.failureReason = reason; }
}

export type UmpValidation = { accepted: true; sequence: number } | { accepted: false; kind: "out-of-order" | "reserved" | "invalid"; message: string };

/** Validates software packet ordering and reserved message-type rejection. */
export class UmpOrderingValidator {
  private nextSequence = 0;
  validate(packet: ArrayLike<number>, sequence: number): UmpValidation {
    if (sequence !== this.nextSequence) return { accepted: false, kind: "out-of-order", message: `expected sequence ${this.nextSequence}, got ${sequence}` };
    if (!packet.length || packet.length > 4) return { accepted: false, kind: "invalid", message: "UMP packet must contain one to four words" };
    const first = packet[0] ?? 0;
    if (!Number.isInteger(first) || first < 0 || first > 0xffffffff) return { accepted: false, kind: "invalid", message: "UMP words must be uint32" };
    const messageType = (first >>> 28) & 0xf;
    if (messageType === 0xd) return { accepted: false, kind: "reserved", message: "UMP message type 0xD is reserved" };
    this.nextSequence += 1;
    return { accepted: true, sequence };
  }
}
