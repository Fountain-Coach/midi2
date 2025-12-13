import { PropertyExchangeEvent } from "./types";

export type SubscriptionAction =
  | { kind: "reply"; event: PropertyExchangeEvent }
  | { kind: "error"; status: number; message?: string };

type SubscriptionState = {
  subscriptionId: string;
  requestId?: number;
  flowControl: boolean;
  stage: SubscriptionStage;
  lastChunkNumber: number;
  resource?: string;
  lastActivityMs: number;
};

type SubscriptionStage = "start" | "partial" | "full" | "active";

/**
 * Minimal in-memory manager for MIDI-CI Property Exchange subscriptions.
 *
 * Handles start/partial/full/notify/end lifecycle, enforces flowControl support,
 * and returns acknowledgements or errors encoded as PropertyExchangeEvent stubs.
 *
 * This is a pure helper and does not send I/O directly.
 */
export class PeSubscriptionManager {
  private readonly supportsFlowControl: boolean;
  private readonly subs = new Map<string, SubscriptionState>();

  constructor(opts?: { supportsFlowControl?: boolean }) {
    this.supportsFlowControl = opts?.supportsFlowControl ?? true;
  }

  /**
   * Convenience that wraps {@link handle} and returns zero or more outbound
   * `PropertyExchangeEvent`s to emit (subscribe replies, ACK/NAK, errors).
   */
  process(event: PropertyExchangeEvent): PropertyExchangeEvent[] {
    const action = this.handle(event);
    if (!action) return [];
    if (action.kind === "reply") return [action.event];
    // translate errors to notify with status in header
    return [
      {
        kind: "propertyExchange",
        group: event.group,
        command: "notify",
        header: { status: action.status, message: action.message },
      },
    ];
  }

  /**
   * Process an incoming Property Exchange event and return any action
   * (subscribe reply, flow-control ACK/NAK, or error) to emit.
   */
  handle(event: PropertyExchangeEvent): SubscriptionAction | null {
    if (event.subscriptionCommand) {
      return this.handleLifecycle(event);
    }

    if (event.command === "subscribe") {
      if (!event.subscriptionId) {
        return { kind: "error", status: 400, message: "missing subscriptionId" };
      }
      const wantsFlowControl = Boolean(event.header?.flowControl);
      if (wantsFlowControl && !this.supportsFlowControl) {
        return {
          kind: "reply",
          event: {
            kind: "propertyExchange",
            group: event.group,
            command: "subscribeReply",
            subscriptionId: event.subscriptionId,
            header: { status: 406 },
          },
        };
      }
      const state: SubscriptionState = {
        subscriptionId: event.subscriptionId,
        requestId: event.requestId,
        flowControl: wantsFlowControl,
      };
      this.subs.set(event.subscriptionId, state);
      return {
        kind: "reply",
        event: {
          kind: "propertyExchange",
          group: event.group,
          command: "subscribeReply",
          subscriptionId: event.subscriptionId,
          header: { status: 200, flowControl: wantsFlowControl },
        },
      };
    }

    if (event.command === "notify") {
      if (!event.subscriptionId) {
        return { kind: "error", status: 400, message: "missing subscriptionId" };
      }
      const sub = this.subs.get(event.subscriptionId);
      if (!sub) {
        return { kind: "reply", event: { kind: "propertyExchange", group: event.group, command: "notify", header: { status: 404 } } };
      }
       if (sub.stage !== "active") {
        return { kind: "reply", event: { kind: "propertyExchange", group: event.group, command: "notify", header: { status: 409 } } };
      }
      // Flow control ACK on each chunk when requested and supported.
      if (sub.flowControl && event.header?.flowControl) {
        return {
          kind: "reply",
          event: {
            kind: "propertyExchange",
            group: event.group,
            command: "notify",
            flowControlAck: {
              status: 17,
              requestId: (event.header as any)?.requestId ?? 0,
              chunkNumber: (event.header as any)?.chunkNumber ?? 0,
              messageLength: event.data instanceof Uint8Array ? event.data.byteLength : 0,
            },
          },
        };
      }
      return null;
    }

    if (event.command === "terminate") {
      if (event.subscriptionId) {
        this.subs.delete(event.subscriptionId);
      }
      return null;
    }

    return null;
  }

  private handleLifecycle(event: PropertyExchangeEvent): SubscriptionAction | null {
    const id = event.subscriptionId;
    if (!id) {
      return { kind: "error", status: 400, message: "missing subscriptionId" };
    }
    const sub = this.subs.get(id);
    const resource = (event.header as any)?.resource ?? (event.header as any)?.res;
    switch (event.subscriptionCommand) {
      case "start": {
        const state: SubscriptionState = {
          subscriptionId: id,
          requestId: event.requestId,
          flowControl: Boolean(event.header?.flowControl),
          stage: "start",
          lastChunkNumber: -1,
          resource,
          lastActivityMs: Date.now(),
        };
        this.subs.set(id, state);
        return {
          kind: "reply",
          event: {
            kind: "propertyExchange",
            group: event.group,
            command: "subscribeReply",
            subscriptionId: id,
            subscriptionCommand: "start",
            header: { status: 200, flowControl: state.flowControl },
          },
        };
      }
      case "partial": {
        if (!sub) return { kind: "error", status: 404, message: "subscription not found" };
        sub.stage = "partial";
        sub.lastActivityMs = Date.now();
        this.subs.set(id, sub);
        return null;
      }
      case "full": {
        if (!sub) return { kind: "error", status: 404, message: "subscription not found" };
        sub.stage = "full";
        sub.lastActivityMs = Date.now();
        this.subs.set(id, sub);
        return {
          kind: "reply",
          event: {
            kind: "propertyExchange",
            group: event.group,
            command: "subscribeReply",
            subscriptionId: id,
            subscriptionCommand: "full",
            header: { status: 200 },
          },
        };
      }
      case "notify": {
        if (!sub) {
          return { kind: "reply", event: { kind: "propertyExchange", group: event.group, command: "notify", header: { status: 404 } } };
        }
        if (sub.resource && resource && sub.resource !== resource) {
          return { kind: "reply", event: { kind: "propertyExchange", group: event.group, command: "notify", header: { status: 409 } } };
        }
        if (sub.stage !== "full" && sub.stage !== "active") {
          return { kind: "reply", event: { kind: "propertyExchange", group: event.group, command: "notify", header: { status: 409 } } };
        }
        sub.stage = "active";
        const chunkNumber = typeof (event.header as any)?.chunkNumber === "number" ? (event.header as any).chunkNumber : sub.lastChunkNumber + 1;
        if (sub.flowControl && event.header?.flowControl) {
          if (chunkNumber !== sub.lastChunkNumber + 1) {
            sub.lastChunkNumber = chunkNumber;
            sub.lastActivityMs = Date.now();
            this.subs.set(id, sub);
            return {
              kind: "reply",
              event: {
                kind: "propertyExchange",
                group: event.group,
                command: "notify",
                flowControlNak: {
                  status: 18,
                  chunkNumber,
                },
              },
            };
          }
          sub.lastChunkNumber = chunkNumber;
        }
        sub.lastActivityMs = Date.now();
        this.subs.set(id, sub);
        if (sub.flowControl && event.header?.flowControl) {
          return {
            kind: "reply",
            event: {
              kind: "propertyExchange",
              group: event.group,
              command: "notify",
              flowControlAck: {
                status: 17,
                requestId: (event.header as any)?.requestId ?? 0,
                chunkNumber: (event.header as any)?.chunkNumber ?? 0,
                messageLength: event.data instanceof Uint8Array ? event.data.byteLength : 0,
              },
            },
          };
        }
        return null;
      }
      case "end": {
        this.subs.delete(id);
        return {
          kind: "reply",
          event: {
            kind: "propertyExchange",
            group: event.group,
            command: "subscribeReply",
            subscriptionId: id,
            subscriptionCommand: "end",
            header: { status: 200 },
          },
        };
      }
      default:
        return { kind: "error", status: 400, message: "unknown subscriptionCommand" };
    }
  }

  /**
   * Emit NAKs for subscriptions whose flow-control ACK window has timed out.
   * Returns PropertyExchangeEvents to send; caller controls timing.
   */
  collectTimeouts(nowMs = Date.now(), timeoutMs = 1000): PropertyExchangeEvent[] {
    const out: PropertyExchangeEvent[] = [];
    for (const [id, sub] of this.subs) {
      if (!sub.flowControl || sub.stage !== "active") continue;
      if (nowMs - sub.lastActivityMs >= timeoutMs) {
        const expectedChunk = sub.lastChunkNumber + 1;
        out.push({
          kind: "propertyExchange",
          group: 0,
          command: "notify",
          subscriptionId: id,
          flowControlNak: { status: 18, chunkNumber: expectedChunk },
        });
        // keep state so retry can proceed
        this.subs.set(id, { ...sub, lastActivityMs: nowMs });
      }
    }
    return out;
  }
}
