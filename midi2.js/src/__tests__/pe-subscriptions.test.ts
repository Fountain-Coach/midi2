import { describe, expect, it } from "vitest";
import { PeSubscriptionManager } from "../pe-subscriptions";
import { PropertyExchangeEvent } from "../types";

function pe(base: Partial<PropertyExchangeEvent>): PropertyExchangeEvent {
  return { kind: "propertyExchange", group: 0, command: "notify", ...base } as PropertyExchangeEvent;
}

describe("PeSubscriptionManager", () => {
  it("runs lifecycle start→partial→full→notify→end", () => {
    const mgr = new PeSubscriptionManager({ supportsFlowControl: true });
    const start = pe({ command: "subscribe", subscriptionCommand: "start", subscriptionId: "sub1", requestId: 1, header: { flowControl: true } });
    const startOut = mgr.process(start);
    expect(startOut[0]).toMatchObject({ command: "subscribeReply", subscriptionCommand: "start", header: { status: 200, flowControl: true } });

    mgr.process(pe({ command: "notify", subscriptionCommand: "partial", subscriptionId: "sub1" }));
    const fullOut = mgr.process(pe({ command: "notify", subscriptionCommand: "full", subscriptionId: "sub1" }));
    expect(fullOut[0]).toMatchObject({ command: "subscribeReply", subscriptionCommand: "full", header: { status: 200 } });

    const notify = pe({ command: "notify", subscriptionCommand: "notify", subscriptionId: "sub1", header: { flowControl: true }, data: new Uint8Array([1, 2]) });
    const ack = mgr.process(notify);
    expect(ack[0]?.flowControlAck?.status).toBe(17);

    // Out-of-order chunk should yield NAK
    const nak = mgr.process(pe({ command: "notify", subscriptionCommand: "notify", subscriptionId: "sub1", header: { flowControl: true, chunkNumber: 5 }, data: new Uint8Array([3]) }));
    expect(nak[0]?.flowControlNak?.status).toBe(18);

    const endOut = mgr.process(pe({ command: "notify", subscriptionCommand: "end", subscriptionId: "sub1" }));
    expect(endOut[0]).toMatchObject({ command: "subscribeReply", subscriptionCommand: "end", header: { status: 200 } });
  });

  it("rejects missing subscriptionId", () => {
    const mgr = new PeSubscriptionManager();
    const out = mgr.process(pe({ command: "notify", subscriptionCommand: "start" }));
    expect(out[0]?.header?.status).toBe(400);
  });

  it("errors on notify before full/active", () => {
    const mgr = new PeSubscriptionManager();
    mgr.process(pe({ command: "subscribe", subscriptionCommand: "start", subscriptionId: "sub2" }));
    const out = mgr.process(pe({ command: "notify", subscriptionCommand: "notify", subscriptionId: "sub2" }));
    expect(out[0]?.header?.status).toBe(409);
  });

  it("returns 404 when subscription unknown", () => {
    const mgr = new PeSubscriptionManager();
    const out = mgr.process(pe({ command: "notify", subscriptionCommand: "notify", subscriptionId: "missing" }));
    expect(out[0]?.header?.status).toBe(404);
  });

  it("rejects resource mismatch and emits timeout NAKs", () => {
    const mgr = new PeSubscriptionManager({ supportsFlowControl: true });
    mgr.process(pe({ command: "subscribe", subscriptionCommand: "start", subscriptionId: "subX", header: { resource: "resA", flowControl: true } }));
    mgr.process(pe({ command: "notify", subscriptionCommand: "full", subscriptionId: "subX", header: { resource: "resA" } }));
    mgr.process(pe({ command: "notify", subscriptionCommand: "notify", subscriptionId: "subX", header: { resource: "resA", flowControl: true, chunkNumber: 0 }, data: new Uint8Array([1]) }));
    const mismatch = mgr.process(pe({ command: "notify", subscriptionCommand: "notify", subscriptionId: "subX", header: { resource: "resB" } }));
    expect(mismatch[0]?.header?.status).toBe(409);
    // simulate timeout
    const nakEvents = mgr.collectTimeouts(Date.now() + 2000, 1);
    expect(nakEvents[0]?.flowControlNak?.status).toBe(18);
    // Exhaust retries to force timeout status
    const mgr2 = new PeSubscriptionManager({ supportsFlowControl: true, maxNakRetries: 1 });
    mgr2.process(pe({ command: "subscribe", subscriptionCommand: "start", subscriptionId: "subY", header: { resource: "resA", flowControl: true } }));
    mgr2.process(pe({ command: "notify", subscriptionCommand: "full", subscriptionId: "subY", header: { resource: "resA" } }));
    mgr2.process(pe({ command: "notify", subscriptionCommand: "notify", subscriptionId: "subY", header: { resource: "resA", flowControl: true, chunkNumber: 0 }, data: new Uint8Array([1]) }));
    // First timeout emits NAK (18)
    const timeoutEvents1 = mgr2.collectTimeouts(Date.now() + 2000, 1);
    const statuses1 = timeoutEvents1.map(ev => ev.header?.status ?? ev.flowControlNak?.status);
    expect(statuses1).toContain(18);
    expect(timeoutEvents1[0]?.header?.retryAfterMs).toBeGreaterThan(0);
    // Second timeout should exceed retries and emit 408
    const timeoutEvents2 = mgr2.collectTimeouts(Date.now() + 4000, 1);
    const statuses2 = timeoutEvents2.map(ev => ev.header?.status ?? ev.flowControlNak?.status);
    expect(statuses2).toContain(408);
  });
});
