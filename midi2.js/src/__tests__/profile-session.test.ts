import { describe, expect, it } from "vitest";
import { ProfileSession } from "../profile-session";

describe("ProfileSession", () => {
  it("handles inquiry, enable, details, and disable", () => {
    const session = new ProfileSession(["org.midi.piano"]);
    const inquiry = session.handle({ kind: "profile", group: 2, command: "inquiry", profileId: "org.midi.piano", target: "channel", channels: [0, 1] });
    expect(inquiry[0]?.command).toBe("reply");
    expect(inquiry[0]).toMatchObject({ group: 2, details: { supported: 1, enabled: 0, cmL: 3, cmH: 0 } });

    const enabled = session.handle({ kind: "profile", group: 0, command: "setOn", profileId: "org.midi.piano", target: "channel", channels: [0] });
    expect(enabled[0]?.command).toBe("enabledReport");
    expect(enabled[0]?.details?.ok).toBe(1);

    const details = session.handle({ kind: "profile", group: 0, command: "detailsInquiry", profileId: "org.midi.piano", target: "channel", channels: [0] });
    expect(details[0]?.command).toBe("detailsReply");
    expect(details[0]?.details).toMatchObject({ supported: 1, enabled: 1, psd: 1, cmL: 1 });

    const disabled = session.handle({ kind: "profile", group: 0, command: "setOff", profileId: "org.midi.piano", target: "channel", channels: [0] });
    expect(disabled[0]?.command).toBe("disabledReport");
  });

  it("rejects unsupported profiles and removes support", () => {
    const session = new ProfileSession();
    const rejected = session.handle({ kind: "profile", group: 0, command: "setOn", profileId: "missing", target: "group" });
    expect(rejected[0]?.command).toBe("disabledReport");
    expect(rejected[0]?.details?.ok).toBe(0);

    const added = session.updateSupportedProfiles(["new"], "group");
    expect(added[0]?.command).toBe("addedReport");
    const removed = session.updateSupportedProfiles([], "group");
    expect(removed[0]?.command).toBe("removedReport");
  });
});
