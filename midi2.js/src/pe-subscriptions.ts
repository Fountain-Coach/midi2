import { PropertyExchangeEvent } from "./types";

export type SubscriptionAction =
  | { kind: "reply"; event: PropertyExchangeEvent }
  | { kind: "error"; status: number; message?: string };

type SubscriptionState = {
  subscriptionId: string;
  requestId?: number;
  flowControl: boolean;
};

/**
 * Minimal in-memory manager for MIDI-CI Property Exchange subscriptions.
 *
 * Handles start/notify/end lifecycle, enforces flowControl support, and returns
 * acknowledgements or errors encoded as PropertyExchangeEvent stubs.
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
}
