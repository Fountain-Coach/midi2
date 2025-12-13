import { describe, expect, it } from "vitest";
import { StreamNegotiationSession, negotiateStreamConfig } from "../stream-negotiation";

describe("stream negotiation helper", () => {
  it("accepts MIDI 2.0 with JR when supported", () => {
    const session = new StreamNegotiationSession({ supportsMIDI2: true, jrTx: true, jrRx: true });
    const result = session.negotiate({ protocol: "midi2", jrTimestampsTx: true, jrTimestampsRx: true });
    expect(result.notification.protocol).toBe("midi2");
    expect(result.notification.jrTimestampsTx).toBe(true);
    expect(result.notification.jrTimestampsRx).toBe(true);
    expect(result.mismatches).toEqual([]);
    expect(result.shouldNotifyPeer).toBe(true); // first negotiation
  });

  it("downgrades protocol and JR Tx when unsupported", () => {
    const session = new StreamNegotiationSession({ supportsMIDI2: false, jrTx: false, jrRx: true });
    const req = { protocol: "midi2", jrTimestampsTx: true, jrTimestampsRx: true } as const;
    const result = session.negotiate(req);
    expect(result.notification.protocol).toBe("midi1");
    expect(result.notification.jrTimestampsTx).toBe(false);
    expect(result.notification.jrTimestampsRx).toBe(true);
    expect(result.mismatches).toEqual([
      { kind: "protocolDowngraded", requested: "midi2", selected: "midi1" },
      { kind: "jrTxRejected" },
    ]);
    expect(result.shouldNotifyPeer).toBe(true);
    expect(session.lastConfigMismatch).toBe(true);
  });

  it("is idempotent for identical requests", () => {
    const session = new StreamNegotiationSession();
    const req = { protocol: "midi2", jrTimestampsTx: true, jrTimestampsRx: true } as const;
    session.negotiate(req);
    const second = session.negotiate(req);
    expect(second.mismatches).toEqual([]);
    expect(second.switchedProtocol).toBe(false);
    expect(second.shouldNotifyPeer).toBe(false);
  });

  it("triggers notification on protocol switch", () => {
    const session = new StreamNegotiationSession();
    session.negotiate({ protocol: "midi1", jrTimestampsTx: false, jrTimestampsRx: false });
    const result = session.negotiate({ protocol: "midi2", jrTimestampsTx: true, jrTimestampsRx: true });
    expect(result.notification.protocol).toBe("midi2");
    expect(result.switchedProtocol).toBe(true);
    expect(result.shouldNotifyPeer).toBe(true);
  });

  it("works statelessly with a provided previous config", () => {
    const prev = { protocol: "midi2", jrTimestampsTx: true, jrTimestampsRx: true } as const;
    const res = negotiateStreamConfig({ protocol: "midi2", jrTimestampsTx: true, jrTimestampsRx: true }, { supportsMIDI2: true, jrTx: true, jrRx: false }, { previous: prev });
    expect(res.notification.jrTimestampsRx).toBe(false);
    expect(res.mismatches).toEqual([{ kind: "jrRxRejected" }]);
    expect(res.shouldNotifyPeer).toBe(true);
  });
});
