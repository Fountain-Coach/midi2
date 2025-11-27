import { describe, expect, it } from "vitest";
import { isUmpPacket } from "../generated/openapi-types";
import { decodeWordsToSchemaPacket, eventToSchemaPacket, eventToSchemaPacketWords, schemaPacketToEvent, schemaPacketToWords } from "../schema-bridge";
import { decodeUmp, encodeUmp } from "../ump";
import {
  MidiCiEvent,
  FlexTempoEvent,
  Midi1ChannelVoiceEvent,
  Midi2NoteOnEvent,
  Midi2ProgramChangeEvent,
  SysEx7Event,
  SysEx8Event,
} from "../types";

describe("schema bridge", () => {
  it("converts midi2 note on events to schema packets and back", () => {
    const evt: Midi2NoteOnEvent = { kind: "noteOn", group: 0, channel: 1, note: 64, velocity: 0x1234 };
    const packet = eventToSchemaPacket(evt);
    expect(packet && isUmpPacket(packet)).toBe(true);
    const words = schemaPacketToWords(packet!);
    expect(words).toEqual([encodeUmp(evt)]);
    const backToEvent = schemaPacketToEvent(packet!);
    expect(backToEvent).toMatchObject(evt);
    const fromWords = decodeWordsToSchemaPacket(words![0]);
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
    expect(packet && isUmpPacket(packet)).toBe(true);
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
    expect(packet && isUmpPacket(packet)).toBe(true);
    const words = schemaPacketToWords(packet!);
    expect(words && words.length).toBe(1);
    const decoded = schemaPacketToEvent(packet!);
    expect(decoded).toMatchObject({ kind: "sysex8", manufacturerId: [0x00, 0x20, 0x33] });
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
    expect(evt?.kind).toBe("sysex8");
  });
});
