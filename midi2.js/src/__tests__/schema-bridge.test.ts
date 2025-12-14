import { describe, expect, it } from "vitest";
import { isUmpPacket, isUmpPacket64, isUmpPacket128 } from "../generated/openapi-types";
import {
  decodeWordsToSchemaPacket,
  eventToSchemaPacket,
  eventToSchemaPacketWords,
  reassemblePeChunks,
  schemaPacketToEvent,
  schemaPacketToEventWithResponses,
  schemaPacketToWords,
} from "../schema-bridge";
import { PeSubscriptionManager } from "../pe-subscriptions";
import { decodeUmp, encodeUmp } from "../ump";
import {
  MidiCiEvent,
  FlexTempoEvent,
  Midi1ChannelVoiceEvent,
  Midi2NoteOnEvent,
  Midi2ProgramChangeEvent,
  MdsEvent,
  StreamEvent,
  SysEx7Event,
  SysEx8Event,
  ProfileEvent,
  PropertyExchangeEvent,
} from "../types";

const flattenWords = (packets: Uint32Array[]): Uint32Array => {
  if (packets.length === 1) return packets[0];
  const total = packets.reduce((sum, p) => sum + p.length, 0);
  const out = new Uint32Array(total);
  let offset = 0;
  for (const p of packets) {
    out.set(p, offset);
    offset += p.length;
  }
  return out;
};

describe("schema bridge", () => {
  it("converts midi2 note on events to schema packets and back", () => {
    const evt: Midi2NoteOnEvent = { kind: "noteOn", group: 0, channel: 1, note: 64, velocity: 0x1234 };
    const packet = eventToSchemaPacket(evt);
    expect(packet && isUmpPacket64(packet)).toBe(true);
    const words = schemaPacketToWords(packet!);
    expect(words).toEqual([encodeUmp(evt)]);
    const backToEvent = schemaPacketToEvent(packet!);
    expect(backToEvent).toMatchObject(evt);
    const fromWords = decodeWordsToSchemaPacket(words![0]);
    expect(fromWords && isUmpPacket64(fromWords)).toBe(true);
  });

  it("supports program change with bank select flags", () => {
    const evt: Midi2ProgramChangeEvent = {
      kind: "programChange",
      group: 0,
      channel: 2,
      program: 10,
      bankMsb: 1,
      bankLsb: 2,
    };
    const words = eventToSchemaPacketWords(evt);
    expect(words).toEqual([encodeUmp(evt)]);
    const decoded = decodeUmp(words![0]);
    expect(decoded).toMatchObject(evt);
  });

  it("supports midi1 channel voice packets via schema", () => {
    const evt: Midi1ChannelVoiceEvent = {
      kind: "midi1ChannelVoice",
      group: 1,
      status: 0x90,
      data1: 60,
      data2: 100,
    };
    const packet = eventToSchemaPacket(evt);
    expect(packet && isUmpPacket(packet)).toBe(true);
    const words = schemaPacketToWords(packet!);
    expect(words).toEqual([encodeUmp(evt)]);
    const roundtripEvent = schemaPacketToEvent(packet!);
    expect(roundtripEvent).toMatchObject(evt);
  });

  it("maps flex tempo to schema envelope", () => {
    const evt: FlexTempoEvent = { kind: "flexTempo", group: 0, bpm: 128.5 };
    const packet = eventToSchemaPacket(evt);
    expect(packet && isUmpPacket128(packet)).toBe(true);
    const words = schemaPacketToWords(packet!);
    const decoded = decodeUmp(words![0]);
    expect(decoded).toMatchObject(evt);
  });

  it("roundtrips SysEx7 via schema packets", () => {
    const evt: SysEx7Event = {
      kind: "sysex7",
      group: 2,
      manufacturerId: [0x7d],
      payload: Uint8Array.from([1, 2, 3, 4, 5, 6, 7, 8]),
    };
    const packet = eventToSchemaPacket(evt);
    expect(packet && isUmpPacket(packet)).toBe(true);
    const words = schemaPacketToWords(packet!);
    expect(words && words.length).toBeGreaterThan(1);
    const backToEvent = schemaPacketToEvent(packet!);
    expect(backToEvent).toMatchObject({ kind: "sysex7", manufacturerId: [0x7d] });
  });

  it("roundtrips SysEx8 via schema packets", () => {
    const evt: SysEx8Event = {
      kind: "sysex8",
      group: 1,
      manufacturerId: [0x00, 0x20, 0x33],
      payload: Uint8Array.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
    };
    const packet = eventToSchemaPacket(evt);
    expect(packet && isUmpPacket128(packet)).toBe(true);
    const words = schemaPacketToWords(packet!);
    expect(words && words.length).toBe(1);
    const decoded = schemaPacketToEvent(packet!);
    expect(decoded).toMatchObject({ kind: "sysex8", manufacturerId: [0x00, 0x20, 0x33] });
  });

  it("encodes/decodes MDS chunk via schema", () => {
    const mds: MdsEvent = {
      kind: "mds",
      group: 2,
      messageId: 7,
      totalChunks: 1,
      chunks: [{ messageId: 7, totalChunks: 1, index: 0, validByteCount: 5, payload: Uint8Array.from([1, 2, 3, 4, 5]) }],
    };
    const packet = eventToSchemaPacket(mds);
    expect(packet && isUmpPacket128(packet)).toBe(true);
    const evt = schemaPacketToEvent(packet!);
    expect(evt).toMatchObject({ kind: "mds", messageId: 7, totalChunks: 1 });
    const words = schemaPacketToWords(packet!);
    const flat = flattenWords(words ?? []);
    const decoded = decodeUmp(flat) as MdsEvent;
    expect(decoded.kind).toBe("mds");
    expect(decoded.chunks[0].validByteCount).toBe(5);
    expect(Array.from(decoded.chunks[0].payload)).toEqual([1, 2, 3, 4, 5]);
  });

  it("supports MIDI-CI envelope mapping (sysex8)", () => {
    const env: MidiCiEvent = {
      kind: "midiCi",
      group: 0,
      scope: "nonRealtime",
      subId2: 0x7c,
      version: 1,
      payload: Uint8Array.from([0x01, 0x02, 0x03]),
      format: "sysex8",
    };
    const packet = eventToSchemaPacket(env);
    expect(packet && isUmpPacket(packet)).toBe(true);
    const evt = schemaPacketToEvent(packet!);
    expect(evt?.kind).toBe("midiCi");
  });

  it("encodes/decodes profile command via MIDI-CI", () => {
    const profile: ProfileEvent = {
      kind: "profile",
      group: 0,
      command: "inquiry",
      profileId: "com.fountain.test.profile",
      target: "group",
      channels: [1, 2],
      details: { version: 1 },
    };
    const packet = eventToSchemaPacket(profile);
    expect(packet).toBeTruthy();
    const evt = schemaPacketToEvent(packet!);
    expect(evt?.kind).toBe("profile");
  });

  it("encodes/decodes property exchange notify via MIDI-CI", () => {
    const pe: PropertyExchangeEvent = {
      kind: "propertyExchange",
      group: 1,
      command: "notify",
      requestId: 42,
      header: { resource: "/test" },
      data: { hello: "world" },
      ack: { ack: true, statusCode: 0, message: "ok" },
    };
    const packet = eventToSchemaPacket(pe);
    expect(packet).toBeTruthy();
    const evt = schemaPacketToEvent(packet!);
    expect(evt?.kind === "propertyExchange" || evt?.kind === "midiCi").toBe(true);
  });

  it("encodes/decodes profile enable/disable commands", () => {
    const enable: ProfileEvent = {
      kind: "profile",
      group: 0,
      command: "setOn",
      profileId: "com.fountain.test.profile",
      target: "channel",
      channels: [0],
    };
    const disable: ProfileEvent = { ...enable, command: "setOff" };
    const enablePacket = eventToSchemaPacket(enable);
    const disablePacket = eventToSchemaPacket(disable);
    expect(schemaPacketToEvent(enablePacket!)?.kind).toBe("profile");
    expect(schemaPacketToEvent(disablePacket!)?.kind).toBe("profile");
  });

  it("encodes/decodes property exchange setReply with ack", () => {
    const pe: PropertyExchangeEvent = {
      kind: "propertyExchange",
      group: 2,
      command: "setReply",
      requestId: 7,
      header: { resource: "/foo", mediaType: "application/json" },
      data: { status: "ok" },
      ack: { ack: true, statusCode: 0, message: "ok" },
    };
    const packet = eventToSchemaPacket(pe);
    const evt = schemaPacketToEvent(packet!);
    expect(evt?.kind).toBe("propertyExchange");
  });

  it("drops unsupported PE header keys and invalid status codes", () => {
    const pe: PropertyExchangeEvent = {
      kind: "propertyExchange",
      group: 0,
      command: "notify",
      requestId: 1,
      header: { resource: "/foo", schema: "bad", status: 9999 } as any,
      data: Uint8Array.from([1, 2, 3]),
    };
    const evt = schemaPacketToEvent(eventToSchemaPacket(pe)!);
    expect(evt?.kind).toBe("propertyExchange");
    expect((evt as PropertyExchangeEvent).header).toEqual({ resource: "/foo" });
  });

  it("enforces flowControl boolean and valid status codes", () => {
    const pe: PropertyExchangeEvent = {
      kind: "propertyExchange",
      group: 0,
      command: "notify",
      requestId: 2,
      header: { resource: "/bar", flowControl: "yes" as any, status: 500 },
      data: Uint8Array.from([1]),
    };
    const evt = schemaPacketToEvent(eventToSchemaPacket(pe)!);
    expect(evt?.kind).toBe("propertyExchange");
    expect((evt as PropertyExchangeEvent).header).toEqual({ resource: "/bar", flowControl: true, status: 500 });
  });

  it("falls back to notify when PE command is invalid", () => {
    const badPayload = new TextEncoder().encode(JSON.stringify({ command: "bogus", data: "0x0102" }));
    const env: MidiCiEvent = { kind: "midiCi", group: 0, scope: "nonRealtime", subId2: 0x21, version: 1, payload: badPayload, format: "sysex7" };
    const evt = schemaPacketToEvent(eventToSchemaPacket(env)!);
    expect(evt?.kind).toBe("propertyExchange");
    expect((evt as any).command).toBe("notify");
  });

  it("downgrades PE with missing requestId", () => {
    const env: MidiCiEvent = {
      kind: "midiCi",
      group: 0,
      scope: "nonRealtime",
      subId2: 0x21,
      version: 1,
      payload: new TextEncoder().encode(JSON.stringify({ command: "set", encoding: "json", data: {} })),
      format: "sysex7",
    };
    const evt = schemaPacketToEvent(eventToSchemaPacket(env)!);
    expect(evt?.kind).toBe("propertyExchange");
    expect((evt as any).command).toBe("notify");
  });

  it("downgrades PE with invalid encoding", () => {
    const payload = new TextEncoder().encode(JSON.stringify({ command: "set", requestId: 1, encoding: "bogus", data: {} }));
    const env: MidiCiEvent = { kind: "midiCi", group: 0, scope: "nonRealtime", subId2: 0x21, version: 1, payload, format: "sysex7" };
    const evt = schemaPacketToEvent(eventToSchemaPacket(env)!);
    expect(evt?.kind).toBe("propertyExchange");
    expect((evt as any).command).toBe("notify");
  });

  it("downgrades PE when payload fails schema validation", () => {
    const payload = new TextEncoder().encode(JSON.stringify({ command: "set", requestId: "not-a-number", header: "bad", data: {} }));
    const env: MidiCiEvent = { kind: "midiCi", group: 0, scope: "nonRealtime", subId2: 0x21, version: 1, payload, format: "sysex7" };
    const evt = schemaPacketToEvent(eventToSchemaPacket(env)!);
    expect(evt?.kind).toBe("propertyExchange");
    expect((evt as any).command).toBe("notify");
  });

  it("routes property exchange subscribe through the subscription manager helper", () => {
    const mgr = new PeSubscriptionManager({ supportsFlowControl: true });
    const pe: PropertyExchangeEvent = {
      kind: "propertyExchange",
      group: 0,
      command: "subscribe",
      requestId: 9,
      subscriptionId: "sub-pe",
      header: { flowControl: true },
    };
    const packet = eventToSchemaPacket(pe);
    const { event, outboundEvents, outboundWords } = schemaPacketToEventWithResponses(packet!, { peSubscriptionManager: mgr });
    expect(event?.kind).toBe("propertyExchange");
    expect(outboundEvents[0]).toMatchObject({ command: "subscribeReply", header: { status: 200, flowControl: true } });
    expect(outboundWords.length).toBeGreaterThan(0);
  });

  it("propagates flow-control rejection when unsupported", () => {
    const mgr = new PeSubscriptionManager({ supportsFlowControl: false });
    const pe: PropertyExchangeEvent = {
      kind: "propertyExchange",
      group: 0,
      command: "subscribe",
      requestId: 10,
      subscriptionId: "flow",
      header: { flowControl: true },
    };
    const { outboundEvents } = schemaPacketToEventWithResponses(eventToSchemaPacket(pe)!, { peSubscriptionManager: mgr });
    expect(outboundEvents[0]?.header?.status).toBe(406);
  });

  it("returns null when PE notify chunks repeat offsets", () => {
    const chunkA: PropertyExchangeEvent = {
      kind: "propertyExchange",
      group: 0,
      command: "notify",
      requestId: 1,
      subscriptionId: "sub-pe",
      header: { offset: 0, length: 3 },
      data: new Uint8Array([1, 2, 3]),
    };
    const chunkB: PropertyExchangeEvent = {
      ...chunkA,
      data: new Uint8Array([4, 5, 6]),
    };
    const merged = reassemblePeChunks([chunkA, chunkB]);
    expect(merged).toBeNull();
  });

  it("downgrades profile with missing profileId", () => {
    const payload = new TextEncoder().encode(JSON.stringify({ command: "setOn", target: "channel", channels: [0] }));
    const env: MidiCiEvent = { kind: "midiCi", group: 0, scope: "nonRealtime", subId2: 0x20, version: 1, payload, format: "sysex7" };
    const evt = schemaPacketToEvent(eventToSchemaPacket(env)!);
    expect(evt?.kind).toBe("profile");
    expect((evt as any).command).toBe("reply");
  });

  it("parses profile added/removed reports", () => {
    const payload = new TextEncoder().encode(JSON.stringify({ command: "addedReport", profileId: "/org.midi/piano" }));
    const env: MidiCiEvent = { kind: "midiCi", group: 0, scope: "nonRealtime", subId2: 0x20, version: 1, payload, format: "sysex7" };
    const added = schemaPacketToEvent(eventToSchemaPacket(env)!);
    expect(added).toMatchObject({ kind: "profile", command: "addedReport", profileId: "/org.midi/piano" });

    const remPayload = new TextEncoder().encode(JSON.stringify({ command: "removedReport", profileId: "/org.midi/piano" }));
    const remEnv: MidiCiEvent = { ...env, payload: remPayload };
    const removed = schemaPacketToEvent(eventToSchemaPacket(remEnv)!);
    expect(removed).toMatchObject({ kind: "profile", command: "removedReport", profileId: "/org.midi/piano" });
  });

  it("parses profile detailsReply", () => {
    const payload = new TextEncoder().encode(JSON.stringify({ command: "detailsReply", profileId: "/org.midi/piano", details: { ver: 1, cmL: 5 } }));
    const env: MidiCiEvent = { kind: "midiCi", group: 0, scope: "nonRealtime", subId2: 0x20, version: 1, payload, format: "sysex7" };
    const evt = schemaPacketToEvent(eventToSchemaPacket(env)!);
    expect(evt).toMatchObject({ kind: "profile", command: "detailsReply", profileId: "/org.midi/piano", details: { ver: 1, cmL: 5 } });
  });

  it("falls back to endReport when process inquiry command is invalid", () => {
    const badPi = new TextEncoder().encode(JSON.stringify({ command: "bogus" }));
    const env: MidiCiEvent = { kind: "midiCi", group: 0, scope: "nonRealtime", subId2: 0x22, version: 1, payload: badPi, format: "sysex7" };
    const evt = schemaPacketToEvent(eventToSchemaPacket(env)!);
    expect(evt?.kind).toBe("processInquiry");
    expect((evt as any).command).toBe("endReport");
  });

  it("treats stream/profile/property-exchange packets as raw when unsupported", () => {
    const streamEvt: StreamEvent = {
      kind: "stream",
      group: 0,
      opcode: "endpointDiscovery",
      endpointDiscovery: { majorVersion: 1, minorVersion: 0, maxGroups: 1 },
    };
    const packet = eventToSchemaPacket(streamEvt);
    expect(packet).toBeTruthy();
    const evt = schemaPacketToEvent(packet!);
    expect(evt).toMatchObject({ kind: "stream", opcode: "endpointDiscovery" });
  });

  it("roundtrips stream device identity and endpoint name via schema", () => {
    const identity: StreamEvent = {
      kind: "stream",
      group: 1,
      opcode: "deviceIdentityNotification",
      deviceIdentityNotification: { manufacturerId: [0x7d], deviceFamily: 0x1234, deviceModel: 0x4567, softwareRevision: 0x01020304 },
    };
    const words = eventToSchemaPacketWords(identity)!;
    const flat = flattenWords(words);
    expect(flat[1]).toBe(0x7d000012);
    expect(flat[2]).toBe(0x34456701);
    expect(flat[3]).toBe(0x02030400);
    const decoded = decodeUmp(flattenWords(words));
    expect(decoded?.kind).toBe("stream");

    const nameEvt: StreamEvent = { kind: "stream", group: 1, opcode: "endpointNameNotification", endpointNameNotification: { name: "SchemaBridge" } };
    const namePkt = eventToSchemaPacket(nameEvt);
    const nameWords = schemaPacketToWords(namePkt!)!;
    const decodedName = decodeUmp(flattenWords(nameWords));
    expect(decodedName).toMatchObject(nameEvt);
  });
});
