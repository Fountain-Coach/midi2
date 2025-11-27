import { describe, expect, it } from "vitest";
import { decodeToPacketAndEvent } from "../decoder";
import fs from "fs";
import path from "path";

function hexToWord(hex: string): number {
  return Number(BigInt(hex));
}

function loadJSON(relPath: string) {
  const abs = path.resolve(__dirname, "../../../docs/pb-vrt", relPath);
  return JSON.parse(fs.readFileSync(abs, "utf8"));
}

describe("PB-VRT golden vectors", () => {
  it("decodes stream config request/notification", () => {
    const req = loadJSON("stream/stream_config_request.json");
    const words = new Uint32Array([hexToWord(req.word)]);
    const decoded = decodeToPacketAndEvent(words);
    expect(decoded?.event?.kind).toBe("stream");
    expect(decoded?.event).toMatchObject({
      opcode: "streamConfigRequest",
      streamConfigRequest: { protocol: "midi2", jrTimestampsTx: true, jrTimestampsRx: true },
    });

    const notif = loadJSON("stream/stream_config_notification.json");
    const notifWords = new Uint32Array([hexToWord(notif.word)]);
    const decodedNotif = decodeToPacketAndEvent(notifWords);
    expect(decodedNotif?.event?.kind).toBe("stream");
    expect(decodedNotif?.event).toMatchObject({
      opcode: "streamConfigNotification",
      streamConfigNotification: { protocol: "midi2", jrTimestampsTx: true, jrTimestampsRx: false },
    });
  });

  it("decodes function block info and discovery", () => {
    const info = loadJSON("stream/function_block_info.json");
    const infoWords = new Uint32Array([hexToWord(info.word)]);
    const decodedInfo = decodeToPacketAndEvent(infoWords);
    expect(decodedInfo?.event).toMatchObject({
      kind: "stream",
      opcode: "functionBlockInfo",
      functionBlockInfo: { index: 1, firstGroup: 10, groupCount: 3 },
    });

    const discovery = loadJSON("stream/function_block_discovery.json");
    const discWords = discovery.map((entry: any) => hexToWord(entry.word ?? entry));
    const decodedDisc = decodeToPacketAndEvent(new Uint32Array([discWords[0]]));
    expect(decodedDisc?.event?.kind).toBe("stream");
  });

  it("decodes JR clock/timestamp sequence", () => {
    const jr = loadJSON("jr/clock_timestamp.json").sequence;
    const events = jr.map((e: any) =>
      decodeToPacketAndEvent(
        new Uint32Array([
          (0x0 << 28) | // utility mt
            (0x0 << 24) |
            (e.utility === "jrClock" ? 0x01 << 16 : 0x02 << 16) |
            (e.value & 0xffff),
        ]),
      ),
    );
    expect(events.every(e => e?.event?.kind === "utility")).toBe(true);
  });
});
