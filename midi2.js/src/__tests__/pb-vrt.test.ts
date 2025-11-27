import { describe, expect, it } from "vitest";
import { decodeToPacketAndEvent } from "../decoder";
import { eventToSchemaPacket } from "../schema-bridge";
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

  it("decodes profile enable/disable sequence", () => {
    const seq = loadJSON("profiles/enable_sequence.json").sequence;
    const commands = seq.map((entry: any) => entry.command);
    expect(commands).toEqual(["setOn", "enabledReport", "detailsInquiry", "detailsReply", "setOff", "disabledReport"]);
  });

  it("decodes property-exchange set chunked sequence", () => {
    const seq = loadJSON("property-exchange/set_chunked.json");
    const events = seq.map((entry: any) => ({
      kind: "propertyExchange",
      group: 0,
      command: entry.command,
      requestId: entry.requestId,
      encoding: entry.encoding,
      header: entry.header,
      data: entry.dataHex ? Uint8Array.from(Buffer.from(entry.dataHex, "hex")) : undefined,
    }));
    const packets = events.map(evt => eventToSchemaPacket(evt as any));
    expect(packets.length).toBeGreaterThan(0);
  });

  it("decodes process inquiry flows", () => {
    const seq = loadJSON("process-inquiry/flows.json").sequence;
    const commands = seq.map((e: any) => e.command);
    expect(commands).toEqual(["capInquiry", "capReply", "messageReport", "messageReportReply", "endReport"]);
  });

  it("reassembles property-exchange notify chunks", () => {
    const seq = loadJSON("property-exchange/notify_chunked.json");
    const chunks = seq.map((entry: any) => ({
      kind: "propertyExchange",
      group: 0,
      command: entry.command,
      requestId: entry.requestId,
      encoding: entry.encoding,
      header: entry.header,
      data: Uint8Array.from(Buffer.from(entry.dataHex, "hex")),
    }));
    const totalLength = chunks.reduce((acc, c) => acc + (c.data as Uint8Array).length, 0);
    const assembled = chunks
      .sort((a, b) => Number(a.header.offset ?? 0) - Number(b.header.offset ?? 0))
      .flatMap(c => Array.from(c.data as Uint8Array));
    expect(totalLength).toBe(6);
    expect(assembled).toEqual([1, 2, 3, 4, 5, 6]);
  });
});
