import {
  Flex_Lyric,
  Flex_Tempo,
  Flex_KeySignature,
  Flex_TimeSignature,
  UmpPacket,
  UmpPacket32,
  UmpPacket64,
  UmpPacket128,
  isUmpPacket,
} from "./generated/openapi-types";
import {
  MidiCiEvent,
  SysEx7Event,
  SysEx8Event,
  Midi1ChannelVoiceEvent,
  Midi2ChannelPressureEvent,
  Midi2ControlChangeEvent,
  Midi2Event,
  Midi2NoteOffEvent,
  Midi2NoteOnEvent,
  Midi2NrpnEvent,
  Midi2NrpnRelativeEvent,
  Midi2PerNoteAssignableControllerEvent,
  Midi2PerNoteManagementEvent,
  Midi2PerNoteRegisteredControllerEvent,
  Midi2PitchBendEvent,
  Midi2PolyPressureEvent,
  Midi2ProgramChangeEvent,
  Midi2RpnEvent,
  Midi2RpnRelativeEvent,
  Midi2SystemEvent,
  UtilityEvent,
  FlexTempoEvent,
  FlexTimeSignatureEvent,
  FlexKeySignatureEvent,
  FlexLyricEvent,
} from "./types";
import { encodeUmp, decodeUmp } from "./ump";
import { fragmentSysEx7, fragmentSysEx8 } from "./sysex";

type ScopeAddress = { scope: "group"; group: number } | { scope: "channel"; channel: number };

function toAddress(group: number, channel?: number): ScopeAddress | undefined {
  if (channel === undefined) return { scope: "group", group };
  return { scope: "channel", channel };
}

function asUmpPacket64(event: Midi2Event): UmpPacket64 | null {
  switch (event.kind) {
    case "sysex7":
    case "sysex8":
    case "midiCi":
      return null; // handled in 32/128-bit paths
    case "noteOn": {
      const body: Midi2NoteOnEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 9,
        channel: body.channel,
        body: {
          statusNibble: 9,
          channel: body.channel,
          body: {
            noteNumber: body.note,
            velocity16: body.velocity,
            attributeType: body.attributeType ?? 0,
            attributeData16: body.attributeData ?? 0,
          },
        },
      };
    }
    case "noteOff": {
      const body: Midi2NoteOffEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 8,
        channel: body.channel,
        body: {
          statusNibble: 8,
          channel: body.channel,
          body: {
            noteNumber: body.note,
            velocity16: body.velocity ?? 0,
            attributeType: body.attributeType ?? 0,
            attributeData16: body.attributeData ?? 0,
          },
        },
      };
    }
    case "polyPressure": {
      const body: Midi2PolyPressureEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 10,
        channel: body.channel,
        body: {
          statusNibble: 10,
          channel: body.channel,
          body: {
            noteNumber: body.note,
            polyPressure32: body.pressure,
          },
        },
      };
    }
    case "controlChange": {
      const body: Midi2ControlChangeEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 11,
        channel: body.channel,
        body: {
          statusNibble: 11,
          channel: body.channel,
          body: {
            control: body.controller,
            controlValue32: body.value,
          },
        },
      };
    }
    case "programChange": {
      const body: Midi2ProgramChangeEvent = event;
      const bankValid = body.bankLsb !== undefined || body.bankMsb !== undefined;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 12,
        channel: body.channel,
        body: {
          statusNibble: 12,
          channel: body.channel,
          body: {
            program: body.program,
            bankMsb: body.bankMsb,
            bankLsb: body.bankLsb,
            bankValid,
          },
        },
      };
    }
    case "channelPressure": {
      const body: Midi2ChannelPressureEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 13,
        channel: body.channel,
        body: {
          statusNibble: 13,
          channel: body.channel,
          body: {
            channelPressure32: body.pressure,
          },
        },
      };
    }
    case "pitchBend": {
      const body: Midi2PitchBendEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 14,
        channel: body.channel,
        body: {
          statusNibble: 14,
          channel: body.channel,
          body: {
            pitchBend32: body.value,
          },
        },
      };
    }
    case "rpn": {
      const body: Midi2RpnEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 15,
        channel: body.channel,
        body: {
          statusNibble: 15,
          channel: body.channel,
          body: {
            rpnIndexMsb: body.bank,
            rpnIndexLsb: body.index,
            rpnData32: body.value,
          },
        },
      };
    }
    case "nrpn": {
      const body: Midi2NrpnEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 15,
        channel: body.channel,
        body: {
          statusNibble: 15,
          channel: body.channel,
          body: {
            nrpnIndexMsb: body.bank,
            nrpnIndexLsb: body.index,
            nrpnData32: body.value,
          },
        },
      };
    }
    case "rpnRelative": {
      const body: Midi2RpnRelativeEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 15,
        channel: body.channel,
        body: {
          statusNibble: 15,
          channel: body.channel,
          body: {
            rpnIndexMsb: body.bank,
            rpnIndexLsb: body.index,
            rpnDelta32: body.delta,
          },
        },
      };
    }
    case "nrpnRelative": {
      const body: Midi2NrpnRelativeEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 15,
        channel: body.channel,
        body: {
          statusNibble: 15,
          channel: body.channel,
          body: {
            nrpnIndexMsb: body.bank,
            nrpnIndexLsb: body.index,
            nrpnDelta32: body.delta,
          },
        },
      };
    }
    case "perNoteManagement": {
      const body: Midi2PerNoteManagementEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 15,
        channel: body.channel,
        body: {
          statusNibble: 15,
          channel: body.channel,
          body: {
            perNoteMgmt: {
              noteNumber: body.note,
              detach: body.detach,
              reset: body.reset,
            },
          },
        },
      };
    }
    case "perNoteRegisteredController": {
      const body: Midi2PerNoteRegisteredControllerEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 15,
        channel: body.channel,
        body: {
          statusNibble: 15,
          channel: body.channel,
          body: {
            noteNumber: body.note,
            regPerNoteCtrlIndex: body.controller,
            regPerNoteCtrlValue32: body.value,
          },
        },
      };
    }
    case "perNoteAssignableController": {
      const body: Midi2PerNoteAssignableControllerEvent = event;
      return {
        messageType: 4,
        group: body.group,
        statusNibble: 15,
        channel: body.channel,
        body: {
          statusNibble: 15,
          channel: body.channel,
          body: {
            noteNumber: body.note,
            assignPerNoteCtrlIndex: body.controller,
            assignPerNoteCtrlValue32: body.value,
          },
        },
      };
    }
    default:
      return null;
  }
}

function asUmpPacket128(event: Midi2Event): UmpPacket128 | null {
  switch (event.kind) {
    case "sysex8": {
      const syx: SysEx8Event = event;
      const body: UmpPacket128["body"] = {
        kind: "sysex8",
        sysex8: {
          manufacturerId: syx.manufacturerId,
          length: syx.payload.length,
          data: Array.from(syx.payload),
        },
      };
      return { messageType: 5, group: syx.group, body };
    }
    case "midiCi": {
      if (event.format !== "sysex8") return null;
      const scope = event.scope === "realtime" ? 0x7f : 0x7e;
      const header = [scope, 0x0d, event.subId2, event.version];
      const syx: SysEx8Event = {
        kind: "sysex8",
        group: event.group,
        manufacturerId: [scope],
        payload: Uint8Array.from([...header, ...event.payload]),
      };
      return asUmpPacket128(syx);
    }
    case "flexTempo": {
      const flex: FlexTempoEvent = event;
      const body: Flex_Tempo = {
        statusClass: 16,
        status: 1,
        address: toAddress(flex.group, flex.channel),
        data: { bpm: flex.bpm },
      };
      return { messageType: 13, group: flex.group, body };
    }
    case "flexTimeSignature": {
      const flex: FlexTimeSignatureEvent = event;
      const body: Flex_TimeSignature = {
        statusClass: 16,
        status: 2,
        address: toAddress(flex.group, flex.channel),
        data: { numerator: flex.numerator, denominatorPow2: flex.denominatorPow2 },
      };
      return { messageType: 13, group: flex.group, body };
    }
    case "flexKeySignature": {
      const flex: FlexKeySignatureEvent = event;
      const body: Flex_KeySignature = {
        statusClass: 16,
        status: 4,
        address: toAddress(flex.group, flex.channel),
        data: { key: flex.key },
      };
      return { messageType: 13, group: flex.group, body };
    }
    case "flexLyric": {
      const flex: FlexLyricEvent = event;
      const body: Flex_Lyric = {
        statusClass: 17,
        status: 2,
        address: toAddress(flex.group, flex.channel),
        data: { lyric: flex.text },
      };
      return { messageType: 13, group: flex.group, body };
    }
    default:
      return null;
  }
}

function asUmpPacket32(event: Midi2Event): UmpPacket32 | null {
  switch (event.kind) {
    case "sysex7": {
      const syx: SysEx7Event = event;
      const packets = sysex7ToPackets(Array.from(syx.payload));
      return { messageType: 3, group: syx.group, body: { manufacturerId: syx.manufacturerId, packets } };
    }
    case "midiCi": {
      if (event.format === "sysex8") return null;
      const scope = event.scope === "realtime" ? 0x7f : 0x7e;
      const header = [scope, 0x0d, event.subId2 & 0x7f, event.version & 0x7f];
      const syx: SysEx7Event = {
        kind: "sysex7",
        group: event.group,
        manufacturerId: [scope],
        payload: Uint8Array.from([...header, ...event.payload]),
      };
      return asUmpPacket32(syx);
    }
    case "utility": {
      const utility: UtilityEvent = event;
      const opcode = utility.status === "jrClock" ? 1 : utility.status === "jrTimestamp" ? 2 : 0;
      const body: UmpPacket32["body"] = {
        opcode,
        jrClock: utility.status === "jrClock" ? { timestamp32: utility.value ?? 0 } : undefined,
        jrTimestamp: utility.status === "jrTimestamp" ? { time15: utility.value ?? 0 } : undefined,
      };
      return { messageType: 0, group: 0, body };
    }
    case "system": {
      const sys: Midi2SystemEvent = event;
      const body: UmpPacket32["body"] = {
        status: sys.status,
        data1: sys.data1,
        data2: sys.data2,
      };
      return { messageType: 1, group: sys.group, body };
    }
    case "midi1ChannelVoice": {
      const m1: Midi1ChannelVoiceEvent = event;
      const statusNibble = (m1.status >> 4) & 0xf;
      const channel = m1.status & 0xf;
      const body: UmpPacket32["body"] = {
        statusNibble: statusNibble as UmpPacket32["body"]["statusNibble"],
        channel,
      };
      if (statusNibble === 8 || statusNibble === 9) {
        body.noteNumber = m1.data1 ?? 0;
        body.velocity7 = m1.data2 ?? 0;
      } else if (statusNibble === 10) {
        body.noteNumber = m1.data1 ?? 0;
        body.pressure7 = m1.data2 ?? 0;
      } else if (statusNibble === 11) {
        body.control = m1.data1 ?? 0;
        body.value7 = m1.data2 ?? 0;
      } else if (statusNibble === 12) {
        body.program = m1.data1 ?? 0;
      } else if (statusNibble === 13) {
        body.pressure7 = m1.data1 ?? 0;
      } else if (statusNibble === 14) {
        const lsb = m1.data1 ?? 0;
        const msb = m1.data2 ?? 0;
        body.pitchBend14 = (msb << 7) | lsb;
      }
      return { messageType: 2, group: m1.group, body };
    }
    default:
      return null;
  }
}

export function eventToSchemaPacket(event: Midi2Event): UmpPacket | null {
  return (asUmpPacket64(event) as UmpPacket | null) ?? (asUmpPacket128(event) as UmpPacket | null) ?? (asUmpPacket32(event) as UmpPacket | null);
}

export function schemaPacketToEvent(packet: unknown): Midi2Event | null {
  if (!isUmpPacket(packet)) {
    if (typeof packet === "object" && packet && ("messageType" in packet)) {
      const mt = (packet as any).messageType;
      if (mt === 3 || mt === 15) {
        const words = packGeneric32(packet as any);
        return { kind: "rawUMP", words, timestamp: undefined };
      }
    }
    return null;
  }
  if (packet.messageType === 3) {
    const p = packet as UmpPacket32;
    const body: any = p.body;
    if (body?.manufacturerId && body?.packets) {
      const { manufacturerId, payload } = reassembleSysEx7FromPackets(body.manufacturerId ?? [], body.packets);
      return {
        kind: "sysex7",
        group: p.group ?? 0,
        manufacturerId,
        payload: Uint8Array.from(payload),
      };
    }
    const words = packGeneric32(p);
    return { kind: "rawUMP", words, timestamp: undefined };
  }
  if (packet.messageType === 15) {
    // Data messages (MDS/SysEx8 in schema) are already handled in MT=5 for sysex8; treat the rest as raw UMP for now.
    const words = packGeneric32(packet as UmpPacket32);
    return { kind: "rawUMP", words, timestamp: undefined };
  }
  if (packet.messageType === 4) {
    const body = (packet as UmpPacket64).body;
    const status = body?.statusNibble;
    const channel = body?.channel;
    const cv = (body as any)?.body ?? {};
    switch (status) {
      case 8:
        return {
          kind: "noteOff",
          group: (packet as UmpPacket64).group ?? 0,
          channel: channel ?? 0,
          note: cv.noteNumber ?? 0,
          velocity: cv.velocity16 ?? 0,
          attributeType: cv.attributeType,
          attributeData: cv.attributeData16,
        };
      case 9:
        return {
          kind: "noteOn",
          group: (packet as UmpPacket64).group ?? 0,
          channel: channel ?? 0,
          note: cv.noteNumber ?? 0,
          velocity: cv.velocity16 ?? 0,
          attributeType: cv.attributeType,
          attributeData: cv.attributeData16,
        };
      case 10:
        return {
          kind: "polyPressure",
          group: (packet as UmpPacket64).group ?? 0,
          channel: channel ?? 0,
          note: cv.noteNumber ?? 0,
          pressure: cv.polyPressure32 ?? 0,
        };
      case 11:
        return {
          kind: "controlChange",
          group: (packet as UmpPacket64).group ?? 0,
          channel: channel ?? 0,
          controller: cv.control ?? 0,
          value: cv.controlValue32 ?? 0,
        };
      case 12:
        return {
          kind: "programChange",
          group: (packet as UmpPacket64).group ?? 0,
          channel: channel ?? 0,
          program: cv.program ?? 0,
          bankMsb: cv.bankMsb,
          bankLsb: cv.bankLsb,
        };
      case 13:
        return {
          kind: "channelPressure",
          group: (packet as UmpPacket64).group ?? 0,
          channel: channel ?? 0,
          pressure: cv.channelPressure32 ?? 0,
        };
      case 14:
        return {
          kind: "pitchBend",
          group: (packet as UmpPacket64).group ?? 0,
          channel: channel ?? 0,
          value: cv.pitchBend32 ?? 0,
        };
      case 15: {
        if (cv.rpnIndexMsb !== undefined && cv.rpnIndexLsb !== undefined && cv.rpnData32 !== undefined) {
          return {
            kind: "rpn",
            group: (packet as UmpPacket64).group ?? 0,
            channel: channel ?? 0,
            bank: cv.rpnIndexMsb,
            index: cv.rpnIndexLsb,
            value: cv.rpnData32,
          };
        }
        if (cv.nrpnIndexMsb !== undefined && cv.nrpnIndexLsb !== undefined && cv.nrpnData32 !== undefined) {
          return {
            kind: "nrpn",
            group: (packet as UmpPacket64).group ?? 0,
            channel: channel ?? 0,
            bank: cv.nrpnIndexMsb,
            index: cv.nrpnIndexLsb,
            value: cv.nrpnData32,
          };
        }
        if (cv.rpnIndexMsb !== undefined && cv.rpnIndexLsb !== undefined && cv.rpnDelta32 !== undefined) {
          return {
            kind: "rpnRelative",
            group: (packet as UmpPacket64).group ?? 0,
            channel: channel ?? 0,
            bank: cv.rpnIndexMsb,
            index: cv.rpnIndexLsb,
            delta: cv.rpnDelta32,
          };
        }
        if (cv.nrpnIndexMsb !== undefined && cv.nrpnIndexLsb !== undefined && cv.nrpnDelta32 !== undefined) {
          return {
            kind: "nrpnRelative",
            group: (packet as UmpPacket64).group ?? 0,
            channel: channel ?? 0,
            bank: cv.nrpnIndexMsb,
            index: cv.nrpnIndexLsb,
            delta: cv.nrpnDelta32,
          };
        }
        if (cv.perNoteMgmt) {
          const mgmt = cv.perNoteMgmt;
          return {
            kind: "perNoteManagement",
            group: (packet as UmpPacket64).group ?? 0,
            channel: channel ?? 0,
            note: mgmt.noteNumber ?? 0,
            detach: Boolean(mgmt.detach),
            reset: Boolean(mgmt.reset),
          };
        }
        if (cv.regPerNoteCtrlIndex !== undefined && cv.regPerNoteCtrlValue32 !== undefined) {
          return {
            kind: "perNoteRegisteredController",
            group: (packet as UmpPacket64).group ?? 0,
            channel: channel ?? 0,
            note: cv.noteNumber ?? 0,
            controller: cv.regPerNoteCtrlIndex,
            value: cv.regPerNoteCtrlValue32,
          };
        }
        if (cv.assignPerNoteCtrlIndex !== undefined && cv.assignPerNoteCtrlValue32 !== undefined) {
          return {
            kind: "perNoteAssignableController",
            group: (packet as UmpPacket64).group ?? 0,
            channel: channel ?? 0,
            note: cv.noteNumber ?? 0,
            controller: cv.assignPerNoteCtrlIndex,
            value: cv.assignPerNoteCtrlValue32,
          };
        }
        return null;
      }
      default:
        return null;
    }
  }
  if (packet.messageType === 13) {
    const p = packet as UmpPacket128;
    const body: any = p.body;
    const channel = body.address?.scope === "channel" ? body.address.channel : undefined;
    switch (`${body.statusClass}-${body.status}`) {
      case "16-1":
        return { kind: "flexTempo", group: p.group ?? 0, channel, bpm: body.data?.bpm ?? 0 };
      case "16-2":
        return { kind: "flexTimeSignature", group: p.group ?? 0, channel, numerator: body.data?.numerator ?? 0, denominatorPow2: body.data?.denominatorPow2 ?? 0 };
      case "16-4":
        return { kind: "flexKeySignature", group: p.group ?? 0, channel, key: body.data?.key ?? "" };
      case "17-2":
        return { kind: "flexLyric", group: p.group ?? 0, channel, text: body.data?.lyric ?? "" };
      default:
        return null;
    }
  }
  if (packet.messageType === 5) {
    const p = packet as UmpPacket128;
    const body: any = p.body;
    if (body.kind === "sysex8" && body.sysex8) {
      return {
        kind: "sysex8",
        group: p.group ?? 0,
        manufacturerId: body.sysex8.manufacturerId ?? [],
        payload: Uint8Array.from(body.sysex8.data ?? []),
      };
    }
    return null;
  }
  if (packet.messageType === 3) {
    const words = packGeneric32(packet as UmpPacket32);
    return { kind: "rawUMP", words, timestamp: undefined };
  }
  if (packet.messageType === 1) {
    const sys = (packet as UmpPacket32).body as any;
    return {
      kind: "system",
      group: (packet as UmpPacket32).group ?? 0,
      status: sys.status,
      data1: sys.data1,
      data2: sys.data2,
    };
  }
  if (packet.messageType === 2) {
    const body = (packet as UmpPacket32).body as any;
    const status = ((body.statusNibble ?? 0) << 4) | (body.channel ?? 0);
    const event: Midi1ChannelVoiceEvent = {
      kind: "midi1ChannelVoice",
      group: (packet as UmpPacket32).group ?? 0,
      status,
    };
    if ("noteNumber" in body) event.data1 = body.noteNumber;
    if ("velocity7" in body) event.data2 = body.velocity7;
    if ("pressure7" in body && body.statusNibble === 10) event.data2 = body.pressure7;
    if ("control" in body) event.data1 = body.control;
    if ("value7" in body) event.data2 = body.value7;
    if ("program" in body) event.data1 = body.program;
    if ("pressure7" in body && body.statusNibble === 13) event.data1 = body.pressure7;
    if ("pitchBend14" in body) {
      const val = body.pitchBend14 ?? 0;
      event.data1 = val & 0x7f;
      event.data2 = (val >> 7) & 0x7f;
    }
    return event;
  }
  if (packet.messageType === 0) {
    const body = (packet as UmpPacket32).body as any;
    const opcode = body.opcode ?? 0;
    const status: UtilityEvent["status"] = opcode === 1 ? "jrClock" : opcode === 2 ? "jrTimestamp" : "noop";
    const value = opcode === 1 ? body.jrClock?.timestamp32 : opcode === 2 ? body.jrTimestamp?.time15 : undefined;
    return { kind: "utility", status, value };
  }
  return null;
}

export function schemaPacketToWords(packet: unknown): Uint32Array[] | null {
  const event = schemaPacketToEvent(packet);
  if (!event) return null;
  if (event.kind === "sysex7") {
    return fragmentSysEx7(event.manufacturerId, event.payload, event.group);
  }
  if (event.kind === "sysex8") {
    return fragmentSysEx8(event.manufacturerId, event.payload, event.group);
  }
  if (event.kind === "rawUMP") {
    return [event.words instanceof Uint32Array ? event.words : Uint32Array.from(event.words)];
  }
  return [encodeUmp(event)];
}

export function eventToSchemaPacketWords(event: Midi2Event): Uint32Array[] | null {
  const packet = eventToSchemaPacket(event);
  if (!packet) return null;
  return schemaPacketToWords(packet);
}

export function validateSchemaPacket(packet: unknown): packet is UmpPacket {
  return isUmpPacket(packet);
}

export function decodeWordsToSchemaPacket(words: ArrayLike<number>): UmpPacket | null {
  const event = decodeUmp(words);
  if (!event) return null;
  return eventToSchemaPacket(event);
}

function sysex7ToPackets(payload: number[]): { streamStatus: "single" | "start" | "continue" | "end"; payload: number[] }[] {
  if (payload.length <= 6) {
    return [{ streamStatus: "single", payload }];
  }
  const packets: { streamStatus: "single" | "start" | "continue" | "end"; payload: number[] }[] = [];
  let remaining = payload.slice();
  packets.push({ streamStatus: "start", payload: remaining.splice(0, 6) });
  while (remaining.length > 6) {
    packets.push({ streamStatus: "continue", payload: remaining.splice(0, 6) });
  }
  packets.push({ streamStatus: "end", payload: remaining });
  return packets;
}

function reassembleSysEx7FromPackets(
  manufacturerId: number[],
  packets: { streamStatus: "single" | "start" | "continue" | "end"; payload: number[] }[],
): { manufacturerId: number[]; payload: number[] } {
  const payload: number[] = [];
  for (const p of packets) {
    payload.push(...p.payload);
  }
  return { manufacturerId, payload };
}

function packGeneric32(packet: UmpPacket32): Uint32Array {
  const mt = packet.messageType ?? 0;
  const group = packet.group ?? 0;
  const opcode = (packet as any).body?.opcode ?? 0;
  const word0 = ((mt & 0xf) << 28) | ((group & 0xf) << 24) | ((opcode & 0xff) << 16);
  return new Uint32Array([word0 >>> 0]);
}
