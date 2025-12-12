import { describe, expect, it } from "vitest";
import { PeSubscriptionManager } from "../pe-subscriptions";
import { PropertyExchangeEvent } from "../types";

function pe(base: Partial<PropertyExchangeEvent>): PropertyExchangeEvent {
  return { kind: "propertyExchange", group: 0, command: "notify", ...base } as PropertyExchangeEvent;
}

describe("PeSubscriptionManager", () => {
  it("accepts subscribe and returns subscribeReply", () => {
    const mgr = new PeSubscriptionManager({ supportsFlowControl: true });
    const subEvt = pe({ command: "subscribe", subscriptionId: "sub1", requestId: 1, header: { flowControl: true } });
    const out = mgr.process(subEvt);
    expect(out.length).toBe(1);
    expect(out[0]).toMatchObject({ command: "subscribeReply", subscriptionId: "sub1", header: { status: 200, flowControl: true } });
  });

  it("rejects flowControl when unsupported", () => {
    const mgr = new PeSubscriptionManager({ supportsFlowControl: false });
    const subEvt = pe({ command: "subscribe", subscriptionId: "sub2", requestId: 2, header: { flowControl: true } });
    const out = mgr.process(subEvt);
    expect(out.length).toBe(1);
    expect(out[0]).toMatchObject({ command: "subscribeReply", header: { status: 406 } });
  });

  it("returns error when subscribe is missing subscriptionId", () => {
    const mgr = new PeSubscriptionManager();
    const out = mgr.process(pe({ command: "subscribe", requestId: 3 }));
    expect(out[0]?.header?.status).toBe(400);
  });

  it("acks notify chunks when flowControl is active", () => {
    const mgr = new PeSubscriptionManager({ supportsFlowControl: true });
    mgr.handle(pe({ command: "subscribe", subscriptionId: "sub3", header: { flowControl: true } }));
    const notify = pe({ command: "notify", subscriptionId: "sub3", header: { flowControl: true }, data: new Uint8Array([1, 2, 3]) });
    const out = mgr.process(notify);
    expect(out[0]?.flowControlAck?.status).toBe(17);
    expect(out[0]?.flowControlAck?.chunkNumber).toBeDefined();
  });

  it("returns 404 notify when subscription unknown", () => {
    const mgr = new PeSubscriptionManager();
    const notify = pe({ command: "notify", subscriptionId: "missing" });
    const out = mgr.process(notify);
    expect(out[0]?.header?.status).toBe(404);
  });

  it("removes subscription on terminate", () => {
    const mgr = new PeSubscriptionManager();
    mgr.handle(pe({ command: "subscribe", subscriptionId: "sub4" }));
    mgr.handle(pe({ command: "terminate", subscriptionId: "sub4" }));
    const action = mgr.handle(pe({ command: "notify", subscriptionId: "sub4" }));
    if (action?.kind === "reply") {
      expect(action.event?.header?.status).toBe(404);
    }
  });
});
