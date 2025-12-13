import {
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
  Midi2PerNotePitchBendEvent,
  Midi2PitchBendEvent,
  Midi2PolyPressureEvent,
  Midi2ProgramChangeEvent,
  Midi2RpnEvent,
  Midi2RpnRelativeEvent,
  RawUMPEvent,
  SysEx7Event,
  SysEx8Event,
  MdsChunk,
  MdsEvent,
  MidiCiEvent,
  Midi2SystemEvent,
  Midi1ChannelVoiceEvent,
  UtilityEvent,
  FlexTempoEvent,
  FlexTimeSignatureEvent,
  FlexKeySignatureEvent,
  FlexLyricEvent,
  FlexTextEvent,
  FlexChordNameEvent,
  FlexRubyEvent,
  FlexMetronomeEvent,
  StreamEvent,
} from "./types";
import { fragmentSysEx7, fragmentSysEx8, reassembleSysEx7, reassembleSysEx8 } from "./sysex";
import { encodeMidiCiEvent, decodeMidiCiFromSysEx } from "./midici";

const MIDI2_CHANNEL_VOICE_MT = 0x4;
const MIDI1_CHANNEL_VOICE_MT = 0x2;
const MIDI2_SYSTEM_MT = 0x1;
const UTILITY_MT = 0x0;
const STREAM_MT = 0xf;
export const STREAM_OPCODE_ENDPOINT_DISCOVERY = 0x00;
export const STREAM_OPCODE_ENDPOINT_INFO = 0x01;
export const STREAM_OPCODE_DEVICE_IDENTITY = 0x02;
export const STREAM_OPCODE_ENDPOINT_NAME = 0x03;
export const STREAM_OPCODE_PRODUCT_INSTANCE_ID = 0x04;
export const STREAM_OPCODE_STREAM_CONFIG_REQUEST = 0x05;
export const STREAM_OPCODE_STREAM_CONFIG_NOTIFICATION = 0x06;
export const STREAM_OPCODE_FUNCTION_BLOCK_DISCOVERY = 0x10;
export const STREAM_OPCODE_FUNCTION_BLOCK_INFO = 0x11;
export const STREAM_OPCODE_FUNCTION_BLOCK_NAME = 0x12;
export const STREAM_OPCODE_START_OF_CLIP = 0x20;
export const STREAM_OPCODE_END_OF_CLIP = 0x21;
export const STREAM_OPCODE_PROCESS_INQUIRY = 0x03; // unchanged (shared request/reply flag in byte3 bit7)
const DATA_STATUS_MDS_HEADER = 0x8;
const DATA_STATUS_MDS_PAYLOAD = 0x9;
const STATUS_RPN = 0x2;
const STATUS_NRPN = 0x3;
const STATUS_RPN_RELATIVE = 0x4;
const STATUS_NRPN_RELATIVE = 0x5;
const STATUS_NOTE_OFF = 0x8;
const STATUS_NOTE_ON = 0x9;
const STATUS_POLY_PRESSURE = 0xA;
const STATUS_CONTROL_CHANGE = 0xB;
const STATUS_PROGRAM_CHANGE = 0xC;
const STATUS_CHANNEL_PRESSURE = 0xD;
const STATUS_PITCH_BEND = 0xE;
const STATUS_PER_NOTE = 0xF;
const STATUS_PER_NOTE_PITCH = 0x00; // 7.4.12
const SYSTEM_REALTIME_MIN = 0xf8;
const SYSTEM_COMMON_MIN = 0xf1; // Song Position etc; 0xF0 handled by SysEx layer
const FLEX_STATUS_CLASS = 0x10;
const FLEX_STATUS_TEMPO = 0x01;
const FLEX_STATUS_TIMESIG = 0x02;
const FLEX_STATUS_KEY = 0x04;
const FLEX_STATUS_METRONOME = 0x03;
const FLEX_STATUS_CHORD = 0x05;
const FLEX_CLASS_LYRIC = 0x11;
const FLEX_STATUS_LYRIC = 0x02;
const FLEX_CLASS_TEXT = 0x11;
const FLEX_STATUS_TEXT = 0x01;
const FLEX_CLASS_RUBY = 0x11;
const FLEX_STATUS_RUBY = 0x03;
const FLEX_TEMPO_SCALE = 65536;

function assertRange(name: string, value: number, min: number, max: number): void {
  if (!Number.isInteger(value) || value < min || value > max) {
    throw new RangeError(`${name} must be an integer in [${min}, ${max}], got ${value}`);
  }
}

function assertInt32(name: string, value: number): void {
  if (!Number.isInteger(value) || value < -0x80000000 || value > 0x7fffffff) {
    throw new RangeError(`${name} must be a 32-bit signed integer, got ${value}`);
  }
}

function assertUint32(name: string, value: number): void {
  if (!Number.isInteger(value) || value < 0 || value > 0xffffffff) {
    throw new RangeError(`${name} must be an integer in [0, 0xFFFFFFFF], got ${value}`);
  }
}

function assertDecodeRange(name: string, value: number, min: number, max: number): void {
  if (value < min || value > max) {
    throw new RangeError(`Invalid ${name}: ${value} (expected [${min}, ${max}])`);
  }
}

function toUint32Array(words: ArrayLike<number>): Uint32Array {
  return words instanceof Uint32Array ? words : Uint32Array.from(words);
}

function encodeSystemEvent(event: Midi2SystemEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("status", event.status, 0xf0, 0xff);
  const needsData2 = event.status === 0xf2; // Song Position Pointer
  const needsData1 = needsData2 || event.status === 0xf1 || event.status === 0xf3;
  if (needsData1) {
    assertRange("data1", event.data1 ?? 0, 0, 0x7f);
  }
  if (needsData2) {
    assertRange("data2", event.data2 ?? 0, 0, 0x7f);
  }
  const byte0 = (MIDI2_SYSTEM_MT << 4) | (event.group & 0x0f);
  const byte1 = event.status & 0xff;
  const byte2 = needsData1 ? (event.data1 ?? 0) & 0x7f : 0;
  const byte3 = needsData2 ? (event.data2 ?? 0) & 0x7f : 0;
  const word0 = (byte0 << 24) | (byte1 << 16) | (byte2 << 8) | byte3;
  return new Uint32Array([word0 >>> 0]);
}

function encodeMidi1ChannelVoice(event: Midi1ChannelVoiceEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("status", event.status, 0x80, 0xef);
  const status = event.status & 0xff;
  const hasData2 = status >= 0x80 && status !== 0xc0 && status !== 0xd0;
  const hasData1 = status >= 0x80;
  if (hasData1) assertRange("data1", event.data1 ?? 0, 0, 0x7f);
  if (hasData2) assertRange("data2", event.data2 ?? 0, 0, 0x7f);
  const word0 =
    (MIDI1_CHANNEL_VOICE_MT << 28) |
    (event.group << 24) |
    (status << 16) |
    ((event.data1 ?? 0) << 8) |
    (hasData2 ? event.data2 ?? 0 : 0);
  return new Uint32Array([word0 >>> 0]);
}

function encodeUtility(event: UtilityEvent): Uint32Array {
  let statusByte = 0x00;
  let data = 0;
  switch (event.status) {
    case "noop":
      statusByte = 0x00;
      data = 0;
      break;
    case "jrClock":
      statusByte = 0x01;
      data = event.value ?? 0;
      break;
    case "jrTimestamp":
      statusByte = 0x02;
      data = event.value ?? 0;
      break;
    default:
      throw new Error(`Unknown utility status ${(event as UtilityEvent).status}`);
  }
  assertRange("value", data, 0, 0xffff);
  const word = (UTILITY_MT << 28) | (statusByte << 16) | (data & 0xffff);
  return new Uint32Array([word >>> 0]);
}

function encodeStreamFlags(cfg: { protocol?: "midi1" | "midi2"; jrTimestampsTx?: boolean; jrTimestampsRx?: boolean }, isNotification: boolean): number {
  let flags = 0;
  if ((cfg.protocol ?? "midi1") === "midi2") flags |= 0x20;
  if (cfg.jrTimestampsTx) flags |= 0x02;
  if (cfg.jrTimestampsRx && !isNotification) flags |= 0x04;
  return flags;
}

function encodeStream(event: StreamEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  switch (event.opcode) {
    case "endpointDiscovery": {
      const info = event.endpointDiscovery ?? {};
      const major = info.majorVersion ?? 0;
      const minor = info.minorVersion ?? 0;
      const maxGroups = info.maxGroups ?? 0;
      assertRange("majorVersion", major, 0, 0x0f);
      assertRange("minorVersion", minor, 0, 0x0f);
      assertRange("maxGroups", maxGroups, 0, 0x0f);
      const byte2 = ((major & 0x0f) << 4) | (minor & 0x0f);
      const byte3 = maxGroups & 0x0f; // high nibble reserved 0
      const word0 = (STREAM_MT << 28) | (event.group << 24) | (STREAM_OPCODE_ENDPOINT_DISCOVERY << 16) | (byte2 << 8) | byte3;
      return new Uint32Array([word0 >>> 0]);
    }
    case "endpointInfoNotification": {
      const info = event.endpointInfoNotification ?? {};
      const s = info.staticFunctionBlocks ? 0x80 : 0;
      const nfb = info.numberOfFunctionBlocks ?? 0;
      assertRange("numberOfFunctionBlocks", nfb, 0, 0x20);
      const byte2 = s | (nfb & 0x3f);
      let byte3 = 0;
      if (info.midi1Supported) byte3 |= 0x01;
      if (info.midi2Supported) byte3 |= 0x02;
      if (info.jrTimestampsRx) byte3 |= 0x04;
      if (info.jrTimestampsTx) byte3 |= 0x08;
      const word0 = (STREAM_MT << 28) | (event.group << 24) | (STREAM_OPCODE_ENDPOINT_INFO << 16) | (byte2 << 8) | byte3;
      return new Uint32Array([word0 >>> 0]);
    }
    case "deviceIdentityNotification": {
      const id = event.deviceIdentityNotification ?? {};
      const mId = id.manufacturerId ?? [];
      const family = id.deviceFamily ?? 0;
      const model = id.deviceModel ?? 0;
      const sw = id.softwareRevision ?? 0;
      const word0 = (STREAM_MT << 28) | (event.group << 24) | (STREAM_OPCODE_DEVICE_IDENTITY << 16);
      const word1 =
        (((mId[0] ?? 0) & 0xff) << 24) |
        (((mId[1] ?? 0) & 0xff) << 16) |
        (((mId[2] ?? 0) & 0xff) << 8) |
        ((family >> 8) & 0xff);
      const word2 =
        ((family & 0xff) << 24) |
        ((model >> 8) & 0xff) << 16 |
        ((model & 0xff) << 8) |
        ((sw >> 24) & 0xff);
      const word3 = ((sw >> 16) & 0xff) << 24 | ((sw >> 8) & 0xff) << 16 | (sw & 0xff) << 8;
      return new Uint32Array([word0 >>> 0, word1 >>> 0, word2 >>> 0, word3 >>> 0]);
    }
    case "endpointNameNotification": {
      const name = event.endpointNameNotification?.name ?? "";
      const bytes = Array.from(new TextEncoder().encode(name)).slice(0, 98);
      const words: number[] = [];
      for (let i = 0; i < bytes.length; i += 4) {
        const w = ((bytes[i] ?? 0) << 24) | ((bytes[i + 1] ?? 0) << 16) | ((bytes[i + 2] ?? 0) << 8) | (bytes[i + 3] ?? 0);
        words.push(w >>> 0);
      }
      const word0 = (STREAM_MT << 28) | (event.group << 24) | (STREAM_OPCODE_ENDPOINT_NAME << 16);
      return new Uint32Array([word0 >>> 0, ...words]);
    }
    case "productInstanceIdNotification": {
      const id = event.productInstanceIdNotification?.productInstanceId ?? "";
      const bytes = Array.from(new TextEncoder().encode(id)).slice(0, 42);
      const words: number[] = [];
      for (let i = 0; i < bytes.length; i += 4) {
        const w = ((bytes[i] ?? 0) << 24) | ((bytes[i + 1] ?? 0) << 16) | ((bytes[i + 2] ?? 0) << 8) | (bytes[i + 3] ?? 0);
        words.push(w >>> 0);
      }
      const word0 = (STREAM_MT << 28) | (event.group << 24) | (STREAM_OPCODE_PRODUCT_INSTANCE_ID << 16);
      return new Uint32Array([word0 >>> 0, ...words]);
    }
    case "streamConfigRequest":
    case "streamConfigNotification": {
      const isNotification = event.opcode === "streamConfigNotification";
      const cfg = event.streamConfigRequest ?? event.streamConfigNotification ?? {};
      const flags = encodeStreamFlags(cfg, isNotification);
      const opcode = isNotification ? STREAM_OPCODE_STREAM_CONFIG_NOTIFICATION : STREAM_OPCODE_STREAM_CONFIG_REQUEST;
      const word0 = (STREAM_MT << 28) | (event.group << 24) | (opcode << 16) | (flags << 8);
      return new Uint32Array([word0 >>> 0]);
    }
    case "functionBlockInfoNotification": {
      const info = event.functionBlockInfoNotification ?? {};
      assertRange("index", info.index ?? 0, 0, 0xff);
      assertRange("firstGroup", info.firstGroup ?? 0, 0, 0x0f);
      assertRange("groupCount", info.groupCount ?? 0, 0, 0x0f);
      assertRange("direction", info.direction ?? 0, 0, 0x03);
      // 0..2 valid, 3 reserved (spec Appendix I); guard upper bound only
      assertRange("midi1Bandwidth", info.midi1Bandwidth ?? 0, 0, 0x02);
      const active = info.active ? 0x80 : 0x00;
      const direction = (info.direction ?? 0) & 0x03;
      const midi1Bandwidth = (info.midi1Bandwidth ?? 0) & 0x03;
      const word0 =
        (STREAM_MT << 28) |
        (event.group << 24) |
        (STREAM_OPCODE_FUNCTION_BLOCK_INFO << 16) |
        ((info.index ?? 0) << 8) |
        (((info.firstGroup ?? 0) & 0x0f) << 4) |
        ((info.groupCount ?? 0) & 0x0f);
      const word1 = (active << 24) | (direction << 16) | (midi1Bandwidth << 8);
      return new Uint32Array([word0 >>> 0, word1 >>> 0]);
    }
    case "functionBlockNameNotification": {
      const word0 = (STREAM_MT << 28) | (event.group << 24) | (STREAM_OPCODE_FUNCTION_BLOCK_NAME << 16);
      return new Uint32Array([word0 >>> 0]);
    }
    case "startOfClip": {
      const word0 = (STREAM_MT << 28) | (event.group << 24) | (STREAM_OPCODE_START_OF_CLIP << 16);
      return new Uint32Array([word0 >>> 0]);
    }
    case "endOfClip": {
      const word0 = (STREAM_MT << 28) | (event.group << 24) | (STREAM_OPCODE_END_OF_CLIP << 16);
      return new Uint32Array([word0 >>> 0]);
    }
    case "functionBlockDiscovery": {
      const filter = (event.functionBlockDiscovery?.filterBitmap ?? 0) & 0xffff;
      const word0 =
        (STREAM_MT << 28) |
        (event.group << 24) |
        (STREAM_OPCODE_FUNCTION_BLOCK_DISCOVERY << 16) |
        (((filter >> 8) & 0xff) << 8) |
        (filter & 0xff);
      return new Uint32Array([word0 >>> 0]);
    }
    case "processInquiry": {
      const fb = event.processInquiry?.functionBlock ?? 0;
      const part = event.processInquiry?.part ?? 0;
      assertRange("functionBlock", fb, 0, 0x7f);
      assertRange("part", part, 0, 0x0f);
      const word0 = (STREAM_MT << 28) | (event.group << 24) | (STREAM_OPCODE_PROCESS_INQUIRY << 16) | (fb << 8) | part;
      return new Uint32Array([word0 >>> 0]);
    }
    case "processInquiryReply": {
      const fb = event.processInquiryReply?.functionBlock ?? 0;
      const part = event.processInquiryReply?.part ?? 0;
      assertRange("functionBlock", fb, 0, 0x7f);
      assertRange("part", part, 0, 0x0f);
      const word0 = (STREAM_MT << 28) | (event.group << 24) | (STREAM_OPCODE_PROCESS_INQUIRY << 16) | (fb << 8) | part | 0x80;
      return new Uint32Array([word0 >>> 0]);
    }
    default:
      throw new Error(`Unsupported stream opcode ${(event as StreamEvent).opcode}`);
  }
}

function decodeStream(words: Uint32Array, timestamp?: number): StreamEvent {
  const word0 = words[0];
  if ((word0 & 0x00000008) !== 0) {
    throw new RangeError("Stream packet has reserved bit set.");
  }
  const mt = (word0 >>> 28) & 0xf;
  if (mt !== STREAM_MT) {
    throw new RangeError("Not a stream packet.");
  }
  const group = (word0 >>> 24) & 0xf;
  const opcodeByte = (word0 >>> 16) & 0xff;
  const byte2 = (word0 >>> 8) & 0xff;
  const byte3 = word0 & 0xff;

  if (opcodeByte === STREAM_OPCODE_ENDPOINT_DISCOVERY) {
    const majorVersion = (byte2 >> 4) & 0x0f;
    const minorVersion = byte2 & 0x0f;
    const maxGroups = byte3 & 0x0f;
    if ((byte3 & 0xf0) !== 0) {
      throw new RangeError("Stream endpoint discovery contains reserved data.");
    }
    return { kind: "stream", group, opcode: "endpointDiscovery", endpointDiscovery: { majorVersion, minorVersion, maxGroups }, timestamp };
  }

  if (opcodeByte === STREAM_OPCODE_ENDPOINT_INFO) {
    const staticFunctionBlocks = (byte2 & 0x80) !== 0;
    if ((byte2 & 0x40) !== 0) {
      throw new RangeError("Endpoint info has reserved bit set.");
    }
    const numberOfFunctionBlocks = byte2 & 0x3f;
    if (numberOfFunctionBlocks > 0x20) {
      throw new RangeError("Endpoint info uses reserved numberOfFunctionBlocks value.");
    }
    const midi1Supported = (byte3 & 0x01) !== 0;
    const midi2Supported = (byte3 & 0x02) !== 0;
    const jrTimestampsRx = (byte3 & 0x04) !== 0;
    const jrTimestampsTx = (byte3 & 0x08) !== 0;
    if ((byte3 & 0xf0) !== 0) {
      throw new RangeError("Endpoint info has reserved capability bits set.");
    }
    return {
      kind: "stream",
      group,
      opcode: "endpointInfoNotification",
      endpointInfoNotification: { staticFunctionBlocks, numberOfFunctionBlocks, midi1Supported, midi2Supported, jrTimestampsRx, jrTimestampsTx },
      timestamp,
    };
  }

  if (opcodeByte === STREAM_OPCODE_DEVICE_IDENTITY) {
    if (words.length >= 4) {
      const w1 = words[1];
      const w2 = words[2];
      const w3 = words[3];
      const manufacturerIdRaw = [(w1 >>> 24) & 0xff, (w1 >>> 16) & 0xff, (w1 >>> 8) & 0xff].filter((b, idx) => idx === 0 || b !== 0);
      const manufacturerId = manufacturerIdRaw.length === 1 ? [manufacturerIdRaw[0]] : manufacturerIdRaw;
      const family = ((w1 & 0xff) << 8) | ((w2 >>> 24) & 0xff);
      const model = ((w2 >>> 16) & 0xff) << 8 | ((w2 >>> 8) & 0xff);
      const sw = ((w2 & 0xff) << 24) | ((w3 >>> 24) & 0xff) << 16 | ((w3 >>> 16) & 0xff) << 8 | ((w3 >>> 8) & 0xff);
      return { kind: "stream", group, opcode: "deviceIdentityNotification", deviceIdentityNotification: { manufacturerId, deviceFamily: family, deviceModel: model, softwareRevision: sw }, timestamp };
    }
    return { kind: "stream", group, opcode: "deviceIdentityNotification", deviceIdentityNotification: {}, timestamp };
  }

  if (opcodeByte === STREAM_OPCODE_ENDPOINT_NAME) {
    const bytes: number[] = [];
    for (let i = 1; i < words.length; i++) {
      const w = words[i];
      bytes.push((w >>> 24) & 0xff, (w >>> 16) & 0xff, (w >>> 8) & 0xff, w & 0xff);
    }
    const name = new TextDecoder().decode(Uint8Array.from(bytes.filter(b => b !== 0)));
    return { kind: "stream", group, opcode: "endpointNameNotification", endpointNameNotification: { name }, timestamp };
  }

  if (opcodeByte === STREAM_OPCODE_PRODUCT_INSTANCE_ID) {
    const bytes: number[] = [];
    for (let i = 1; i < words.length; i++) {
      const w = words[i];
      bytes.push((w >>> 24) & 0xff, (w >>> 16) & 0xff, (w >>> 8) & 0xff, w & 0xff);
    }
    const productInstanceId = new TextDecoder().decode(Uint8Array.from(bytes.filter(b => b !== 0)));
    return { kind: "stream", group, opcode: "productInstanceIdNotification", productInstanceIdNotification: { productInstanceId }, timestamp };
  }

  if (opcodeByte === STREAM_OPCODE_STREAM_CONFIG_REQUEST || opcodeByte === STREAM_OPCODE_STREAM_CONFIG_NOTIFICATION) {
    if ((byte2 & 0xd9) !== 0) {
      throw new RangeError("Stream config flags have reserved bits set.");
    }
    const protocol: "midi1" | "midi2" = (byte2 & 0x20) !== 0 ? "midi2" : "midi1";
    const jrTx = (byte2 & 0x02) !== 0;
    const jrRx = (byte2 & 0x04) !== 0;
    const cfg = { protocol, jrTimestampsTx: jrTx, jrTimestampsRx: jrRx };
    const isNotification = opcodeByte === STREAM_OPCODE_STREAM_CONFIG_NOTIFICATION;
    return isNotification
      ? { kind: "stream", group, opcode: "streamConfigNotification", streamConfigNotification: cfg, timestamp }
      : { kind: "stream", group, opcode: "streamConfigRequest", streamConfigRequest: cfg, timestamp };
  }

  if (opcodeByte === STREAM_OPCODE_FUNCTION_BLOCK_DISCOVERY) {
    const filterBitmap = (byte2 << 8) | byte3;
    return {
      kind: "stream",
      group,
      opcode: "functionBlockDiscovery",
      functionBlockDiscovery: { filterBitmap },
      timestamp,
    };
  }

  if (opcodeByte === STREAM_OPCODE_FUNCTION_BLOCK_INFO) {
    if (words.length < 2) {
      throw new RangeError("Function block info must contain two words.");
    }
    const index = byte2;
    const firstGroup = (byte3 >> 4) & 0x0f;
    const groupCount = byte3 & 0x0f;
    const word1 = words[1];
    const active = (word1 & 0x80000000) !== 0;
    const direction = (word1 >>> 16) & 0x03;
    const midi1Bandwidth = (word1 >>> 8) & 0x03;
    const reservedMask = ~(0x80030300 >>> 0);
    if ((word1 & reservedMask) !== 0) {
      throw new RangeError("Function block info has reserved bits set.");
    }
    if (midi1Bandwidth > 0x02) {
      throw new RangeError("Function block info has reserved midi1Bandwidth value.");
    }
    return {
      kind: "stream",
      group,
      opcode: "functionBlockInfoNotification",
      functionBlockInfoNotification: { index, firstGroup, groupCount, active, direction: direction as any, midi1Bandwidth: midi1Bandwidth as any },
      timestamp,
    };
  }

  if (opcodeByte === STREAM_OPCODE_FUNCTION_BLOCK_NAME) {
    return { kind: "stream", group, opcode: "functionBlockNameNotification", functionBlockNameNotification: { functionBlock: 0, name: "" }, timestamp };
  }

  if (opcodeByte === STREAM_OPCODE_START_OF_CLIP) {
    return { kind: "stream", group, opcode: "startOfClip", timestamp };
  }

  if (opcodeByte === STREAM_OPCODE_END_OF_CLIP) {
    return { kind: "stream", group, opcode: "endOfClip", timestamp };
  }
  if (opcodeByte === STREAM_OPCODE_PROCESS_INQUIRY) {
    const fb = byte2 & 0x7f;
    const part = byte3 & 0x0f;
    const isReply = (byte3 & 0x80) !== 0;
    if (isReply) {
      return { kind: "stream", group, opcode: "processInquiryReply", processInquiryReply: { functionBlock: fb, part }, timestamp };
    }
    return { kind: "stream", group, opcode: "processInquiry", processInquiry: { functionBlock: fb, part }, timestamp };
  }

  throw new RangeError(`Unsupported stream opcode 0x${opcodeByte.toString(16)}`);
}

function encodeFlexTempo(event: FlexTempoEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  if (event.bpm < 1) {
    throw new RangeError("bpm must be at least 1");
  }
  const fixed = Math.round(event.bpm * FLEX_TEMPO_SCALE);
  const word0 =
    (0xd << 28) |
    (event.group << 24) |
    (FLEX_STATUS_CLASS << 16) |
    (FLEX_STATUS_TEMPO << 8);
  return new Uint32Array([word0 >>> 0, fixed >>> 0, 0, 0]);
}

function encodeFlexTimeSignature(event: FlexTimeSignatureEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("numerator", event.numerator, 1, 0xff);
  assertRange("denominatorPow2", event.denominatorPow2, 0, 0x1f);
  let addrByte = 0x00;
  if (event.channel !== undefined) {
    assertRange("channel", event.channel, 0, 0xf);
    addrByte = 0x10 | (event.channel & 0x0f);
  }
  const word0 =
    (0xd << 28) |
    (event.group << 24) |
    (FLEX_STATUS_CLASS << 16) |
    (FLEX_STATUS_TIMESIG << 8) |
    addrByte;
  const word1 = (event.numerator << 24) | (event.denominatorPow2 << 16);
  return new Uint32Array([word0 >>> 0, word1 >>> 0, 0, 0]);
}

function packText12(text: string): [number, number, number] {
  const bytes = Array.from(new TextEncoder().encode(text)).slice(0, 12);
  while (bytes.length < 12) bytes.push(0);
  const word1 = (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
  const word2 = (bytes[4] << 24) | (bytes[5] << 16) | (bytes[6] << 8) | bytes[7];
  const word3 = (bytes[8] << 24) | (bytes[9] << 16) | (bytes[10] << 8) | bytes[11];
  return [word1 >>> 0, word2 >>> 0, word3 >>> 0];
}

function packBytes12(bytes: number[]): [number, number, number] {
  const arr = bytes.slice(0, 12);
  while (arr.length < 12) arr.push(0);
  const word1 = (arr[0] << 24) | (arr[1] << 16) | (arr[2] << 8) | arr[3];
  const word2 = (arr[4] << 24) | (arr[5] << 16) | (arr[6] << 8) | arr[7];
  const word3 = (arr[8] << 24) | (arr[9] << 16) | (arr[10] << 8) | arr[11];
  return [word1 >>> 0, word2 >>> 0, word3 >>> 0];
}

function encodeFlexKeySignature(event: FlexKeySignatureEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  let addrByte = 0x00;
  if (event.channel !== undefined) {
    assertRange("channel", event.channel, 0, 0xf);
    addrByte = 0x10 | (event.channel & 0x0f);
  }
  const word0 =
    (0xd << 28) |
    (event.group << 24) |
    (FLEX_STATUS_CLASS << 16) |
    (FLEX_STATUS_KEY << 8) |
    addrByte;
  const [w1, w2, w3] = packText12(event.key);
  return new Uint32Array([word0 >>> 0, w1, w2, w3]);
}

function encodeFlexLyric(event: FlexLyricEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  let addrByte = 0x00;
  if (event.channel !== undefined) {
    assertRange("channel", event.channel, 0, 0xf);
    addrByte = 0x10 | (event.channel & 0x0f);
  }
  const word0 =
    (0xd << 28) |
    (event.group << 24) |
    (FLEX_CLASS_LYRIC << 16) |
    (FLEX_STATUS_LYRIC << 8) |
    addrByte;
  const [w1, w2, w3] = packText12(event.text);
  return new Uint32Array([word0 >>> 0, w1, w2, w3]);
}

function encodeFlexText(event: FlexTextEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  let addrByte = 0x00;
  if (event.channel !== undefined) {
    assertRange("channel", event.channel, 0, 0xf);
    addrByte = 0x10 | (event.channel & 0x0f);
  }
  const word0 = (0xd << 28) | (event.group << 24) | (FLEX_CLASS_TEXT << 16) | (FLEX_STATUS_TEXT << 8) | addrByte;
  const [w1, w2, w3] = packText12(event.text);
  return new Uint32Array([word0 >>> 0, w1, w2, w3]);
}

function encodeFlexRuby(event: FlexRubyEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  let addrByte = 0x00;
  if (event.channel !== undefined) {
    assertRange("channel", event.channel, 0, 0xf);
    addrByte = 0x10 | (event.channel & 0x0f);
  }
  const word0 = (0xd << 28) | (event.group << 24) | (FLEX_CLASS_RUBY << 16) | (FLEX_STATUS_RUBY << 8) | addrByte;
  const [w1, w2, w3] = packText12(event.ruby);
  return new Uint32Array([word0 >>> 0, w1, w2, w3]);
}

function encodeFlexChordName(event: FlexChordNameEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  let addrByte = 0x00;
  if (event.channel !== undefined) {
    assertRange("channel", event.channel, 0, 0xf);
    addrByte = 0x10 | (event.channel & 0x0f);
  }
  const word0 = (0xd << 28) | (event.group << 24) | (FLEX_STATUS_CLASS << 16) | (FLEX_STATUS_CHORD << 8) | addrByte;
  const [w1, w2, w3] = packText12(event.chord);
  return new Uint32Array([word0 >>> 0, w1, w2, w3]);
}

function encodeFlexMetronome(event: FlexMetronomeEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  if (!Number.isInteger(event.clicksPerBeat) || event.clicksPerBeat < 1 || event.clicksPerBeat > 0xffff) {
    throw new RangeError("clicksPerBeat must be an integer in [1, 65535]");
  }
  let addrByte = 0x00;
  if (event.channel !== undefined) {
    assertRange("channel", event.channel, 0, 0xf);
    addrByte = 0x10 | (event.channel & 0x0f);
  }
  const accentBytes = Array.from(new TextEncoder().encode(event.accentPattern)).slice(0, 10);
  while (accentBytes.length < 10) accentBytes.push(0);
  const [w1, w2, w3] = packBytes12([
    (event.clicksPerBeat >> 8) & 0xff,
    event.clicksPerBeat & 0xff,
    ...accentBytes,
  ]);
  const word0 = (0xd << 28) | (event.group << 24) | (FLEX_STATUS_CLASS << 16) | (FLEX_STATUS_METRONOME << 8) | addrByte;
  return new Uint32Array([word0 >>> 0, w1, w2, w3]);
}

function encodeChannelVoiceWord0(group: number, status: number, channel: number, dataMsb: number, dataLsb = 0): number {
  return (
    (MIDI2_CHANNEL_VOICE_MT << 28) |
    (group << 24) |
    (status << 20) |
    (channel << 16) |
    (dataMsb << 8) |
    dataLsb
  );
}

export function encodeNoteOn(event: Midi2NoteOnEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("note", event.note, 0, 0x7f);
  const velocity = event.velocity;
  assertRange("velocity", velocity, 0, 0xffff);
  const attributeType = event.attributeType ?? 0;
  assertRange("attributeType", attributeType, 0, 0xff);
  const attributeData = event.attributeData ?? 0;
  assertRange("attributeData", attributeData, 0, 0xffff);

  const word0 = encodeChannelVoiceWord0(event.group, STATUS_NOTE_ON, event.channel, event.note, attributeType);
  const word1 = (velocity << 16) | attributeData;
  return new Uint32Array([word0 >>> 0, word1 >>> 0]);
}

export function encodeNoteOff(event: Midi2NoteOffEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("note", event.note, 0, 0x7f);
  const velocity = event.velocity ?? 0;
  assertRange("velocity", velocity, 0, 0xffff);
  const attributeType = event.attributeType ?? 0;
  assertRange("attributeType", attributeType, 0, 0xff);
  const attributeData = event.attributeData ?? 0;
  assertRange("attributeData", attributeData, 0, 0xffff);

  const word0 = encodeChannelVoiceWord0(event.group, STATUS_NOTE_OFF, event.channel, event.note, attributeType);
  const word1 = (velocity << 16) | attributeData;
  return new Uint32Array([word0 >>> 0, word1 >>> 0]);
}

export function encodeRpn(event: Midi2RpnEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("bank", event.bank, 0, 0x7f);
  assertRange("index", event.index, 0, 0x7f);
  assertUint32("value", event.value);
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_RPN, event.channel, event.bank, event.index);
  return new Uint32Array([word0 >>> 0, event.value >>> 0]);
}

export function encodeNrpn(event: Midi2NrpnEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("bank", event.bank, 0, 0x7f);
  assertRange("index", event.index, 0, 0x7f);
  assertUint32("value", event.value);
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_NRPN, event.channel, event.bank, event.index);
  return new Uint32Array([word0 >>> 0, event.value >>> 0]);
}

export function encodeRpnRelative(event: Midi2RpnRelativeEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("bank", event.bank, 0, 0x7f);
  assertRange("index", event.index, 0, 0x7f);
  assertInt32("delta", event.delta);
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_RPN_RELATIVE, event.channel, event.bank, event.index);
  return new Uint32Array([word0 >>> 0, (event.delta >>> 0) & 0xffffffff]);
}

export function encodeNrpnRelative(event: Midi2NrpnRelativeEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("bank", event.bank, 0, 0x7f);
  assertRange("index", event.index, 0, 0x7f);
  assertInt32("delta", event.delta);
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_NRPN_RELATIVE, event.channel, event.bank, event.index);
  return new Uint32Array([word0 >>> 0, (event.delta >>> 0) & 0xffffffff]);
}

export function encodePerNoteManagement(event: Midi2PerNoteManagementEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("note", event.note, 0, 0x7f);
  const flags = (event.detach ? 0x02 : 0) | (event.reset ? 0x01 : 0);
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_PER_NOTE, event.channel, event.note, flags);
  return new Uint32Array([word0 >>> 0, 0]);
}

export function encodePerNoteRegisteredController(event: Midi2PerNoteRegisteredControllerEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("note", event.note, 0, 0x7f);
  assertRange("controller", event.controller, 0, 0x7f);
  assertUint32("value", event.value);
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_PER_NOTE, event.channel, event.note, event.controller);
  return new Uint32Array([word0 >>> 0, event.value >>> 0]);
}

export function encodePerNoteAssignableController(event: Midi2PerNoteAssignableControllerEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("note", event.note, 0, 0x7f);
  assertRange("controller", event.controller, 0x80, 0xff);
  assertUint32("value", event.value);
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_PER_NOTE, event.channel, event.note, event.controller);
  return new Uint32Array([word0 >>> 0, event.value >>> 0]);
}

export function encodePerNotePitchBend(event: Midi2PerNotePitchBendEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("note", event.note, 0, 0x7f);
  assertUint32("value", event.value);
  const word0 =
    (MIDI2_CHANNEL_VOICE_MT << 28) |
    (event.group << 24) |
    (STATUS_PER_NOTE_PITCH << 20) |
    (event.channel << 16) |
    (event.note << 8);
  return new Uint32Array([word0 >>> 0, event.value >>> 0]);
}

export function encodePolyPressure(event: Midi2PolyPressureEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("note", event.note, 0, 0x7f);
  assertUint32("pressure", event.pressure);
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_POLY_PRESSURE, event.channel, event.note);
  return new Uint32Array([word0 >>> 0, event.pressure >>> 0]);
}

export function encodeControlChange(event: Midi2ControlChangeEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("controller", event.controller, 0, 0x7f);
  assertUint32("value", event.value);
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_CONTROL_CHANGE, event.channel, event.controller);
  return new Uint32Array([word0 >>> 0, event.value >>> 0]);
}

export function encodeProgramChange(event: Midi2ProgramChangeEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertRange("program", event.program, 0, 0x7f);
  const bankValid = event.bankMsb !== undefined || event.bankLsb !== undefined;
  if (event.bankMsb !== undefined) {
    assertRange("bankMsb", event.bankMsb, 0, 0x7f);
  }
  if (event.bankLsb !== undefined) {
    assertRange("bankLsb", event.bankLsb, 0, 0x7f);
  }
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_PROGRAM_CHANGE, event.channel, event.program, bankValid ? 0x80 : 0x00);
  const word1 =
    ((event.bankMsb ?? 0) << 24) |
    ((event.bankLsb ?? 0) << 16);
  return new Uint32Array([word0 >>> 0, word1 >>> 0]);
}

export function encodeChannelPressure(event: Midi2ChannelPressureEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertUint32("pressure", event.pressure);
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_CHANNEL_PRESSURE, event.channel, 0, 0);
  return new Uint32Array([word0 >>> 0, event.pressure >>> 0]);
}

export function encodePitchBend(event: Midi2PitchBendEvent): Uint32Array {
  assertRange("group", event.group, 0, 0xf);
  assertRange("channel", event.channel, 0, 0xf);
  assertUint32("value", event.value);
  const word0 = encodeChannelVoiceWord0(event.group, STATUS_PITCH_BEND, event.channel, 0, 0);
  return new Uint32Array([word0 >>> 0, event.value >>> 0]);
}

export function encodeUmp(event: Midi2Event): Uint32Array {
  switch (event.kind) {
    case "utility":
      return encodeUtility(event);
    case "stream":
      return encodeStream(event);
    case "flexTempo":
      return encodeFlexTempo(event);
    case "flexTimeSignature":
      return encodeFlexTimeSignature(event);
    case "flexKeySignature":
      return encodeFlexKeySignature(event);
    case "flexLyric":
      return encodeFlexLyric(event);
    case "flexText":
      return encodeFlexText(event);
    case "flexChordName":
      return encodeFlexChordName(event);
    case "flexRuby":
      return encodeFlexRuby(event);
    case "flexMetronome":
      return encodeFlexMetronome(event);
    case "midi1ChannelVoice":
      return encodeMidi1ChannelVoice(event);
    case "system":
      return encodeSystemEvent(event);
    case "noteOn":
      return encodeNoteOn(event);
    case "noteOff":
      return encodeNoteOff(event);
    case "rpn":
      return encodeRpn(event);
    case "nrpn":
      return encodeNrpn(event);
    case "rpnRelative":
      return encodeRpnRelative(event);
    case "nrpnRelative":
      return encodeNrpnRelative(event);
    case "perNoteManagement":
      return encodePerNoteManagement(event);
    case "perNoteRegisteredController":
      return encodePerNoteRegisteredController(event);
    case "perNoteAssignableController":
      return encodePerNoteAssignableController(event);
    case "perNotePitchBend":
      return encodePerNotePitchBend(event);
    case "polyPressure":
      return encodePolyPressure(event);
    case "controlChange":
      return encodeControlChange(event);
    case "programChange":
      return encodeProgramChange(event);
    case "channelPressure":
      return encodeChannelPressure(event);
    case "pitchBend":
      return encodePitchBend(event);
    case "rawUMP":
      return toUint32Array(event.words);
    default:
      throw new Error(`Cannot encode event of kind ${(event as Midi2Event).kind}`);
  }
}

export function encodeEventPackets(event: Midi2Event): Uint32Array[] {
  switch (event.kind) {
    case "sysex7": {
      return fragmentSysEx7(event.manufacturerId, event.payload, event.group);
    }
    case "sysex8": {
      return fragmentSysEx8(event.manufacturerId, event.payload, event.group);
    }
    case "midiCi":
      return encodeMidiCiEvent(event);
    default:
      return [encodeUmp(event)];
  }
}

export function decodeUmp(words: ArrayLike<number>, timestamp?: number): Midi2Event | null {
  if (!words || words.length < 1) {
    return null;
  }
  const packet = toUint32Array(words);
  const word0 = packet[0];
  const mt = (word0 >>> 28) & 0xf;
  if (mt === STREAM_MT) {
    return decodeStream(packet, timestamp);
  }
  if (mt === 0x3) {
    if (packet.length % 2 !== 0) {
      return { kind: "rawUMP", words: packet, timestamp } as RawUMPEvent;
    }
    const packets: Uint32Array[] = [];
    for (let i = 0; i < packet.length; i += 2) {
      packets.push(packet.subarray(i, i + 2));
    }
    try {
      const syx = reassembleSysEx7(packets);
      const evt: SysEx7Event = {
        kind: "sysex7",
        group: syx.group,
        manufacturerId: syx.manufacturerId,
        payload: syx.payload,
        timestamp,
      };
      const maybeCi = decodeMidiCiFromSysEx(evt);
      return maybeCi ?? evt;
    } catch {
      return { kind: "rawUMP", words: packet, timestamp } as RawUMPEvent;
    }
  }
  if (mt === 0x5) {
    // MT=5 can be SysEx8 or MDS; detect Mixed Data Set status nibble 0x8/0x9 in first word
    if (packet.length % 4 !== 0) {
      return { kind: "rawUMP", words: packet, timestamp } as RawUMPEvent;
    }
    const statusNibble = (word0 >>> 20) & 0xf;
    if (statusNibble === DATA_STATUS_MDS_HEADER || statusNibble === DATA_STATUS_MDS_PAYLOAD) {
      // interpret as MDS
      if (packet.length < 4) return null;
      const headerStatus = (packet[0] >>> 20) & 0xf;
      if (headerStatus !== DATA_STATUS_MDS_HEADER) {
        return { kind: "rawUMP", words: packet, timestamp } as RawUMPEvent;
      }
      const group = (packet[0] >>> 24) & 0x0f;
      const mdsId = (packet[0] >>> 8) & 0xff;
      const headerValidBytes = packet[0] & 0xff;
      const totalChunks = (packet[1] >>> 16) & 0xffff;
      const chunkIndex = packet[1] & 0xffff;
      const manufacturerId = (packet[2] >>> 16) & 0xffff;
      const deviceId = packet[2] & 0xffff;
      const subId1 = (packet[3] >>> 16) & 0xffff;
      const subId2 = packet[3] & 0xffff;

      const payloadParts: number[] = [];
      for (let i = 4; i + 3 < packet.length; i += 4) {
        const w0 = packet[i] >>> 0;
        const status = (w0 >>> 20) & 0xf;
        if (status !== DATA_STATUS_MDS_PAYLOAD) continue;
        const payloadMdsId = (w0 >>> 8) & 0xff;
        if (payloadMdsId !== mdsId) continue;
        const byteCount = (w0 >>> 16) & 0x0f;
        const payloadBytes = new Uint8Array(12);
        const dv = new DataView(payloadBytes.buffer);
        dv.setUint32(0, packet[i + 1] >>> 0, false);
        dv.setUint32(4, packet[i + 2] >>> 0, false);
        dv.setUint32(8, packet[i + 3] >>> 0, false);
        const bytesToTake = byteCount > 0 ? Math.min(byteCount, payloadBytes.length) : payloadBytes.length;
        payloadParts.push(...payloadBytes.slice(0, bytesToTake));
      }

      const validByteCount = headerValidBytes || payloadParts.length;
      const chunkPayload = Uint8Array.from(payloadParts).slice(0, validByteCount);
      const chunk: MdsChunk = {
        messageId: mdsId,
        totalChunks,
        index: chunkIndex,
        validByteCount,
        payload: chunkPayload,
        manufacturerId,
        deviceId,
        subId1,
        subId2,
      };
      const evt: MdsEvent = { kind: "mds", group, messageId: mdsId, totalChunks, chunks: [chunk], timestamp };
      return evt;
    }
    const packets: Uint32Array[] = [];
    for (let i = 0; i < packet.length; i += 4) {
      packets.push(packet.subarray(i, i + 4));
    }
    try {
      const syx = reassembleSysEx8(packets);
      const evt: SysEx8Event = {
        kind: "sysex8",
        group: syx.group,
        manufacturerId: syx.manufacturerId,
        payload: syx.payload,
        timestamp,
      };
      const maybeCi = decodeMidiCiFromSysEx(evt);
      return maybeCi ?? evt;
    } catch {
      return { kind: "rawUMP", words: packet, timestamp } as RawUMPEvent;
    }
  }
  if (mt === 0xd) {
    if (packet.length < 4) return null;
    const statusClass = (word0 >>> 16) & 0xff;
    const status = (word0 >>> 8) & 0xff;
    const group = (word0 >>> 24) & 0xf;
    const addrByte = word0 & 0xff;
    const channel = (addrByte & 0x10) !== 0 ? addrByte & 0x0f : undefined;
    const textBytes = [
      (packet[1] >>> 24) & 0xff,
      (packet[1] >>> 16) & 0xff,
      (packet[1] >>> 8) & 0xff,
      packet[1] & 0xff,
      (packet[2] >>> 24) & 0xff,
      (packet[2] >>> 16) & 0xff,
      (packet[2] >>> 8) & 0xff,
      packet[2] & 0xff,
      (packet[3] >>> 24) & 0xff,
      (packet[3] >>> 16) & 0xff,
      (packet[3] >>> 8) & 0xff,
      packet[3] & 0xff,
    ];
    const decodedText = new TextDecoder().decode(Uint8Array.from(textBytes.filter(b => b !== 0)));

    if (statusClass === FLEX_CLASS_TEXT && status === FLEX_STATUS_TEXT) {
      const event: FlexTextEvent = { kind: "flexText", group, channel, text: decodedText, timestamp };
      return event;
    }
    if (statusClass === FLEX_CLASS_LYRIC && status === FLEX_STATUS_LYRIC) {
      const event: FlexLyricEvent = { kind: "flexLyric", group, channel, text: decodedText, timestamp };
      return event;
    }
    if (statusClass === FLEX_CLASS_RUBY && status === FLEX_STATUS_RUBY) {
      const event: FlexRubyEvent = { kind: "flexRuby", group, channel, ruby: decodedText, timestamp };
      return event;
    }
    if (statusClass !== FLEX_STATUS_CLASS) {
      return {
        kind: "rawUMP",
        words: packet,
        timestamp,
      } as RawUMPEvent;
    }
    switch (status) {
      case FLEX_STATUS_TEMPO: {
        const fixed = packet[1] >>> 0;
        const bpm = fixed / FLEX_TEMPO_SCALE;
        const event: FlexTempoEvent = {
          kind: "flexTempo",
          group,
          bpm,
          timestamp,
        };
        return event;
      }
      case FLEX_STATUS_TIMESIG: {
        const numerator = (packet[1] >>> 24) & 0xff;
        const denominatorPow2 = (packet[1] >>> 16) & 0xff;
        if (numerator < 1) {
          return null;
        }
        const event: FlexTimeSignatureEvent = {
          kind: "flexTimeSignature",
          group,
          channel,
          numerator,
          denominatorPow2,
          timestamp,
        };
        return event;
      }
      case FLEX_STATUS_KEY: {
        const event: FlexKeySignatureEvent = {
          kind: "flexKeySignature",
          group,
          channel,
          key: decodedText,
          timestamp,
        };
        return event;
      }
      case FLEX_STATUS_METRONOME: {
        const clicksPerBeat = ((packet[1] >>> 24) & 0xff) << 8 | ((packet[1] >>> 16) & 0xff);
        if (clicksPerBeat < 1) return null;
        const accentBytes = textBytes.slice(2); // remove clicksPerBeat bytes
        const accentPattern = new TextDecoder().decode(Uint8Array.from(accentBytes.filter(b => b !== 0)));
        const event: FlexMetronomeEvent = {
          kind: "flexMetronome",
          group,
          channel,
          clicksPerBeat,
          accentPattern,
          timestamp,
        };
        return event;
      }
      case FLEX_STATUS_CHORD: {
        const event: FlexChordNameEvent = {
          kind: "flexChordName",
          group,
          channel,
          chord: decodedText,
          timestamp,
        };
        return event;
      }
      default:
        return {
          kind: "rawUMP",
          words: packet,
          timestamp,
        } as RawUMPEvent;
    }
  }
  if (mt === UTILITY_MT) {
    const statusByte = (word0 >>> 16) & 0xff;
    const value = word0 & 0xffff;
    let status: UtilityEvent["status"];
    if (statusByte === 0x00) status = "noop";
    else if (statusByte === 0x01) status = "jrClock";
    else if (statusByte === 0x02) status = "jrTimestamp";
    else
      return {
        kind: "rawUMP",
        words: packet,
        timestamp,
      } as RawUMPEvent;
    const event: UtilityEvent = {
      kind: "utility",
      status,
      value,
      timestamp,
    };
    return event;
  }
  if (mt === MIDI1_CHANNEL_VOICE_MT) {
    const group = (word0 >>> 24) & 0xf;
    const status = (word0 >>> 16) & 0xff;
    const data1 = (word0 >>> 8) & 0xff;
    const data2 = word0 & 0xff;
    const event: Midi1ChannelVoiceEvent = {
      kind: "midi1ChannelVoice",
      group,
      status,
      data1: data1 || undefined,
      data2: data2 || undefined,
      timestamp,
    };
    return event;
  }
  if (mt === MIDI2_SYSTEM_MT) {
    const group = (word0 >>> 24) & 0xf;
    const statusByte = (word0 >>> 16) & 0xff;
    const allowedStatuses: Midi2SystemEvent["status"][] = [0xf1, 0xf2, 0xf3, 0xf6, 0xf8, 0xfa, 0xfb, 0xfc, 0xfe, 0xff];
    if (!allowedStatuses.includes(statusByte as Midi2SystemEvent["status"])) {
      return {
        kind: "rawUMP",
        words: packet,
        timestamp,
      } as RawUMPEvent;
    }
    const status = statusByte as Midi2SystemEvent["status"];
    const data1 = (word0 >>> 8) & 0xff;
    const data2 = word0 & 0xff;
    const needsData2 = status === 0xf2;
    const needsData1 = needsData2 || status === 0xf1 || status === 0xf3;
    const event: Midi2SystemEvent = {
      kind: "system",
      group,
      status,
      data1: needsData1 ? data1 & 0x7f : undefined,
      data2: needsData2 ? data2 & 0x7f : undefined,
      timestamp,
    };
    return event;
  }
  if (mt !== MIDI2_CHANNEL_VOICE_MT) {
    return {
      kind: "rawUMP",
      words: packet,
      timestamp,
    } as RawUMPEvent;
  }

  if (packet.length < 2) {
    return null;
  }

  const status = (word0 >>> 20) & 0xf;
  const group = (word0 >>> 24) & 0xf;
  const channel = (word0 >>> 16) & 0xf;
  const dataMsb = (word0 >>> 8) & 0xff;
  const dataLsb = word0 & 0xff;
  const dataWord = packet[1] >>> 0;

  switch (status) {
    case STATUS_RPN: {
      if (dataMsb >= 0x80 || dataLsb >= 0x80) {
        return null;
      }
      const event: Midi2RpnEvent = {
        kind: "rpn",
        group,
        channel,
        bank: dataMsb,
        index: dataLsb,
        value: dataWord,
        timestamp,
      };
      return event;
    }
    case STATUS_NRPN: {
      if (dataMsb >= 0x80 || dataLsb >= 0x80) {
        return null;
      }
      const event: Midi2NrpnEvent = {
        kind: "nrpn",
        group,
        channel,
        bank: dataMsb,
        index: dataLsb,
        value: dataWord,
        timestamp,
      };
      return event;
    }
    case STATUS_RPN_RELATIVE: {
      if (dataMsb >= 0x80 || dataLsb >= 0x80) {
        return null;
      }
      const event: Midi2RpnRelativeEvent = {
        kind: "rpnRelative",
        group,
        channel,
        bank: dataMsb,
        index: dataLsb,
        delta: (dataWord << 0) >> 0, // force signed int32
        timestamp,
      };
      return event;
    }
    case STATUS_NRPN_RELATIVE: {
      if (dataMsb >= 0x80 || dataLsb >= 0x80) {
        return null;
      }
      const event: Midi2NrpnRelativeEvent = {
        kind: "nrpnRelative",
        group,
        channel,
        bank: dataMsb,
        index: dataLsb,
        delta: (dataWord << 0) >> 0,
        timestamp,
      };
      return event;
    }
    case STATUS_NOTE_ON: {
      const velocity = (dataWord >>> 16) & 0xffff;
      const attributeData = dataWord & 0xffff;
      const event: Midi2NoteOnEvent = {
        kind: "noteOn",
        group,
        channel,
        note: dataMsb,
        velocity,
        attributeType: dataLsb,
        attributeData,
        timestamp,
      };
      return event;
    }
    case STATUS_NOTE_OFF: {
      const velocity = (dataWord >>> 16) & 0xffff;
      const attributeData = dataWord & 0xffff;
      const event: Midi2NoteOffEvent = {
        kind: "noteOff",
        group,
        channel,
        note: dataMsb,
        velocity,
        attributeType: dataLsb,
        attributeData,
        timestamp,
      };
      return event;
    }
    case STATUS_POLY_PRESSURE: {
      const event: Midi2PolyPressureEvent = {
        kind: "polyPressure",
        group,
        channel,
        note: dataMsb,
        pressure: dataWord,
        timestamp,
      };
      return event;
    }
    case STATUS_CONTROL_CHANGE: {
      const event: Midi2ControlChangeEvent = {
        kind: "controlChange",
        group,
        channel,
        controller: dataMsb,
        value: dataWord,
        timestamp,
      };
      return event;
    }
    case STATUS_PROGRAM_CHANGE: {
      const bankValid = (dataLsb & 0x80) !== 0;
      const bankMsb = bankValid ? (dataWord >>> 24) & 0xff : undefined;
      const bankLsb = bankValid ? (dataWord >>> 16) & 0xff : undefined;
      const event: Midi2ProgramChangeEvent = {
        kind: "programChange",
        group,
        channel,
        program: dataMsb,
        bankMsb,
        bankLsb,
        timestamp,
      };
      return event;
    }
    case STATUS_CHANNEL_PRESSURE: {
      const event: Midi2ChannelPressureEvent = {
        kind: "channelPressure",
        group,
        channel,
        pressure: dataWord,
        timestamp,
      };
      return event;
    }
    case STATUS_PITCH_BEND: {
      const event: Midi2PitchBendEvent = {
        kind: "pitchBend",
        group,
        channel,
        value: dataWord,
        timestamp,
      };
      return event;
    }
    case STATUS_PER_NOTE: {
      if (packet.length < 2) {
        return null;
      }
      if (dataWord === 0) {
        const event: Midi2PerNoteManagementEvent = {
          kind: "perNoteManagement",
          group,
          channel,
          note: dataMsb,
          detach: (dataLsb & 0x02) !== 0,
          reset: (dataLsb & 0x01) !== 0,
          timestamp,
        };
        return event;
      }
      if (dataLsb < 0x80) {
        const event: Midi2PerNoteRegisteredControllerEvent = {
          kind: "perNoteRegisteredController",
          group,
          channel,
          note: dataMsb,
          controller: dataLsb,
          value: dataWord,
          timestamp,
        };
        return event;
      }
      const event: Midi2PerNoteAssignableControllerEvent = {
        kind: "perNoteAssignableController",
        group,
        channel,
        note: dataMsb,
        controller: dataLsb,
        value: dataWord,
        timestamp,
      };
      return event;
    }
    case STATUS_PER_NOTE_PITCH: {
      assertDecodeRange("note", dataMsb, 0, 0x7f);
      const event: Midi2PerNotePitchBendEvent = {
        kind: "perNotePitchBend",
        group,
        channel,
        note: dataMsb,
        value: dataWord,
        timestamp,
      };
      return event;
    }
    default:
      return {
        kind: "rawUMP",
        words: packet,
        timestamp,
      } as RawUMPEvent;
  }
}
