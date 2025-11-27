import { describe, expect, it } from "vitest";
import { isUmpPacket } from "../generated/openapi-types";
import {
  decodeWordsToSchemaPacket,
  eventToSchemaPacket,
  eventToSchemaPacketWords,
  schemaPacketToEvent,
  schemaPacketToWords,
} from "../schema-bridge";
import { decodeUmp, encodeUmp } from "../ump";
import {
  FlexTempoEvent,
  Midi1ChannelVoiceEvent,
  Midi2NoteOnEvent,
  Midi2ProgramChangeEvent,
} from "../types";

describe("schema bridge", () => {
  it("converts midi2 note on events to schema packets and back", () => {
    const evt: Midi2NoteOnEvent = { kind: "noteOn", group: 0, channel: 1, note: 64, velocity: 0x1234 };
    const packet = eventToSchemaPacket(evt);
    expect(packet && isUmpPacket(packet)).toBe(true);
    const words = schemaPacketToWords(packet!);
    expect(words).toEqual(encodeUmp(evt));
    const backToEvent = schemaPacketToEvent(packet!);
    expect(backToEvent).toMatchObject(evt);
    const fromWords = decodeWordsToSchemaPacket(words!);
    expect(fromWords && isUmpPacket(fromWords)).toBe(true);
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
    expect(words).toEqual(encodeUmp(evt));
    const decoded = decodeUmp(words!);
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
    expect(words).toEqual(encodeUmp(evt));
    const roundtripEvent = schemaPacketToEvent(packet!);
    expect(roundtripEvent).toMatchObject(evt);
  });

  it("maps flex tempo to schema envelope", () => {
    const evt: FlexTempoEvent = { kind: "flexTempo", group: 0, bpm: 128.5 };
    const packet = eventToSchemaPacket(evt);
    expect(packet && isUmpPacket(packet)).toBe(true);
    const words = schemaPacketToWords(packet!);
    const decoded = decodeUmp(words!);
    expect(decoded).toMatchObject(evt);
  });
});
