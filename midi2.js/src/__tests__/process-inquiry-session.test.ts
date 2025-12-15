import { describe, expect, it } from "vitest";
import { ProcessInquirySession } from "../process-inquiry-session";
import { ProcessInquiryEvent } from "../types";

const pi = (partial: Partial<ProcessInquiryEvent>): ProcessInquiryEvent => ({ kind: "processInquiry", group: 0, command: "capInquiry", ...partial } as ProcessInquiryEvent);

describe("ProcessInquirySession", () => {
  it("replies to capability inquiry with supported filters", () => {
    const session = new ProcessInquirySession({ filters: { noteOn: 1, clock: 1 } });
    const reply = session.handle(pi({ command: "capInquiry" }));
    expect(reply?.command).toBe("capReply");
    expect(reply?.filters?.noteOn).toBe(1);
    expect(reply?.filters?.clock).toBe(1);
  });

  it("clamps messageReport filters and drops unsupported", () => {
    const session = new ProcessInquirySession({ filters: { sysex: 1, noteOn: 2 } });
    const reply = session.handle(pi({ command: "messageReport", filters: { sysex: 3, clock: 2, messageDataControl: 0x02 } }));
    expect(reply?.command).toBe("messageReportReply");
    expect(reply?.filters?.sysex).toBe(1);
    expect(reply?.filters?.clock).toBeUndefined();
    expect(reply?.filters?.messageDataControl).toBeUndefined();
  });

  it("returns null when deviceId is invalid", () => {
    const session = new ProcessInquirySession({ deviceId: 0x10 });
    const reply = session.handle(pi({ command: "capInquiry" }));
    expect(reply).toBeNull();
  });
});
