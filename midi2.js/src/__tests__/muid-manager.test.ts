import { describe, expect, it } from "vitest";
import { MuidManager } from "../muid-manager";

describe("MuidManager", () => {
  it("uses the preferred hint when available", () => {
    const mgr = new MuidManager({ localHint: 0x0a0b0c0d, now: () => 0 });
    expect(mgr.localMuid).toBe(0x0a0b0c0d);
  });

  it("rotates on conflict with local MUID", () => {
    let now = 0;
    const mgr = new MuidManager({ localHint: 0x01020304, ttlMs: 10_000, now: () => now });
    const old = mgr.localMuid;
    const conflicted = mgr.registerPeer(old, now);
    expect(conflicted).toBe(true);
    expect(mgr.localMuid).not.toBe(old);
    expect(mgr.peersSnapshot.find(p => p.muid === old)).toBeTruthy();
  });

  it("cleans up expired peers", () => {
    let now = 0;
    const mgr = new MuidManager({ ttlMs: 5_000, now: () => now });
    mgr.registerPeer(0xaaaa, now); // expires at 5000
    now = 3_000;
    mgr.registerPeer(0xbbbb, now); // expires at 8000
    now = 8_000;
    const expired = mgr.cleanup(now);
    expect(expired).toContain(0xaaaa);
    expect(expired).not.toContain(0xbbbb);
    expect(mgr.peersSnapshot.some(p => p.muid === 0xbbbb)).toBe(true);
  });

  it("refreshes peer lifetime on re-registration", () => {
    let now = 0;
    const mgr = new MuidManager({ ttlMs: 2_000, now: () => now });
    mgr.registerPeer(0xdead, now); // expires at 2000
    now = 1_500;
    mgr.registerPeer(0xdead, now); // refresh to 1500 + TTL = 3500
    now = 3_100;
    const expired = mgr.cleanup(now);
    expect(expired).not.toContain(0xdead);
  });
});
