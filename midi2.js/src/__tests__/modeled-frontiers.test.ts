import {
  MidiCiTransaction,
  ProfileChannelAllocation,
  PropertyExchangeResourceTransaction,
  UmpOrderingValidator,
  selectCompatibleFeatures,
} from "../modeled-frontiers";
import { describe, expect, it } from "vitest";

describe("modeled frontier runtime", () => {
  it("selects compatible features and reports missing requirements", () => {
    expect(selectCompatibleFeatures(["midi2", "jr"], ["midi2"])).toEqual({ compatible: false, selected: ["midi2"], missing: ["jr"] });
  });

  it("makes MIDI-CI failure terminal", () => {
    const tx = new MidiCiTransaction();
    tx.sendRequest();
    tx.acceptRequest();
    tx.timeout();
    expect(tx.state).toBe("timed-out");
    expect(() => tx.receiveResponse()).toThrow();
  });

  it("allocates and releases profile channels only after inquiry", () => {
    const allocation = new ProfileChannelAllocation("/org.midi/piano", [0, 15]);
    expect(() => allocation.accept()).toThrow();
    allocation.inquire();
    allocation.beginNegotiation();
    allocation.accept();
    allocation.release();
    expect(allocation.state).toBe("released");
  });

  it("keeps invalid Property Exchange resources out of completion", () => {
    const tx = new PropertyExchangeResourceTransaction("/device/name", 7);
    tx.request();
    tx.invalidate("unsupported-resource");
    expect(tx.state).toBe("invalid");
    expect(() => tx.complete()).toThrow();
  });

  it("enforces packet ordering and reserved message types", () => {
    const validator = new UmpOrderingValidator();
    expect(validator.validate(new Uint32Array([0x40000000]), 1)).toMatchObject({ accepted: false, kind: "out-of-order" });
    expect(validator.validate(new Uint32Array([0xd0000000]), 0)).toMatchObject({ accepted: false, kind: "reserved" });
    expect(validator.validate(new Uint32Array([0x40000000]), 0)).toEqual({ accepted: true, sequence: 0 });
  });
});
