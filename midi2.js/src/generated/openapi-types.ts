// Generated from midi2.full.openapi.json via scripts/generate-openapi-types.mjs.
// Do not edit by hand.
/* eslint-disable */

type UnknownRecord = Record<string, unknown>;

function isPlainObject(value: unknown): value is UnknownRecord {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function hasOnlyKeys(value: UnknownRecord, keys: string[]): boolean {
  return Object.keys(value).every(k => keys.includes(k));
}

export type ByteArray = number[];

export type ClipEnvelope = {
  "startOfClip"?: boolean;
  "endOfClip"?: boolean;
  "pickupBars"?: number;
};

export type DataMessageBody = {
  "kind": "sysex8" | "mds";
  "sysex8"?: {
  "manufacturerId": number[] | number[];
  "length": number;
  "data": number[];
};
  "mds"?: {
  "messageId": number;
  "totalChunks": number;
  "chunks": {
  "index": number;
  "validByteCount": number;
  "payload": number[];
}[];
};
};

export type DataMessageKind = "sysex8" | "mds";

// Clip configuration timing as used in MIDI Clip Files.
export type DeltaClockstampConfig = {
  "dctpq"?: number;
  "initialTempoMicrosecPerQN"?: number;
  "timeSignature"?: {
  "numerator"?: number;
  "denominatorPow2"?: number;
};
};

// Flex: Chord name at position.
export type Flex_ChordName = {
  "statusClass": 16;
  "status": 5;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "chord": string;
};
};

// Flex: Set Key Signature (e.g., 'C', 'Gm').
export type Flex_KeySignature = {
  "statusClass": 16;
  "status": 4;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "key": string;
};
};

// Flex Lyric.
export type Flex_Lyric = {
  "statusClass": 17;
  "status": 2;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "lyric": string;
};
};

// Flex: Set Metronome parameters.
export type Flex_Metronome = {
  "statusClass": 16;
  "status": 3;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "clicksPerBeat"?: number;
  "accentPattern"?: string;
};
};

// Flex Ruby (furigana).
export type Flex_Ruby = {
  "statusClass": 17;
  "status": 3;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "ruby": string;
};
};

// Flex: Set Tempo (heuristic mapping to BPM).
export type Flex_Tempo = {
  "statusClass": 16;
  "status": 1;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "bpm": number;
};
};

// Flex Text.
export type Flex_Text = {
  "statusClass": 17;
  "status": 1;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "text": string;
};
};

// Flex: Set Time Signature (n / 2^d).
export type Flex_TimeSignature = {
  "statusClass": 16;
  "status": 2;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "numerator": number;
  "denominatorPow2": number;
};
};

export type FlexDataBody = {
  "statusClass": 16;
  "status": 1;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "bpm": number;
};
} | {
  "statusClass": 16;
  "status": 2;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "numerator": number;
  "denominatorPow2": number;
};
} | {
  "statusClass": 16;
  "status": 3;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "clicksPerBeat"?: number;
  "accentPattern"?: string;
};
} | {
  "statusClass": 16;
  "status": 4;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "key": string;
};
} | {
  "statusClass": 16;
  "status": 5;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "chord": string;
};
} | {
  "statusClass": 17;
  "status": 1;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "text": string;
};
} | {
  "statusClass": 17;
  "status": 2;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "lyric": string;
};
} | {
  "statusClass": 17;
  "status": 3;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "ruby": string;
};
};

export type FunctionBlockNameNotification = {
  "functionBlock": number;
  "name": string;
};

// MIDI Group (0-15). Utility (0x0) and Stream (0xF) are groupless in v1.1+; set 0.
export type Group = Uint4;

export type Int32 = number;

// Messages share this body, with relevant fields set based on status.
export type Midi1ChannelVoiceBody = {
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14;
  "channel": number;
  "noteNumber"?: number;
  "velocity7"?: number;
  "pressure7"?: number;
  "control"?: number;
  "value7"?: number;
  "program"?: number;
  "pitchBend14"?: number;
};

// 0x8..0xE
export type Midi1StatusNibble = 8 | 9 | 10 | 11 | 12 | 13 | 14;

export type Midi2_AssignPerNoteController = {
  "noteNumber": number;
  "assignPerNoteCtrlIndex": number;
  "assignPerNoteCtrlValue32": number;
};

// Status 0xD (Channel Pressure).
export type Midi2_ChannelPressure = {
  "channelPressure32": number;
};

// Status 0xB (CC).
export type Midi2_ControlChange = {
  "control": number;
  "controlValue32": number;
};

// Status 0x8 (Note Off).
export type Midi2_NoteOff = {
  "noteNumber": number;
  "velocity16": number;
  "attributeType"?: number;
  "attributeData16"?: number;
};

// Status 0x9 (Note On).
export type Midi2_NoteOn = {
  "noteNumber": number;
  "velocity16": number;
  "attributeType"?: number;
  "attributeData16"?: number;
};

// Assignable Controller (absolute).
export type Midi2_NRPN = {
  "nrpnIndexMsb": number;
  "nrpnIndexLsb": number;
  "nrpnData32": number;
};

// Assignable Controller (relative).
export type Midi2_NRPNRelative = {
  "nrpnIndexMsb": number;
  "nrpnIndexLsb": number;
  "nrpnDelta32": number;
};

// Per-Note Management (D/S flags).
export type Midi2_PerNoteManagement = {
  "noteNumber": number;
  "detach": boolean;
  "reset": boolean;
};

// Status 0xE (Pitch Bend).
export type Midi2_PitchBend = {
  "pitchBend32": number;
};

// Status 0xA (Polyphonic Key Pressure).
export type Midi2_PolyPressure = {
  "noteNumber": number;
  "polyPressure32": number;
};

// Status 0xC (Program Change).
export type Midi2_ProgramChange = {
  "program": number;
  "bankMsb"?: number;
  "bankLsb"?: number;
  "bankValid"?: boolean;
};

export type Midi2_RegPerNoteController = {
  "noteNumber": number;
  "regPerNoteCtrlIndex": number;
  "regPerNoteCtrlValue32": number;
};

// Registered Controller (absolute).
export type Midi2_RPN = {
  "rpnIndexMsb": number;
  "rpnIndexLsb": number;
  "rpnData32": number;
};

// Registered Controller (relative).
export type Midi2_RPNRelative = {
  "rpnIndexMsb": number;
  "rpnIndexLsb": number;
  "rpnDelta32": number;
};

// Only fields relevant to the specific status are present.
export type Midi2ChannelVoiceBody = {
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
  "noteNumber"?: number;
  "velocity16"?: number;
  "attributeType"?: number;
  "attributeData16"?: number;
  "polyPressure32"?: number;
  "control"?: number;
  "controlValue32"?: number;
  "program"?: number;
  "bankMsb"?: number;
  "bankLsb"?: number;
  "bankValid"?: boolean;
  "channelPressure32"?: number;
  "pitchBend32"?: number;
  "rpnIndexMsb"?: number;
  "rpnIndexLsb"?: number;
  "rpnData32"?: number;
  "nrpnIndexMsb"?: number;
  "nrpnIndexLsb"?: number;
  "nrpnData32"?: number;
  "rpnDelta32"?: number;
  "nrpnDelta32"?: number;
  "perNoteMgmt"?: {
  "noteNumber"?: number;
  "detach"?: boolean;
  "reset"?: boolean;
};
  "regPerNoteCtrlIndex"?: number;
  "regPerNoteCtrlValue32"?: number;
  "assignPerNoteCtrlIndex"?: number;
  "assignPerNoteCtrlValue32"?: number;
};

export type Midi2ChannelVoiceVariants = ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 8;
  "body"?: {
  "noteNumber": number;
  "velocity16": number;
  "attributeType"?: number;
  "attributeData16"?: number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 9;
  "body"?: {
  "noteNumber": number;
  "velocity16": number;
  "attributeType"?: number;
  "attributeData16"?: number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 10;
  "body"?: {
  "noteNumber": number;
  "polyPressure32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 11;
  "body"?: {
  "control": number;
  "controlValue32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 12;
  "body"?: {
  "program": number;
  "bankMsb"?: number;
  "bankLsb"?: number;
  "bankValid"?: boolean;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 13;
  "body"?: {
  "channelPressure32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 14;
  "body"?: {
  "pitchBend32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 15;
  "body"?: {
  "rpnIndexMsb": number;
  "rpnIndexLsb": number;
  "rpnData32": number;
} | {
  "nrpnIndexMsb": number;
  "nrpnIndexLsb": number;
  "nrpnData32": number;
} | {
  "rpnIndexMsb": number;
  "rpnIndexLsb": number;
  "rpnDelta32": number;
} | {
  "nrpnIndexMsb": number;
  "nrpnIndexLsb": number;
  "nrpnDelta32": number;
} | {
  "noteNumber": number;
  "detach": boolean;
  "reset": boolean;
} | {
  "noteNumber": number;
  "regPerNoteCtrlIndex": number;
  "regPerNoteCtrlValue32": number;
} | {
  "noteNumber": number;
  "assignPerNoteCtrlIndex": number;
  "assignPerNoteCtrlValue32": number;
};
});

export type Midi2StatusNibble = 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;

export type MidiCiAckNakBody = {
  "ack"?: boolean;
  "statusCode"?: number;
  "message"?: string;
};

export type MidiCiDiscoveryBody = {
  "muid"?: number;
  "manufacturerId"?: number[] | number[];
  "deviceFamily"?: number;
  "deviceModel"?: number;
  "softwareRev"?: number;
  "categories"?: {
  "profiles"?: boolean;
  "propertyExchange"?: boolean;
  "processInquiry"?: boolean;
};
  "maxSysEx"?: number;
};

// SysEx(7/8) payload for MIDI-CI transactions.
export type MidiCiEnvelope = {
  "scope": "nonRealtime" | "realtime";
  "subId1": 13;
  "subId2": number;
  "version": number;
  "body": {
  "muid"?: number;
  "manufacturerId"?: number[] | number[];
  "deviceFamily"?: number;
  "deviceModel"?: number;
  "softwareRev"?: number;
  "categories"?: {
  "profiles"?: boolean;
  "propertyExchange"?: boolean;
  "processInquiry"?: boolean;
};
  "maxSysEx"?: number;
} | {
  "command"?: "inquiry" | "reply" | "addedReport" | "removedReport" | "setOn" | "setOff" | "enabledReport" | "disabledReport" | "detailsInquiry" | "detailsReply" | "profileSpecificData";
  "profileId"?: string;
  "target"?: "channel" | "group" | "functionBlock";
  "channels"?: number[];
  "details"?: {
};
} | {
  "command"?: "capInquiry" | "capReply" | "get" | "getReply" | "set" | "setReply" | "subscribe" | "subscribeReply" | "notify" | "terminate";
  "subscriptionId"?: string;
  "requestId"?: number;
  "encoding"?: "json" | "binary" | "json+zlib" | "binary+zlib" | "mcoded7";
  "header"?: {
  "resource"?: string;
  "resId"?: number;
  "encoding"?: "json" | "binary" | "json+zlib" | "binary+zlib" | "mcoded7";
  "flowControl"?: boolean;
  "status"?: number;
  "message"?: string;
  "cacheTime"?: number;
  "mediaType"?: string;
};
  "data"?: {
} | number[];
  "statusCodes"?: 200 | 201 | 341 | 342 | 343 | 400 | 403 | 404 | 405 | 406 | 407 | 413 | 415 | 445 | 500[];
  "timeoutStatus"?: 100 | 408;
  "flowControlError"?: 406 | 407;
  "deltaClockstampTicksPerQuarterNote"?: number;
  "cacheTime"?: number;
  "flowControlAck"?: {
  "requestId"?: number;
  "chunkNumber"?: number;
  "messageLength"?: number;
  "status"?: 17;
};
  "flowControlNak"?: {
  "status"?: 18;
  "chunkNumber"?: number;
};
  "subscriptionCommand"?: "start" | "partial" | "full" | "notify" | "end";
} | {
  "command"?: "capInquiry" | "capReply" | "messageReport" | "messageReportReply" | "endReport";
  "deviceId"?: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 126 | 127;
  "messageDataControl"?: 0 | 1 | 127;
  "systemMessages"?: {
  "mtcQuarterFrame"?: boolean;
  "songPosition"?: boolean;
  "songSelect"?: boolean;
};
  "channelControllerMessages"?: {
  "pitchBend"?: boolean;
  "controlChange"?: boolean;
  "registeredController"?: boolean;
  "assignableController"?: boolean;
  "programChange"?: boolean;
  "channelPressure"?: boolean;
};
  "noteDataMessages"?: {
  "notes"?: boolean;
  "polyPressure"?: boolean;
  "perNotePitchBend"?: boolean;
  "registeredPerNoteController"?: boolean;
  "assignablePerNoteController"?: boolean;
};
  "supportedFeatures"?: {
  "messageReport"?: boolean;
};
} | {
  "ack"?: boolean;
  "statusCode"?: number;
  "message"?: string;
};
};

export type MidiCiProcessInquiryBody = {
  "command"?: "capInquiry" | "capReply" | "messageReport" | "messageReportReply" | "endReport";
  "deviceId"?: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 126 | 127;
  "messageDataControl"?: 0 | 1 | 127;
  "systemMessages"?: {
  "mtcQuarterFrame"?: boolean;
  "songPosition"?: boolean;
  "songSelect"?: boolean;
};
  "channelControllerMessages"?: {
  "pitchBend"?: boolean;
  "controlChange"?: boolean;
  "registeredController"?: boolean;
  "assignableController"?: boolean;
  "programChange"?: boolean;
  "channelPressure"?: boolean;
};
  "noteDataMessages"?: {
  "notes"?: boolean;
  "polyPressure"?: boolean;
  "perNotePitchBend"?: boolean;
  "registeredPerNoteController"?: boolean;
  "assignablePerNoteController"?: boolean;
};
  "supportedFeatures"?: {
  "messageReport"?: boolean;
};
};

export type MidiCiProfilesBody = {
  "command"?: "inquiry" | "reply" | "addedReport" | "removedReport" | "setOn" | "setOff" | "enabledReport" | "disabledReport" | "detailsInquiry" | "detailsReply" | "profileSpecificData";
  "profileId"?: string;
  "target"?: "channel" | "group" | "functionBlock";
  "channels"?: number[];
  "details"?: {
};
};

export type MidiCiPropertyExchangeBody = {
  "command"?: "capInquiry" | "capReply" | "get" | "getReply" | "set" | "setReply" | "subscribe" | "subscribeReply" | "notify" | "terminate";
  "subscriptionId"?: string;
  "requestId"?: number;
  "encoding"?: "json" | "binary" | "json+zlib" | "binary+zlib" | "mcoded7";
  "header"?: {
  "resource"?: string;
  "resId"?: number;
  "encoding"?: "json" | "binary" | "json+zlib" | "binary+zlib" | "mcoded7";
  "flowControl"?: boolean;
  "status"?: number;
  "message"?: string;
  "cacheTime"?: number;
  "mediaType"?: string;
};
  "data"?: {
} | number[];
  "statusCodes"?: 200 | 201 | 341 | 342 | 343 | 400 | 403 | 404 | 405 | 406 | 407 | 413 | 415 | 445 | 500[];
  "timeoutStatus"?: 100 | 408;
  "flowControlError"?: 406 | 407;
  "deltaClockstampTicksPerQuarterNote"?: number;
  "cacheTime"?: number;
  "flowControlAck"?: {
  "requestId"?: number;
  "chunkNumber"?: number;
  "messageLength"?: number;
  "status"?: 17;
};
  "flowControlNak"?: {
  "status"?: 18;
  "chunkNumber"?: number;
};
  "subscriptionCommand"?: "start" | "partial" | "full" | "notify" | "end";
};

export type NoteAttributeType = number;

// Endpoint discovery, protocol selection, and FB info.
export type StreamBody = {
  "opcode": 0 | 1 | 2 | 3 | 4 | 5 | 6 | 16 | 17 | 18 | 32 | 33;
  "endpointDiscovery"?: {
  "majorVersion"?: number;
  "minorVersion"?: number;
  "maxGroups"?: number;
  "filter"?: {
  "endpointInfo"?: boolean;
  "deviceIdentity"?: boolean;
  "endpointName"?: boolean;
  "productInstanceId"?: boolean;
  "streamConfig"?: boolean;
};
};
  "endpointInfoNotification"?: {
  "staticFunctionBlocks"?: boolean;
  "numberOfFunctionBlocks"?: number;
  "umpVersionMajor"?: number;
  "umpVersionMinor"?: number;
  "midi2Supported"?: boolean;
  "midi1Supported"?: boolean;
  "jrTimestampsRx"?: boolean;
  "jrTimestampsTx"?: boolean;
};
  "deviceIdentityNotification"?: {
  "manufacturerId"?: number[] | number[];
  "deviceFamily"?: number;
  "deviceModel"?: number;
  "softwareRevision"?: number;
};
  "endpointNameNotification"?: {
  "name": string;
};
  "productInstanceIdNotification"?: {
  "productInstanceId": string;
};
  "streamConfigRequest"?: {
  "protocol"?: "midi1" | "midi2";
  "jrTimestampsTx"?: boolean;
  "jrTimestampsRx"?: boolean;
};
  "streamConfigNotification"?: {
  "protocol"?: "midi1" | "midi2";
  "jrTimestampsTx"?: boolean;
  "jrTimestampsRx"?: boolean;
};
  "functionBlockDiscovery"?: {
  "filterBitmap"?: number;
};
  "functionBlockInfo"?: {
  "index"?: number;
  "firstGroup"?: number;
  "groupCount"?: number;
  "active"?: boolean;
  "direction"?: 0 | 1 | 2 | 3;
  "midi1Bandwidth"?: 0 | 1 | 2;
};
  "processInquiry"?: {
  "functionBlock"?: number;
  "part"?: number;
};
  "processInquiryReply"?: {
  "functionBlock"?: number;
  "part"?: number;
};
};

export type StreamOpcode = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 16 | 17 | 18 | 32 | 33;

// 7-bit clean stream framed in 32-bit UMP words (up to 6 bytes per word).
export type SysEx7Body = {
  "manufacturerId": number[] | number[];
  "packets": {
  "streamStatus": "single" | "start" | "continue" | "end";
  "payload": number[];
}[];
};

export type SysEx7Packet = {
  "streamStatus": "single" | "start" | "continue" | "end";
  "payload": number[];
};

// UMP 0x1 System Common & Real-Time.
export type SystemCommonRealtimeBody = {
  "status": 241 | 242 | 243 | 246 | 248 | 250 | 251 | 252 | 254 | 255;
  "data1"?: number;
  "data2"?: number;
};

// MIDI System Common/Real-Time per UMP.
export type SystemStatus = 241 | 242 | 243 | 246 | 248 | 250 | 251 | 252 | 254 | 255;

export type Uint14 = number;

export type Uint16 = number;

export type Uint21 = number;

export type Uint28 = number;

export type Uint32 = number;

export type Uint4 = number;

export type Uint7 = number;

export type Uint8 = number;

// 128-bit UMP header for Data (SysEx8/MDS) and Flex Data.
export type UmpHeader128 = {
  "messageType": 5 | 13;
  "group"?: Uint4;
};

// Common 32-bit UMP header (messageType + optional group).
export type UmpHeader32 = {
  "messageType": 0 | 1 | 2 | 3 | 15;
  "group"?: Uint4;
};

// 64-bit UMP header for MIDI 2.0 Channel Voice.
export type UmpHeader64 = {
  "messageType": 4;
  "group": Uint4;
  "statusNibble": number;
  "channel": number;
};

// UMP Message Type nibble: 0=Utility,1=System,2=MIDI1 Ch Voice,3=SysEx7,4=MIDI2 Ch Voice,5=SysEx8/MDS,13=Flex,15=Stream.
export type UmpMessageType = 0 | 1 | 2 | 3 | 4 | 5 | 13 | 15;

export type UmpPacket = {
  "messageType": 0 | 1 | 2 | 3 | 15;
  "group"?: Uint4;
  "body": {
  "opcode": 0 | 1 | 2;
  "jrClock"?: {
  "timestamp32": number;
};
  "jrTimestamp"?: {
  "time15": number;
};
} | {
  "status": 241 | 242 | 243 | 246 | 248 | 250 | 251 | 252 | 254 | 255;
  "data1"?: number;
  "data2"?: number;
} | {
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14;
  "channel": number;
  "noteNumber"?: number;
  "velocity7"?: number;
  "pressure7"?: number;
  "control"?: number;
  "value7"?: number;
  "program"?: number;
  "pitchBend14"?: number;
} | {
  "manufacturerId": number[] | number[];
  "packets": {
  "streamStatus": "single" | "start" | "continue" | "end";
  "payload": number[];
}[];
} | {
  "opcode": 0 | 1 | 2 | 3 | 4 | 5 | 6 | 16 | 17 | 18 | 32 | 33;
  "endpointDiscovery"?: {
  "majorVersion"?: number;
  "minorVersion"?: number;
  "maxGroups"?: number;
  "filter"?: {
  "endpointInfo"?: boolean;
  "deviceIdentity"?: boolean;
  "endpointName"?: boolean;
  "productInstanceId"?: boolean;
  "streamConfig"?: boolean;
};
};
  "endpointInfoNotification"?: {
  "staticFunctionBlocks"?: boolean;
  "numberOfFunctionBlocks"?: number;
  "umpVersionMajor"?: number;
  "umpVersionMinor"?: number;
  "midi2Supported"?: boolean;
  "midi1Supported"?: boolean;
  "jrTimestampsRx"?: boolean;
  "jrTimestampsTx"?: boolean;
};
  "deviceIdentityNotification"?: {
  "manufacturerId"?: number[] | number[];
  "deviceFamily"?: number;
  "deviceModel"?: number;
  "softwareRevision"?: number;
};
  "endpointNameNotification"?: {
  "name": string;
};
  "productInstanceIdNotification"?: {
  "productInstanceId": string;
};
  "streamConfigRequest"?: {
  "protocol"?: "midi1" | "midi2";
  "jrTimestampsTx"?: boolean;
  "jrTimestampsRx"?: boolean;
};
  "streamConfigNotification"?: {
  "protocol"?: "midi1" | "midi2";
  "jrTimestampsTx"?: boolean;
  "jrTimestampsRx"?: boolean;
};
  "functionBlockDiscovery"?: {
  "filterBitmap"?: number;
};
  "functionBlockInfo"?: {
  "index"?: number;
  "firstGroup"?: number;
  "groupCount"?: number;
  "active"?: boolean;
  "direction"?: 0 | 1 | 2 | 3;
  "midi1Bandwidth"?: 0 | 1 | 2;
};
  "processInquiry"?: {
  "functionBlock"?: number;
  "part"?: number;
};
  "processInquiryReply"?: {
  "functionBlock"?: number;
  "part"?: number;
};
};
} | {
  "messageType": 4;
  "group": Uint4;
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
  "body": ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 8;
  "body"?: {
  "noteNumber": number;
  "velocity16": number;
  "attributeType"?: number;
  "attributeData16"?: number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 9;
  "body"?: {
  "noteNumber": number;
  "velocity16": number;
  "attributeType"?: number;
  "attributeData16"?: number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 10;
  "body"?: {
  "noteNumber": number;
  "polyPressure32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 11;
  "body"?: {
  "control": number;
  "controlValue32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 12;
  "body"?: {
  "program": number;
  "bankMsb"?: number;
  "bankLsb"?: number;
  "bankValid"?: boolean;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 13;
  "body"?: {
  "channelPressure32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 14;
  "body"?: {
  "pitchBend32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 15;
  "body"?: {
  "rpnIndexMsb": number;
  "rpnIndexLsb": number;
  "rpnData32": number;
} | {
  "nrpnIndexMsb": number;
  "nrpnIndexLsb": number;
  "nrpnData32": number;
} | {
  "rpnIndexMsb": number;
  "rpnIndexLsb": number;
  "rpnDelta32": number;
} | {
  "nrpnIndexMsb": number;
  "nrpnIndexLsb": number;
  "nrpnDelta32": number;
} | {
  "noteNumber": number;
  "detach": boolean;
  "reset": boolean;
} | {
  "noteNumber": number;
  "regPerNoteCtrlIndex": number;
  "regPerNoteCtrlValue32": number;
} | {
  "noteNumber": number;
  "assignPerNoteCtrlIndex": number;
  "assignPerNoteCtrlValue32": number;
};
});
} | {
  "messageType": 5 | 13;
  "group"?: Uint4;
  "body": {
  "kind": "sysex8" | "mds";
  "sysex8"?: {
  "manufacturerId": number[] | number[];
  "length": number;
  "data": number[];
};
  "mds"?: {
  "messageId": number;
  "totalChunks": number;
  "chunks": {
  "index": number;
  "validByteCount": number;
  "payload": number[];
}[];
};
} | {
  "statusClass": 16;
  "status": 1;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "bpm": number;
};
} | {
  "statusClass": 16;
  "status": 2;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "numerator": number;
  "denominatorPow2": number;
};
} | {
  "statusClass": 16;
  "status": 3;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "clicksPerBeat"?: number;
  "accentPattern"?: string;
};
} | {
  "statusClass": 16;
  "status": 4;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "key": string;
};
} | {
  "statusClass": 16;
  "status": 5;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "chord": string;
};
} | {
  "statusClass": 17;
  "status": 1;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "text": string;
};
} | {
  "statusClass": 17;
  "status": 2;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "lyric": string;
};
} | {
  "statusClass": 17;
  "status": 3;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "ruby": string;
};
};
};

export type UmpPacket128 = {
  "messageType": 5 | 13;
  "group"?: Uint4;
  "body": {
  "kind": "sysex8" | "mds";
  "sysex8"?: {
  "manufacturerId": number[] | number[];
  "length": number;
  "data": number[];
};
  "mds"?: {
  "messageId": number;
  "totalChunks": number;
  "chunks": {
  "index": number;
  "validByteCount": number;
  "payload": number[];
}[];
};
} | {
  "statusClass": 16;
  "status": 1;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "bpm": number;
};
} | {
  "statusClass": 16;
  "status": 2;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "numerator": number;
  "denominatorPow2": number;
};
} | {
  "statusClass": 16;
  "status": 3;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "clicksPerBeat"?: number;
  "accentPattern"?: string;
};
} | {
  "statusClass": 16;
  "status": 4;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "key": string;
};
} | {
  "statusClass": 16;
  "status": 5;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "chord": string;
};
} | {
  "statusClass": 17;
  "status": 1;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "text": string;
};
} | {
  "statusClass": 17;
  "status": 2;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "lyric": string;
};
} | {
  "statusClass": 17;
  "status": 3;
  "address"?: {
  "scope"?: "group" | "channel";
  "group"?: number;
  "channel"?: number;
};
  "data": {
  "ruby": string;
};
};
};

export type UmpPacket32 = {
  "messageType": 0 | 1 | 2 | 3 | 15;
  "group"?: Uint4;
  "body": {
  "opcode": 0 | 1 | 2;
  "jrClock"?: {
  "timestamp32": number;
};
  "jrTimestamp"?: {
  "time15": number;
};
} | {
  "status": 241 | 242 | 243 | 246 | 248 | 250 | 251 | 252 | 254 | 255;
  "data1"?: number;
  "data2"?: number;
} | {
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14;
  "channel": number;
  "noteNumber"?: number;
  "velocity7"?: number;
  "pressure7"?: number;
  "control"?: number;
  "value7"?: number;
  "program"?: number;
  "pitchBend14"?: number;
} | {
  "manufacturerId": number[] | number[];
  "packets": {
  "streamStatus": "single" | "start" | "continue" | "end";
  "payload": number[];
}[];
} | {
  "opcode": 0 | 1 | 2 | 3 | 4 | 5 | 6 | 16 | 17 | 18 | 32 | 33;
  "endpointDiscovery"?: {
  "majorVersion"?: number;
  "minorVersion"?: number;
  "maxGroups"?: number;
  "filter"?: {
  "endpointInfo"?: boolean;
  "deviceIdentity"?: boolean;
  "endpointName"?: boolean;
  "productInstanceId"?: boolean;
  "streamConfig"?: boolean;
};
};
  "endpointInfoNotification"?: {
  "staticFunctionBlocks"?: boolean;
  "numberOfFunctionBlocks"?: number;
  "umpVersionMajor"?: number;
  "umpVersionMinor"?: number;
  "midi2Supported"?: boolean;
  "midi1Supported"?: boolean;
  "jrTimestampsRx"?: boolean;
  "jrTimestampsTx"?: boolean;
};
  "deviceIdentityNotification"?: {
  "manufacturerId"?: number[] | number[];
  "deviceFamily"?: number;
  "deviceModel"?: number;
  "softwareRevision"?: number;
};
  "endpointNameNotification"?: {
  "name": string;
};
  "productInstanceIdNotification"?: {
  "productInstanceId": string;
};
  "streamConfigRequest"?: {
  "protocol"?: "midi1" | "midi2";
  "jrTimestampsTx"?: boolean;
  "jrTimestampsRx"?: boolean;
};
  "streamConfigNotification"?: {
  "protocol"?: "midi1" | "midi2";
  "jrTimestampsTx"?: boolean;
  "jrTimestampsRx"?: boolean;
};
  "functionBlockDiscovery"?: {
  "filterBitmap"?: number;
};
  "functionBlockInfo"?: {
  "index"?: number;
  "firstGroup"?: number;
  "groupCount"?: number;
  "active"?: boolean;
  "direction"?: 0 | 1 | 2 | 3;
  "midi1Bandwidth"?: 0 | 1 | 2;
};
  "processInquiry"?: {
  "functionBlock"?: number;
  "part"?: number;
};
  "processInquiryReply"?: {
  "functionBlock"?: number;
  "part"?: number;
};
};
};

export type UmpPacket64 = {
  "messageType": 4;
  "group": Uint4;
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
  "body": ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 8;
  "body"?: {
  "noteNumber": number;
  "velocity16": number;
  "attributeType"?: number;
  "attributeData16"?: number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 9;
  "body"?: {
  "noteNumber": number;
  "velocity16": number;
  "attributeType"?: number;
  "attributeData16"?: number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 10;
  "body"?: {
  "noteNumber": number;
  "polyPressure32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 11;
  "body"?: {
  "control": number;
  "controlValue32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 12;
  "body"?: {
  "program": number;
  "bankMsb"?: number;
  "bankLsb"?: number;
  "bankValid"?: boolean;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 13;
  "body"?: {
  "channelPressure32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 14;
  "body"?: {
  "pitchBend32": number;
};
}) | ({
  "statusNibble": 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15;
  "channel": number;
} & {
  "statusNibble"?: 15;
  "body"?: {
  "rpnIndexMsb": number;
  "rpnIndexLsb": number;
  "rpnData32": number;
} | {
  "nrpnIndexMsb": number;
  "nrpnIndexLsb": number;
  "nrpnData32": number;
} | {
  "rpnIndexMsb": number;
  "rpnIndexLsb": number;
  "rpnDelta32": number;
} | {
  "nrpnIndexMsb": number;
  "nrpnIndexLsb": number;
  "nrpnDelta32": number;
} | {
  "noteNumber": number;
  "detach": boolean;
  "reset": boolean;
} | {
  "noteNumber": number;
  "regPerNoteCtrlIndex": number;
  "regPerNoteCtrlValue32": number;
} | {
  "noteNumber": number;
  "assignPerNoteCtrlIndex": number;
  "assignPerNoteCtrlValue32": number;
};
});
};

// UMP Type 0x0 Utility messages (groupless).
export type UtilityBody = {
  "opcode": 0 | 1 | 2;
  "jrClock"?: {
  "timestamp32": number;
};
  "jrTimestamp"?: {
  "time15": number;
};
};

// 0=NOOP,1=JR Clock,2=JR Timestamp
export type UtilityOpcode = 0 | 1 | 2;

export function isByteArray(value: unknown): value is ByteArray {
  return (Array.isArray(value) && true && true && value.every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)));
}

export function isClipEnvelope(value: unknown): value is ClipEnvelope {
  return isPlainObject(value) && ("startOfClip" in value ? typeof value["startOfClip"] === "boolean" : true) && ("endOfClip" in value ? typeof value["endOfClip"] === "boolean" : true) && ("pickupBars" in value ? (typeof value["pickupBars"] === "number" && Number.isFinite(value["pickupBars"]) && true && true) : true) && hasOnlyKeys(value, ["startOfClip","endOfClip","pickupBars"]);
}

export function isDataMessageBody(value: unknown): value is DataMessageBody {
  return isPlainObject(value) && ("kind" in value && (value["kind"] === "sysex8" || value["kind"] === "mds")) && ("sysex8" in value ? isPlainObject(value["sysex8"]) && ("manufacturerId" in value["sysex8"] && (((Array.isArray(value["sysex8"]["manufacturerId"]) && value["sysex8"]["manufacturerId"].length >= 1 && value["sysex8"]["manufacturerId"].length <= 1 && value["sysex8"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) || ((Array.isArray(value["sysex8"]["manufacturerId"]) && value["sysex8"]["manufacturerId"].length >= 3 && value["sysex8"]["manufacturerId"].length <= 3 && value["sysex8"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))))) && ("length" in value["sysex8"] && (typeof value["sysex8"]["length"] === "number" && Number.isInteger(value["sysex8"]["length"]) && value["sysex8"]["length"] >= 0 && value["sysex8"]["length"] <= 268435455)) && ("data" in value["sysex8"] && (Array.isArray(value["sysex8"]["data"]) && true && true && value["sysex8"]["data"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) && hasOnlyKeys(value["sysex8"], ["manufacturerId","length","data"]) : true) && ("mds" in value ? isPlainObject(value["mds"]) && ("messageId" in value["mds"] && (typeof value["mds"]["messageId"] === "number" && Number.isInteger(value["mds"]["messageId"]) && value["mds"]["messageId"] >= 0 && value["mds"]["messageId"] <= 65535)) && ("totalChunks" in value["mds"] && (typeof value["mds"]["totalChunks"] === "number" && Number.isInteger(value["mds"]["totalChunks"]) && value["mds"]["totalChunks"] >= 0 && value["mds"]["totalChunks"] <= 65535)) && ("chunks" in value["mds"] && (Array.isArray(value["mds"]["chunks"]) && true && true && value["mds"]["chunks"].every(item => isPlainObject(item) && ("index" in item && (typeof item["index"] === "number" && Number.isInteger(item["index"]) && item["index"] >= 0 && item["index"] <= 65535)) && ("validByteCount" in item && (typeof item["validByteCount"] === "number" && Number.isInteger(item["validByteCount"]) && item["validByteCount"] >= 0 && item["validByteCount"] <= 255)) && ("payload" in item && (Array.isArray(item["payload"]) && true && item["payload"].length <= 14 && item["payload"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) && hasOnlyKeys(item, ["index","validByteCount","payload"])))) && hasOnlyKeys(value["mds"], ["messageId","totalChunks","chunks"]) : true) && hasOnlyKeys(value, ["kind","sysex8","mds"]);
}

export function isDataMessageKind(value: unknown): value is DataMessageKind {
  return (value === "sysex8" || value === "mds");
}

export function isDeltaClockstampConfig(value: unknown): value is DeltaClockstampConfig {
  return isPlainObject(value) && ("dctpq" in value ? (typeof value["dctpq"] === "number" && Number.isInteger(value["dctpq"]) && value["dctpq"] >= 0 && value["dctpq"] <= 65535) : true) && ("initialTempoMicrosecPerQN" in value ? (typeof value["initialTempoMicrosecPerQN"] === "number" && Number.isInteger(value["initialTempoMicrosecPerQN"]) && value["initialTempoMicrosecPerQN"] >= 0 && value["initialTempoMicrosecPerQN"] <= 4294967295) : true) && ("timeSignature" in value ? isPlainObject(value["timeSignature"]) && ("numerator" in value["timeSignature"] ? (typeof value["timeSignature"]["numerator"] === "number" && Number.isInteger(value["timeSignature"]["numerator"]) && value["timeSignature"]["numerator"] >= 1 && true) : true) && ("denominatorPow2" in value["timeSignature"] ? (typeof value["timeSignature"]["denominatorPow2"] === "number" && Number.isInteger(value["timeSignature"]["denominatorPow2"]) && value["timeSignature"]["denominatorPow2"] >= 0 && true) : true) && hasOnlyKeys(value["timeSignature"], ["numerator","denominatorPow2"]) : true) && hasOnlyKeys(value, ["dctpq","initialTempoMicrosecPerQN","timeSignature"]);
}

export function isFlex_ChordName(value: unknown): value is Flex_ChordName {
  return isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 16) && ("status" in value && value["status"] === 5) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("chord" in value["data"] && typeof value["data"]["chord"] === "string") && hasOnlyKeys(value["data"], ["chord"])) && hasOnlyKeys(value, ["statusClass","status","address","data"]);
}

export function isFlex_KeySignature(value: unknown): value is Flex_KeySignature {
  return isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 16) && ("status" in value && value["status"] === 4) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("key" in value["data"] && typeof value["data"]["key"] === "string") && hasOnlyKeys(value["data"], ["key"])) && hasOnlyKeys(value, ["statusClass","status","address","data"]);
}

export function isFlex_Lyric(value: unknown): value is Flex_Lyric {
  return isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 17) && ("status" in value && value["status"] === 2) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("lyric" in value["data"] && typeof value["data"]["lyric"] === "string") && hasOnlyKeys(value["data"], ["lyric"])) && hasOnlyKeys(value, ["statusClass","status","address","data"]);
}

export function isFlex_Metronome(value: unknown): value is Flex_Metronome {
  return isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 16) && ("status" in value && value["status"] === 3) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("clicksPerBeat" in value["data"] ? (typeof value["data"]["clicksPerBeat"] === "number" && Number.isInteger(value["data"]["clicksPerBeat"]) && value["data"]["clicksPerBeat"] >= 1 && true) : true) && ("accentPattern" in value["data"] ? typeof value["data"]["accentPattern"] === "string" : true) && hasOnlyKeys(value["data"], ["clicksPerBeat","accentPattern"])) && hasOnlyKeys(value, ["statusClass","status","address","data"]);
}

export function isFlex_Ruby(value: unknown): value is Flex_Ruby {
  return isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 17) && ("status" in value && value["status"] === 3) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("ruby" in value["data"] && typeof value["data"]["ruby"] === "string") && hasOnlyKeys(value["data"], ["ruby"])) && hasOnlyKeys(value, ["statusClass","status","address","data"]);
}

export function isFlex_Tempo(value: unknown): value is Flex_Tempo {
  return isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 16) && ("status" in value && value["status"] === 1) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("bpm" in value["data"] && (typeof value["data"]["bpm"] === "number" && Number.isFinite(value["data"]["bpm"]) && value["data"]["bpm"] >= 1 && true)) && hasOnlyKeys(value["data"], ["bpm"])) && hasOnlyKeys(value, ["statusClass","status","address","data"]);
}

export function isFlex_Text(value: unknown): value is Flex_Text {
  return isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 17) && ("status" in value && value["status"] === 1) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("text" in value["data"] && typeof value["data"]["text"] === "string") && hasOnlyKeys(value["data"], ["text"])) && hasOnlyKeys(value, ["statusClass","status","address","data"]);
}

export function isFlex_TimeSignature(value: unknown): value is Flex_TimeSignature {
  return isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 16) && ("status" in value && value["status"] === 2) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("numerator" in value["data"] && (typeof value["data"]["numerator"] === "number" && Number.isInteger(value["data"]["numerator"]) && value["data"]["numerator"] >= 1 && true)) && ("denominatorPow2" in value["data"] && (typeof value["data"]["denominatorPow2"] === "number" && Number.isInteger(value["data"]["denominatorPow2"]) && value["data"]["denominatorPow2"] >= 0 && true)) && hasOnlyKeys(value["data"], ["numerator","denominatorPow2"])) && hasOnlyKeys(value, ["statusClass","status","address","data"]);
}

export function isFlexDataBody(value: unknown): value is FlexDataBody {
  return ((isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 16) && ("status" in value && value["status"] === 1) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("bpm" in value["data"] && (typeof value["data"]["bpm"] === "number" && Number.isFinite(value["data"]["bpm"]) && value["data"]["bpm"] >= 1 && true)) && hasOnlyKeys(value["data"], ["bpm"])) && hasOnlyKeys(value, ["statusClass","status","address","data"])) || (isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 16) && ("status" in value && value["status"] === 2) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("numerator" in value["data"] && (typeof value["data"]["numerator"] === "number" && Number.isInteger(value["data"]["numerator"]) && value["data"]["numerator"] >= 1 && true)) && ("denominatorPow2" in value["data"] && (typeof value["data"]["denominatorPow2"] === "number" && Number.isInteger(value["data"]["denominatorPow2"]) && value["data"]["denominatorPow2"] >= 0 && true)) && hasOnlyKeys(value["data"], ["numerator","denominatorPow2"])) && hasOnlyKeys(value, ["statusClass","status","address","data"])) || (isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 16) && ("status" in value && value["status"] === 3) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("clicksPerBeat" in value["data"] ? (typeof value["data"]["clicksPerBeat"] === "number" && Number.isInteger(value["data"]["clicksPerBeat"]) && value["data"]["clicksPerBeat"] >= 1 && true) : true) && ("accentPattern" in value["data"] ? typeof value["data"]["accentPattern"] === "string" : true) && hasOnlyKeys(value["data"], ["clicksPerBeat","accentPattern"])) && hasOnlyKeys(value, ["statusClass","status","address","data"])) || (isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 16) && ("status" in value && value["status"] === 4) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("key" in value["data"] && typeof value["data"]["key"] === "string") && hasOnlyKeys(value["data"], ["key"])) && hasOnlyKeys(value, ["statusClass","status","address","data"])) || (isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 16) && ("status" in value && value["status"] === 5) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("chord" in value["data"] && typeof value["data"]["chord"] === "string") && hasOnlyKeys(value["data"], ["chord"])) && hasOnlyKeys(value, ["statusClass","status","address","data"])) || (isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 17) && ("status" in value && value["status"] === 1) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("text" in value["data"] && typeof value["data"]["text"] === "string") && hasOnlyKeys(value["data"], ["text"])) && hasOnlyKeys(value, ["statusClass","status","address","data"])) || (isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 17) && ("status" in value && value["status"] === 2) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("lyric" in value["data"] && typeof value["data"]["lyric"] === "string") && hasOnlyKeys(value["data"], ["lyric"])) && hasOnlyKeys(value, ["statusClass","status","address","data"])) || (isPlainObject(value) && ("statusClass" in value && value["statusClass"] === 17) && ("status" in value && value["status"] === 3) && ("address" in value ? isPlainObject(value["address"]) && ("scope" in value["address"] ? (value["address"]["scope"] === "group" || value["address"]["scope"] === "channel") : true) && ("group" in value["address"] ? (typeof value["address"]["group"] === "number" && Number.isInteger(value["address"]["group"]) && value["address"]["group"] >= 0 && value["address"]["group"] <= 15) : true) && ("channel" in value["address"] ? (typeof value["address"]["channel"] === "number" && Number.isInteger(value["address"]["channel"]) && value["address"]["channel"] >= 0 && value["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["address"], ["scope","group","channel"]) : true) && ("data" in value && isPlainObject(value["data"]) && ("ruby" in value["data"] && typeof value["data"]["ruby"] === "string") && hasOnlyKeys(value["data"], ["ruby"])) && hasOnlyKeys(value, ["statusClass","status","address","data"])));
}

export function isFunctionBlockNameNotification(value: unknown): value is FunctionBlockNameNotification {
  return isPlainObject(value) && ("functionBlock" in value && (typeof value["functionBlock"] === "number" && Number.isInteger(value["functionBlock"]) && value["functionBlock"] >= 0 && value["functionBlock"] <= 127)) && ("name" in value && typeof value["name"] === "string") && hasOnlyKeys(value, ["functionBlock","name"]);
}

export function isGroup(value: unknown): value is Group {
  return isUint4(value);
}

export function isInt32(value: unknown): value is Int32 {
  return (typeof value === "number" && Number.isInteger(value) && value >= -2147483648 && value <= 2147483647);
}

export function isMidi1ChannelVoiceBody(value: unknown): value is Midi1ChannelVoiceBody {
  return isPlainObject(value) && ("statusNibble" in value && (value["statusNibble"] === 8 || value["statusNibble"] === 9 || value["statusNibble"] === 10 || value["statusNibble"] === 11 || value["statusNibble"] === 12 || value["statusNibble"] === 13 || value["statusNibble"] === 14)) && ("channel" in value && (typeof value["channel"] === "number" && Number.isInteger(value["channel"]) && value["channel"] >= 0 && value["channel"] <= 15)) && ("noteNumber" in value ? (typeof value["noteNumber"] === "number" && Number.isInteger(value["noteNumber"]) && value["noteNumber"] >= 0 && value["noteNumber"] <= 127) : true) && ("velocity7" in value ? (typeof value["velocity7"] === "number" && Number.isInteger(value["velocity7"]) && value["velocity7"] >= 0 && value["velocity7"] <= 127) : true) && ("pressure7" in value ? (typeof value["pressure7"] === "number" && Number.isInteger(value["pressure7"]) && value["pressure7"] >= 0 && value["pressure7"] <= 127) : true) && ("control" in value ? (typeof value["control"] === "number" && Number.isInteger(value["control"]) && value["control"] >= 0 && value["control"] <= 127) : true) && ("value7" in value ? (typeof value["value7"] === "number" && Number.isInteger(value["value7"]) && value["value7"] >= 0 && value["value7"] <= 127) : true) && ("program" in value ? (typeof value["program"] === "number" && Number.isInteger(value["program"]) && value["program"] >= 0 && value["program"] <= 127) : true) && ("pitchBend14" in value ? (typeof value["pitchBend14"] === "number" && Number.isInteger(value["pitchBend14"]) && value["pitchBend14"] >= 0 && value["pitchBend14"] <= 16383) : true) && hasOnlyKeys(value, ["statusNibble","channel","noteNumber","velocity7","pressure7","control","value7","program","pitchBend14"]);
}

export function isMidi1StatusNibble(value: unknown): value is Midi1StatusNibble {
  return (value === 8 || value === 9 || value === 10 || value === 11 || value === 12 || value === 13 || value === 14);
}

export function isMidi2_AssignPerNoteController(value: unknown): value is Midi2_AssignPerNoteController {
  return isPlainObject(value) && ("noteNumber" in value && (typeof value["noteNumber"] === "number" && Number.isInteger(value["noteNumber"]) && value["noteNumber"] >= 0 && value["noteNumber"] <= 127)) && ("assignPerNoteCtrlIndex" in value && (typeof value["assignPerNoteCtrlIndex"] === "number" && Number.isInteger(value["assignPerNoteCtrlIndex"]) && value["assignPerNoteCtrlIndex"] >= 0 && value["assignPerNoteCtrlIndex"] <= 255)) && ("assignPerNoteCtrlValue32" in value && (typeof value["assignPerNoteCtrlValue32"] === "number" && Number.isInteger(value["assignPerNoteCtrlValue32"]) && value["assignPerNoteCtrlValue32"] >= 0 && value["assignPerNoteCtrlValue32"] <= 4294967295)) && hasOnlyKeys(value, ["noteNumber","assignPerNoteCtrlIndex","assignPerNoteCtrlValue32"]);
}

export function isMidi2_ChannelPressure(value: unknown): value is Midi2_ChannelPressure {
  return isPlainObject(value) && ("channelPressure32" in value && (typeof value["channelPressure32"] === "number" && Number.isInteger(value["channelPressure32"]) && value["channelPressure32"] >= 0 && value["channelPressure32"] <= 4294967295)) && hasOnlyKeys(value, ["channelPressure32"]);
}

export function isMidi2_ControlChange(value: unknown): value is Midi2_ControlChange {
  return isPlainObject(value) && ("control" in value && (typeof value["control"] === "number" && Number.isInteger(value["control"]) && value["control"] >= 0 && value["control"] <= 127)) && ("controlValue32" in value && (typeof value["controlValue32"] === "number" && Number.isInteger(value["controlValue32"]) && value["controlValue32"] >= 0 && value["controlValue32"] <= 4294967295)) && hasOnlyKeys(value, ["control","controlValue32"]);
}

export function isMidi2_NoteOff(value: unknown): value is Midi2_NoteOff {
  return isPlainObject(value) && ("noteNumber" in value && (typeof value["noteNumber"] === "number" && Number.isInteger(value["noteNumber"]) && value["noteNumber"] >= 0 && value["noteNumber"] <= 127)) && ("velocity16" in value && (typeof value["velocity16"] === "number" && Number.isInteger(value["velocity16"]) && value["velocity16"] >= 0 && value["velocity16"] <= 65535)) && ("attributeType" in value ? (typeof value["attributeType"] === "number" && Number.isInteger(value["attributeType"]) && value["attributeType"] >= 0 && value["attributeType"] <= 255) : true) && ("attributeData16" in value ? (typeof value["attributeData16"] === "number" && Number.isInteger(value["attributeData16"]) && value["attributeData16"] >= 0 && value["attributeData16"] <= 65535) : true) && hasOnlyKeys(value, ["noteNumber","velocity16","attributeType","attributeData16"]);
}

export function isMidi2_NoteOn(value: unknown): value is Midi2_NoteOn {
  return isPlainObject(value) && ("noteNumber" in value && (typeof value["noteNumber"] === "number" && Number.isInteger(value["noteNumber"]) && value["noteNumber"] >= 0 && value["noteNumber"] <= 127)) && ("velocity16" in value && (typeof value["velocity16"] === "number" && Number.isInteger(value["velocity16"]) && value["velocity16"] >= 0 && value["velocity16"] <= 65535)) && ("attributeType" in value ? (typeof value["attributeType"] === "number" && Number.isInteger(value["attributeType"]) && value["attributeType"] >= 0 && value["attributeType"] <= 255) : true) && ("attributeData16" in value ? (typeof value["attributeData16"] === "number" && Number.isInteger(value["attributeData16"]) && value["attributeData16"] >= 0 && value["attributeData16"] <= 65535) : true) && hasOnlyKeys(value, ["noteNumber","velocity16","attributeType","attributeData16"]);
}

export function isMidi2_NRPN(value: unknown): value is Midi2_NRPN {
  return isPlainObject(value) && ("nrpnIndexMsb" in value && (typeof value["nrpnIndexMsb"] === "number" && Number.isInteger(value["nrpnIndexMsb"]) && value["nrpnIndexMsb"] >= 0 && value["nrpnIndexMsb"] <= 127)) && ("nrpnIndexLsb" in value && (typeof value["nrpnIndexLsb"] === "number" && Number.isInteger(value["nrpnIndexLsb"]) && value["nrpnIndexLsb"] >= 0 && value["nrpnIndexLsb"] <= 127)) && ("nrpnData32" in value && (typeof value["nrpnData32"] === "number" && Number.isInteger(value["nrpnData32"]) && value["nrpnData32"] >= 0 && value["nrpnData32"] <= 4294967295)) && hasOnlyKeys(value, ["nrpnIndexMsb","nrpnIndexLsb","nrpnData32"]);
}

export function isMidi2_NRPNRelative(value: unknown): value is Midi2_NRPNRelative {
  return isPlainObject(value) && ("nrpnIndexMsb" in value && (typeof value["nrpnIndexMsb"] === "number" && Number.isInteger(value["nrpnIndexMsb"]) && value["nrpnIndexMsb"] >= 0 && value["nrpnIndexMsb"] <= 127)) && ("nrpnIndexLsb" in value && (typeof value["nrpnIndexLsb"] === "number" && Number.isInteger(value["nrpnIndexLsb"]) && value["nrpnIndexLsb"] >= 0 && value["nrpnIndexLsb"] <= 127)) && ("nrpnDelta32" in value && (typeof value["nrpnDelta32"] === "number" && Number.isInteger(value["nrpnDelta32"]) && value["nrpnDelta32"] >= -2147483648 && value["nrpnDelta32"] <= 2147483647)) && hasOnlyKeys(value, ["nrpnIndexMsb","nrpnIndexLsb","nrpnDelta32"]);
}

export function isMidi2_PerNoteManagement(value: unknown): value is Midi2_PerNoteManagement {
  return isPlainObject(value) && ("noteNumber" in value && (typeof value["noteNumber"] === "number" && Number.isInteger(value["noteNumber"]) && value["noteNumber"] >= 0 && value["noteNumber"] <= 127)) && ("detach" in value && typeof value["detach"] === "boolean") && ("reset" in value && typeof value["reset"] === "boolean") && hasOnlyKeys(value, ["noteNumber","detach","reset"]);
}

export function isMidi2_PitchBend(value: unknown): value is Midi2_PitchBend {
  return isPlainObject(value) && ("pitchBend32" in value && (typeof value["pitchBend32"] === "number" && Number.isInteger(value["pitchBend32"]) && value["pitchBend32"] >= 0 && value["pitchBend32"] <= 4294967295)) && hasOnlyKeys(value, ["pitchBend32"]);
}

export function isMidi2_PolyPressure(value: unknown): value is Midi2_PolyPressure {
  return isPlainObject(value) && ("noteNumber" in value && (typeof value["noteNumber"] === "number" && Number.isInteger(value["noteNumber"]) && value["noteNumber"] >= 0 && value["noteNumber"] <= 127)) && ("polyPressure32" in value && (typeof value["polyPressure32"] === "number" && Number.isInteger(value["polyPressure32"]) && value["polyPressure32"] >= 0 && value["polyPressure32"] <= 4294967295)) && hasOnlyKeys(value, ["noteNumber","polyPressure32"]);
}

export function isMidi2_ProgramChange(value: unknown): value is Midi2_ProgramChange {
  return isPlainObject(value) && ("program" in value && (typeof value["program"] === "number" && Number.isInteger(value["program"]) && value["program"] >= 0 && value["program"] <= 127)) && ("bankMsb" in value ? (typeof value["bankMsb"] === "number" && Number.isInteger(value["bankMsb"]) && value["bankMsb"] >= 0 && value["bankMsb"] <= 127) : true) && ("bankLsb" in value ? (typeof value["bankLsb"] === "number" && Number.isInteger(value["bankLsb"]) && value["bankLsb"] >= 0 && value["bankLsb"] <= 127) : true) && ("bankValid" in value ? typeof value["bankValid"] === "boolean" : true) && hasOnlyKeys(value, ["program","bankMsb","bankLsb","bankValid"]);
}

export function isMidi2_RegPerNoteController(value: unknown): value is Midi2_RegPerNoteController {
  return isPlainObject(value) && ("noteNumber" in value && (typeof value["noteNumber"] === "number" && Number.isInteger(value["noteNumber"]) && value["noteNumber"] >= 0 && value["noteNumber"] <= 127)) && ("regPerNoteCtrlIndex" in value && (typeof value["regPerNoteCtrlIndex"] === "number" && Number.isInteger(value["regPerNoteCtrlIndex"]) && value["regPerNoteCtrlIndex"] >= 0 && value["regPerNoteCtrlIndex"] <= 255)) && ("regPerNoteCtrlValue32" in value && (typeof value["regPerNoteCtrlValue32"] === "number" && Number.isInteger(value["regPerNoteCtrlValue32"]) && value["regPerNoteCtrlValue32"] >= 0 && value["regPerNoteCtrlValue32"] <= 4294967295)) && hasOnlyKeys(value, ["noteNumber","regPerNoteCtrlIndex","regPerNoteCtrlValue32"]);
}

export function isMidi2_RPN(value: unknown): value is Midi2_RPN {
  return isPlainObject(value) && ("rpnIndexMsb" in value && (typeof value["rpnIndexMsb"] === "number" && Number.isInteger(value["rpnIndexMsb"]) && value["rpnIndexMsb"] >= 0 && value["rpnIndexMsb"] <= 127)) && ("rpnIndexLsb" in value && (typeof value["rpnIndexLsb"] === "number" && Number.isInteger(value["rpnIndexLsb"]) && value["rpnIndexLsb"] >= 0 && value["rpnIndexLsb"] <= 127)) && ("rpnData32" in value && (typeof value["rpnData32"] === "number" && Number.isInteger(value["rpnData32"]) && value["rpnData32"] >= 0 && value["rpnData32"] <= 4294967295)) && hasOnlyKeys(value, ["rpnIndexMsb","rpnIndexLsb","rpnData32"]);
}

export function isMidi2_RPNRelative(value: unknown): value is Midi2_RPNRelative {
  return isPlainObject(value) && ("rpnIndexMsb" in value && (typeof value["rpnIndexMsb"] === "number" && Number.isInteger(value["rpnIndexMsb"]) && value["rpnIndexMsb"] >= 0 && value["rpnIndexMsb"] <= 127)) && ("rpnIndexLsb" in value && (typeof value["rpnIndexLsb"] === "number" && Number.isInteger(value["rpnIndexLsb"]) && value["rpnIndexLsb"] >= 0 && value["rpnIndexLsb"] <= 127)) && ("rpnDelta32" in value && (typeof value["rpnDelta32"] === "number" && Number.isInteger(value["rpnDelta32"]) && value["rpnDelta32"] >= -2147483648 && value["rpnDelta32"] <= 2147483647)) && hasOnlyKeys(value, ["rpnIndexMsb","rpnIndexLsb","rpnDelta32"]);
}

export function isMidi2ChannelVoiceBody(value: unknown): value is Midi2ChannelVoiceBody {
  return isPlainObject(value) && ("statusNibble" in value && (value["statusNibble"] === 8 || value["statusNibble"] === 9 || value["statusNibble"] === 10 || value["statusNibble"] === 11 || value["statusNibble"] === 12 || value["statusNibble"] === 13 || value["statusNibble"] === 14 || value["statusNibble"] === 15)) && ("channel" in value && (typeof value["channel"] === "number" && Number.isInteger(value["channel"]) && value["channel"] >= 0 && value["channel"] <= 15)) && ("noteNumber" in value ? (typeof value["noteNumber"] === "number" && Number.isInteger(value["noteNumber"]) && value["noteNumber"] >= 0 && value["noteNumber"] <= 127) : true) && ("velocity16" in value ? (typeof value["velocity16"] === "number" && Number.isInteger(value["velocity16"]) && value["velocity16"] >= 0 && value["velocity16"] <= 65535) : true) && ("attributeType" in value ? (typeof value["attributeType"] === "number" && Number.isInteger(value["attributeType"]) && value["attributeType"] >= 0 && value["attributeType"] <= 255) : true) && ("attributeData16" in value ? (typeof value["attributeData16"] === "number" && Number.isInteger(value["attributeData16"]) && value["attributeData16"] >= 0 && value["attributeData16"] <= 65535) : true) && ("polyPressure32" in value ? (typeof value["polyPressure32"] === "number" && Number.isInteger(value["polyPressure32"]) && value["polyPressure32"] >= 0 && value["polyPressure32"] <= 4294967295) : true) && ("control" in value ? (typeof value["control"] === "number" && Number.isInteger(value["control"]) && value["control"] >= 0 && value["control"] <= 127) : true) && ("controlValue32" in value ? (typeof value["controlValue32"] === "number" && Number.isInteger(value["controlValue32"]) && value["controlValue32"] >= 0 && value["controlValue32"] <= 4294967295) : true) && ("program" in value ? (typeof value["program"] === "number" && Number.isInteger(value["program"]) && value["program"] >= 0 && value["program"] <= 127) : true) && ("bankMsb" in value ? (typeof value["bankMsb"] === "number" && Number.isInteger(value["bankMsb"]) && value["bankMsb"] >= 0 && value["bankMsb"] <= 127) : true) && ("bankLsb" in value ? (typeof value["bankLsb"] === "number" && Number.isInteger(value["bankLsb"]) && value["bankLsb"] >= 0 && value["bankLsb"] <= 127) : true) && ("bankValid" in value ? typeof value["bankValid"] === "boolean" : true) && ("channelPressure32" in value ? (typeof value["channelPressure32"] === "number" && Number.isInteger(value["channelPressure32"]) && value["channelPressure32"] >= 0 && value["channelPressure32"] <= 4294967295) : true) && ("pitchBend32" in value ? (typeof value["pitchBend32"] === "number" && Number.isInteger(value["pitchBend32"]) && value["pitchBend32"] >= 0 && value["pitchBend32"] <= 4294967295) : true) && ("rpnIndexMsb" in value ? (typeof value["rpnIndexMsb"] === "number" && Number.isInteger(value["rpnIndexMsb"]) && value["rpnIndexMsb"] >= 0 && value["rpnIndexMsb"] <= 127) : true) && ("rpnIndexLsb" in value ? (typeof value["rpnIndexLsb"] === "number" && Number.isInteger(value["rpnIndexLsb"]) && value["rpnIndexLsb"] >= 0 && value["rpnIndexLsb"] <= 127) : true) && ("rpnData32" in value ? (typeof value["rpnData32"] === "number" && Number.isInteger(value["rpnData32"]) && value["rpnData32"] >= 0 && value["rpnData32"] <= 4294967295) : true) && ("nrpnIndexMsb" in value ? (typeof value["nrpnIndexMsb"] === "number" && Number.isInteger(value["nrpnIndexMsb"]) && value["nrpnIndexMsb"] >= 0 && value["nrpnIndexMsb"] <= 127) : true) && ("nrpnIndexLsb" in value ? (typeof value["nrpnIndexLsb"] === "number" && Number.isInteger(value["nrpnIndexLsb"]) && value["nrpnIndexLsb"] >= 0 && value["nrpnIndexLsb"] <= 127) : true) && ("nrpnData32" in value ? (typeof value["nrpnData32"] === "number" && Number.isInteger(value["nrpnData32"]) && value["nrpnData32"] >= 0 && value["nrpnData32"] <= 4294967295) : true) && ("rpnDelta32" in value ? (typeof value["rpnDelta32"] === "number" && Number.isInteger(value["rpnDelta32"]) && value["rpnDelta32"] >= -2147483648 && value["rpnDelta32"] <= 2147483647) : true) && ("nrpnDelta32" in value ? (typeof value["nrpnDelta32"] === "number" && Number.isInteger(value["nrpnDelta32"]) && value["nrpnDelta32"] >= -2147483648 && value["nrpnDelta32"] <= 2147483647) : true) && ("perNoteMgmt" in value ? isPlainObject(value["perNoteMgmt"]) && ("noteNumber" in value["perNoteMgmt"] ? (typeof value["perNoteMgmt"]["noteNumber"] === "number" && Number.isInteger(value["perNoteMgmt"]["noteNumber"]) && value["perNoteMgmt"]["noteNumber"] >= 0 && value["perNoteMgmt"]["noteNumber"] <= 127) : true) && ("detach" in value["perNoteMgmt"] ? typeof value["perNoteMgmt"]["detach"] === "boolean" : true) && ("reset" in value["perNoteMgmt"] ? typeof value["perNoteMgmt"]["reset"] === "boolean" : true) && hasOnlyKeys(value["perNoteMgmt"], ["noteNumber","detach","reset"]) : true) && ("regPerNoteCtrlIndex" in value ? (typeof value["regPerNoteCtrlIndex"] === "number" && Number.isInteger(value["regPerNoteCtrlIndex"]) && value["regPerNoteCtrlIndex"] >= 0 && value["regPerNoteCtrlIndex"] <= 255) : true) && ("regPerNoteCtrlValue32" in value ? (typeof value["regPerNoteCtrlValue32"] === "number" && Number.isInteger(value["regPerNoteCtrlValue32"]) && value["regPerNoteCtrlValue32"] >= 0 && value["regPerNoteCtrlValue32"] <= 4294967295) : true) && ("assignPerNoteCtrlIndex" in value ? (typeof value["assignPerNoteCtrlIndex"] === "number" && Number.isInteger(value["assignPerNoteCtrlIndex"]) && value["assignPerNoteCtrlIndex"] >= 0 && value["assignPerNoteCtrlIndex"] <= 255) : true) && ("assignPerNoteCtrlValue32" in value ? (typeof value["assignPerNoteCtrlValue32"] === "number" && Number.isInteger(value["assignPerNoteCtrlValue32"]) && value["assignPerNoteCtrlValue32"] >= 0 && value["assignPerNoteCtrlValue32"] <= 4294967295) : true) && hasOnlyKeys(value, ["statusNibble","channel","noteNumber","velocity16","attributeType","attributeData16","polyPressure32","control","controlValue32","program","bankMsb","bankLsb","bankValid","channelPressure32","pitchBend32","rpnIndexMsb","rpnIndexLsb","rpnData32","nrpnIndexMsb","nrpnIndexLsb","nrpnData32","rpnDelta32","nrpnDelta32","perNoteMgmt","regPerNoteCtrlIndex","regPerNoteCtrlValue32","assignPerNoteCtrlIndex","assignPerNoteCtrlValue32"]);
}

export function isMidi2ChannelVoiceVariants(value: unknown): value is Midi2ChannelVoiceVariants {
  return (isPlainObject(value) && ("statusNibble" in value && (value["statusNibble"] === 8 || value["statusNibble"] === 9 || value["statusNibble"] === 10 || value["statusNibble"] === 11 || value["statusNibble"] === 12 || value["statusNibble"] === 13 || value["statusNibble"] === 14 || value["statusNibble"] === 15)) && ("channel" in value && (typeof value["channel"] === "number" && Number.isInteger(value["channel"]) && value["channel"] >= 0 && value["channel"] <= 15)) && hasOnlyKeys(value, ["statusNibble","channel","body"])) && ((isPlainObject(value) && ("statusNibble" in value ? value["statusNibble"] === 8 : true) && ("body" in value ? isPlainObject(value["body"]) && ("noteNumber" in value["body"] && (typeof value["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["noteNumber"]) && value["body"]["noteNumber"] >= 0 && value["body"]["noteNumber"] <= 127)) && ("velocity16" in value["body"] && (typeof value["body"]["velocity16"] === "number" && Number.isInteger(value["body"]["velocity16"]) && value["body"]["velocity16"] >= 0 && value["body"]["velocity16"] <= 65535)) && ("attributeType" in value["body"] ? (typeof value["body"]["attributeType"] === "number" && Number.isInteger(value["body"]["attributeType"]) && value["body"]["attributeType"] >= 0 && value["body"]["attributeType"] <= 255) : true) && ("attributeData16" in value["body"] ? (typeof value["body"]["attributeData16"] === "number" && Number.isInteger(value["body"]["attributeData16"]) && value["body"]["attributeData16"] >= 0 && value["body"]["attributeData16"] <= 65535) : true) && hasOnlyKeys(value["body"], ["noteNumber","velocity16","attributeType","attributeData16"]) : true)) || (isPlainObject(value) && ("statusNibble" in value ? value["statusNibble"] === 9 : true) && ("body" in value ? isPlainObject(value["body"]) && ("noteNumber" in value["body"] && (typeof value["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["noteNumber"]) && value["body"]["noteNumber"] >= 0 && value["body"]["noteNumber"] <= 127)) && ("velocity16" in value["body"] && (typeof value["body"]["velocity16"] === "number" && Number.isInteger(value["body"]["velocity16"]) && value["body"]["velocity16"] >= 0 && value["body"]["velocity16"] <= 65535)) && ("attributeType" in value["body"] ? (typeof value["body"]["attributeType"] === "number" && Number.isInteger(value["body"]["attributeType"]) && value["body"]["attributeType"] >= 0 && value["body"]["attributeType"] <= 255) : true) && ("attributeData16" in value["body"] ? (typeof value["body"]["attributeData16"] === "number" && Number.isInteger(value["body"]["attributeData16"]) && value["body"]["attributeData16"] >= 0 && value["body"]["attributeData16"] <= 65535) : true) && hasOnlyKeys(value["body"], ["noteNumber","velocity16","attributeType","attributeData16"]) : true)) || (isPlainObject(value) && ("statusNibble" in value ? value["statusNibble"] === 10 : true) && ("body" in value ? isPlainObject(value["body"]) && ("noteNumber" in value["body"] && (typeof value["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["noteNumber"]) && value["body"]["noteNumber"] >= 0 && value["body"]["noteNumber"] <= 127)) && ("polyPressure32" in value["body"] && (typeof value["body"]["polyPressure32"] === "number" && Number.isInteger(value["body"]["polyPressure32"]) && value["body"]["polyPressure32"] >= 0 && value["body"]["polyPressure32"] <= 4294967295)) && hasOnlyKeys(value["body"], ["noteNumber","polyPressure32"]) : true)) || (isPlainObject(value) && ("statusNibble" in value ? value["statusNibble"] === 11 : true) && ("body" in value ? isPlainObject(value["body"]) && ("control" in value["body"] && (typeof value["body"]["control"] === "number" && Number.isInteger(value["body"]["control"]) && value["body"]["control"] >= 0 && value["body"]["control"] <= 127)) && ("controlValue32" in value["body"] && (typeof value["body"]["controlValue32"] === "number" && Number.isInteger(value["body"]["controlValue32"]) && value["body"]["controlValue32"] >= 0 && value["body"]["controlValue32"] <= 4294967295)) && hasOnlyKeys(value["body"], ["control","controlValue32"]) : true)) || (isPlainObject(value) && ("statusNibble" in value ? value["statusNibble"] === 12 : true) && ("body" in value ? isPlainObject(value["body"]) && ("program" in value["body"] && (typeof value["body"]["program"] === "number" && Number.isInteger(value["body"]["program"]) && value["body"]["program"] >= 0 && value["body"]["program"] <= 127)) && ("bankMsb" in value["body"] ? (typeof value["body"]["bankMsb"] === "number" && Number.isInteger(value["body"]["bankMsb"]) && value["body"]["bankMsb"] >= 0 && value["body"]["bankMsb"] <= 127) : true) && ("bankLsb" in value["body"] ? (typeof value["body"]["bankLsb"] === "number" && Number.isInteger(value["body"]["bankLsb"]) && value["body"]["bankLsb"] >= 0 && value["body"]["bankLsb"] <= 127) : true) && ("bankValid" in value["body"] ? typeof value["body"]["bankValid"] === "boolean" : true) && hasOnlyKeys(value["body"], ["program","bankMsb","bankLsb","bankValid"]) : true)) || (isPlainObject(value) && ("statusNibble" in value ? value["statusNibble"] === 13 : true) && ("body" in value ? isPlainObject(value["body"]) && ("channelPressure32" in value["body"] && (typeof value["body"]["channelPressure32"] === "number" && Number.isInteger(value["body"]["channelPressure32"]) && value["body"]["channelPressure32"] >= 0 && value["body"]["channelPressure32"] <= 4294967295)) && hasOnlyKeys(value["body"], ["channelPressure32"]) : true)) || (isPlainObject(value) && ("statusNibble" in value ? value["statusNibble"] === 14 : true) && ("body" in value ? isPlainObject(value["body"]) && ("pitchBend32" in value["body"] && (typeof value["body"]["pitchBend32"] === "number" && Number.isInteger(value["body"]["pitchBend32"]) && value["body"]["pitchBend32"] >= 0 && value["body"]["pitchBend32"] <= 4294967295)) && hasOnlyKeys(value["body"], ["pitchBend32"]) : true)) || (isPlainObject(value) && ("statusNibble" in value ? value["statusNibble"] === 15 : true) && ("body" in value ? ((isPlainObject(value["body"]) && ("rpnIndexMsb" in value["body"] && (typeof value["body"]["rpnIndexMsb"] === "number" && Number.isInteger(value["body"]["rpnIndexMsb"]) && value["body"]["rpnIndexMsb"] >= 0 && value["body"]["rpnIndexMsb"] <= 127)) && ("rpnIndexLsb" in value["body"] && (typeof value["body"]["rpnIndexLsb"] === "number" && Number.isInteger(value["body"]["rpnIndexLsb"]) && value["body"]["rpnIndexLsb"] >= 0 && value["body"]["rpnIndexLsb"] <= 127)) && ("rpnData32" in value["body"] && (typeof value["body"]["rpnData32"] === "number" && Number.isInteger(value["body"]["rpnData32"]) && value["body"]["rpnData32"] >= 0 && value["body"]["rpnData32"] <= 4294967295)) && hasOnlyKeys(value["body"], ["rpnIndexMsb","rpnIndexLsb","rpnData32"])) || (isPlainObject(value["body"]) && ("nrpnIndexMsb" in value["body"] && (typeof value["body"]["nrpnIndexMsb"] === "number" && Number.isInteger(value["body"]["nrpnIndexMsb"]) && value["body"]["nrpnIndexMsb"] >= 0 && value["body"]["nrpnIndexMsb"] <= 127)) && ("nrpnIndexLsb" in value["body"] && (typeof value["body"]["nrpnIndexLsb"] === "number" && Number.isInteger(value["body"]["nrpnIndexLsb"]) && value["body"]["nrpnIndexLsb"] >= 0 && value["body"]["nrpnIndexLsb"] <= 127)) && ("nrpnData32" in value["body"] && (typeof value["body"]["nrpnData32"] === "number" && Number.isInteger(value["body"]["nrpnData32"]) && value["body"]["nrpnData32"] >= 0 && value["body"]["nrpnData32"] <= 4294967295)) && hasOnlyKeys(value["body"], ["nrpnIndexMsb","nrpnIndexLsb","nrpnData32"])) || (isPlainObject(value["body"]) && ("rpnIndexMsb" in value["body"] && (typeof value["body"]["rpnIndexMsb"] === "number" && Number.isInteger(value["body"]["rpnIndexMsb"]) && value["body"]["rpnIndexMsb"] >= 0 && value["body"]["rpnIndexMsb"] <= 127)) && ("rpnIndexLsb" in value["body"] && (typeof value["body"]["rpnIndexLsb"] === "number" && Number.isInteger(value["body"]["rpnIndexLsb"]) && value["body"]["rpnIndexLsb"] >= 0 && value["body"]["rpnIndexLsb"] <= 127)) && ("rpnDelta32" in value["body"] && (typeof value["body"]["rpnDelta32"] === "number" && Number.isInteger(value["body"]["rpnDelta32"]) && value["body"]["rpnDelta32"] >= -2147483648 && value["body"]["rpnDelta32"] <= 2147483647)) && hasOnlyKeys(value["body"], ["rpnIndexMsb","rpnIndexLsb","rpnDelta32"])) || (isPlainObject(value["body"]) && ("nrpnIndexMsb" in value["body"] && (typeof value["body"]["nrpnIndexMsb"] === "number" && Number.isInteger(value["body"]["nrpnIndexMsb"]) && value["body"]["nrpnIndexMsb"] >= 0 && value["body"]["nrpnIndexMsb"] <= 127)) && ("nrpnIndexLsb" in value["body"] && (typeof value["body"]["nrpnIndexLsb"] === "number" && Number.isInteger(value["body"]["nrpnIndexLsb"]) && value["body"]["nrpnIndexLsb"] >= 0 && value["body"]["nrpnIndexLsb"] <= 127)) && ("nrpnDelta32" in value["body"] && (typeof value["body"]["nrpnDelta32"] === "number" && Number.isInteger(value["body"]["nrpnDelta32"]) && value["body"]["nrpnDelta32"] >= -2147483648 && value["body"]["nrpnDelta32"] <= 2147483647)) && hasOnlyKeys(value["body"], ["nrpnIndexMsb","nrpnIndexLsb","nrpnDelta32"])) || (isPlainObject(value["body"]) && ("noteNumber" in value["body"] && (typeof value["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["noteNumber"]) && value["body"]["noteNumber"] >= 0 && value["body"]["noteNumber"] <= 127)) && ("detach" in value["body"] && typeof value["body"]["detach"] === "boolean") && ("reset" in value["body"] && typeof value["body"]["reset"] === "boolean") && hasOnlyKeys(value["body"], ["noteNumber","detach","reset"])) || (isPlainObject(value["body"]) && ("noteNumber" in value["body"] && (typeof value["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["noteNumber"]) && value["body"]["noteNumber"] >= 0 && value["body"]["noteNumber"] <= 127)) && ("regPerNoteCtrlIndex" in value["body"] && (typeof value["body"]["regPerNoteCtrlIndex"] === "number" && Number.isInteger(value["body"]["regPerNoteCtrlIndex"]) && value["body"]["regPerNoteCtrlIndex"] >= 0 && value["body"]["regPerNoteCtrlIndex"] <= 255)) && ("regPerNoteCtrlValue32" in value["body"] && (typeof value["body"]["regPerNoteCtrlValue32"] === "number" && Number.isInteger(value["body"]["regPerNoteCtrlValue32"]) && value["body"]["regPerNoteCtrlValue32"] >= 0 && value["body"]["regPerNoteCtrlValue32"] <= 4294967295)) && hasOnlyKeys(value["body"], ["noteNumber","regPerNoteCtrlIndex","regPerNoteCtrlValue32"])) || (isPlainObject(value["body"]) && ("noteNumber" in value["body"] && (typeof value["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["noteNumber"]) && value["body"]["noteNumber"] >= 0 && value["body"]["noteNumber"] <= 127)) && ("assignPerNoteCtrlIndex" in value["body"] && (typeof value["body"]["assignPerNoteCtrlIndex"] === "number" && Number.isInteger(value["body"]["assignPerNoteCtrlIndex"]) && value["body"]["assignPerNoteCtrlIndex"] >= 0 && value["body"]["assignPerNoteCtrlIndex"] <= 255)) && ("assignPerNoteCtrlValue32" in value["body"] && (typeof value["body"]["assignPerNoteCtrlValue32"] === "number" && Number.isInteger(value["body"]["assignPerNoteCtrlValue32"]) && value["body"]["assignPerNoteCtrlValue32"] >= 0 && value["body"]["assignPerNoteCtrlValue32"] <= 4294967295)) && hasOnlyKeys(value["body"], ["noteNumber","assignPerNoteCtrlIndex","assignPerNoteCtrlValue32"]))) : true)));
}

export function isMidi2StatusNibble(value: unknown): value is Midi2StatusNibble {
  return (value === 8 || value === 9 || value === 10 || value === 11 || value === 12 || value === 13 || value === 14 || value === 15);
}

export function isMidiCiAckNakBody(value: unknown): value is MidiCiAckNakBody {
  return isPlainObject(value) && ("ack" in value ? typeof value["ack"] === "boolean" : true) && ("statusCode" in value ? (typeof value["statusCode"] === "number" && Number.isInteger(value["statusCode"]) && value["statusCode"] >= 0 && value["statusCode"] <= 255) : true) && ("message" in value ? typeof value["message"] === "string" : true) && hasOnlyKeys(value, ["ack","statusCode","message"]);
}

export function isMidiCiDiscoveryBody(value: unknown): value is MidiCiDiscoveryBody {
  return isPlainObject(value) && ("muid" in value ? (typeof value["muid"] === "number" && Number.isInteger(value["muid"]) && value["muid"] >= 0 && value["muid"] <= 4294967295) : true) && ("manufacturerId" in value ? (((Array.isArray(value["manufacturerId"]) && value["manufacturerId"].length >= 1 && value["manufacturerId"].length <= 1 && value["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) || ((Array.isArray(value["manufacturerId"]) && value["manufacturerId"].length >= 3 && value["manufacturerId"].length <= 3 && value["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255))))) : true) && ("deviceFamily" in value ? (typeof value["deviceFamily"] === "number" && Number.isInteger(value["deviceFamily"]) && value["deviceFamily"] >= 0 && value["deviceFamily"] <= 65535) : true) && ("deviceModel" in value ? (typeof value["deviceModel"] === "number" && Number.isInteger(value["deviceModel"]) && value["deviceModel"] >= 0 && value["deviceModel"] <= 65535) : true) && ("softwareRev" in value ? (typeof value["softwareRev"] === "number" && Number.isInteger(value["softwareRev"]) && value["softwareRev"] >= 0 && value["softwareRev"] <= 4294967295) : true) && ("categories" in value ? isPlainObject(value["categories"]) && ("profiles" in value["categories"] ? typeof value["categories"]["profiles"] === "boolean" : true) && ("propertyExchange" in value["categories"] ? typeof value["categories"]["propertyExchange"] === "boolean" : true) && ("processInquiry" in value["categories"] ? typeof value["categories"]["processInquiry"] === "boolean" : true) && hasOnlyKeys(value["categories"], ["profiles","propertyExchange","processInquiry"]) : true) && ("maxSysEx" in value ? (typeof value["maxSysEx"] === "number" && Number.isInteger(value["maxSysEx"]) && value["maxSysEx"] >= 0 && value["maxSysEx"] <= 4294967295) : true) && hasOnlyKeys(value, ["muid","manufacturerId","deviceFamily","deviceModel","softwareRev","categories","maxSysEx"]);
}

export function isMidiCiEnvelope(value: unknown): value is MidiCiEnvelope {
  return isPlainObject(value) && ("scope" in value && (value["scope"] === "nonRealtime" || value["scope"] === "realtime")) && ("subId1" in value && value["subId1"] === 13) && ("subId2" in value && (typeof value["subId2"] === "number" && Number.isInteger(value["subId2"]) && value["subId2"] >= 0 && value["subId2"] <= 255)) && ("version" in value && (typeof value["version"] === "number" && Number.isInteger(value["version"]) && value["version"] >= 0 && value["version"] <= 255)) && ("body" in value && ((isPlainObject(value["body"]) && ("muid" in value["body"] ? (typeof value["body"]["muid"] === "number" && Number.isInteger(value["body"]["muid"]) && value["body"]["muid"] >= 0 && value["body"]["muid"] <= 4294967295) : true) && ("manufacturerId" in value["body"] ? (((Array.isArray(value["body"]["manufacturerId"]) && value["body"]["manufacturerId"].length >= 1 && value["body"]["manufacturerId"].length <= 1 && value["body"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) || ((Array.isArray(value["body"]["manufacturerId"]) && value["body"]["manufacturerId"].length >= 3 && value["body"]["manufacturerId"].length <= 3 && value["body"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255))))) : true) && ("deviceFamily" in value["body"] ? (typeof value["body"]["deviceFamily"] === "number" && Number.isInteger(value["body"]["deviceFamily"]) && value["body"]["deviceFamily"] >= 0 && value["body"]["deviceFamily"] <= 65535) : true) && ("deviceModel" in value["body"] ? (typeof value["body"]["deviceModel"] === "number" && Number.isInteger(value["body"]["deviceModel"]) && value["body"]["deviceModel"] >= 0 && value["body"]["deviceModel"] <= 65535) : true) && ("softwareRev" in value["body"] ? (typeof value["body"]["softwareRev"] === "number" && Number.isInteger(value["body"]["softwareRev"]) && value["body"]["softwareRev"] >= 0 && value["body"]["softwareRev"] <= 4294967295) : true) && ("categories" in value["body"] ? isPlainObject(value["body"]["categories"]) && ("profiles" in value["body"]["categories"] ? typeof value["body"]["categories"]["profiles"] === "boolean" : true) && ("propertyExchange" in value["body"]["categories"] ? typeof value["body"]["categories"]["propertyExchange"] === "boolean" : true) && ("processInquiry" in value["body"]["categories"] ? typeof value["body"]["categories"]["processInquiry"] === "boolean" : true) && hasOnlyKeys(value["body"]["categories"], ["profiles","propertyExchange","processInquiry"]) : true) && ("maxSysEx" in value["body"] ? (typeof value["body"]["maxSysEx"] === "number" && Number.isInteger(value["body"]["maxSysEx"]) && value["body"]["maxSysEx"] >= 0 && value["body"]["maxSysEx"] <= 4294967295) : true) && hasOnlyKeys(value["body"], ["muid","manufacturerId","deviceFamily","deviceModel","softwareRev","categories","maxSysEx"])) || (isPlainObject(value["body"]) && ("command" in value["body"] ? (value["body"]["command"] === "inquiry" || value["body"]["command"] === "reply" || value["body"]["command"] === "addedReport" || value["body"]["command"] === "removedReport" || value["body"]["command"] === "setOn" || value["body"]["command"] === "setOff" || value["body"]["command"] === "enabledReport" || value["body"]["command"] === "disabledReport" || value["body"]["command"] === "detailsInquiry" || value["body"]["command"] === "detailsReply" || value["body"]["command"] === "profileSpecificData") : true) && ("profileId" in value["body"] ? typeof value["body"]["profileId"] === "string" : true) && ("target" in value["body"] ? (value["body"]["target"] === "channel" || value["body"]["target"] === "group" || value["body"]["target"] === "functionBlock") : true) && ("channels" in value["body"] ? (Array.isArray(value["body"]["channels"]) && true && true && value["body"]["channels"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 15))) : true) && ("details" in value["body"] ? isPlainObject(value["body"]["details"]) && hasOnlyKeys(value["body"]["details"], []) : true) && hasOnlyKeys(value["body"], ["command","profileId","target","channels","details"])) || (isPlainObject(value["body"]) && ("command" in value["body"] ? (value["body"]["command"] === "capInquiry" || value["body"]["command"] === "capReply" || value["body"]["command"] === "get" || value["body"]["command"] === "getReply" || value["body"]["command"] === "set" || value["body"]["command"] === "setReply" || value["body"]["command"] === "subscribe" || value["body"]["command"] === "subscribeReply" || value["body"]["command"] === "notify" || value["body"]["command"] === "terminate") : true) && ("subscriptionId" in value["body"] ? typeof value["body"]["subscriptionId"] === "string" : true) && ("requestId" in value["body"] ? (typeof value["body"]["requestId"] === "number" && Number.isInteger(value["body"]["requestId"]) && value["body"]["requestId"] >= 0 && value["body"]["requestId"] <= 4294967295) : true) && ("encoding" in value["body"] ? (value["body"]["encoding"] === "json" || value["body"]["encoding"] === "binary" || value["body"]["encoding"] === "json+zlib" || value["body"]["encoding"] === "binary+zlib" || value["body"]["encoding"] === "mcoded7") : true) && ("header" in value["body"] ? isPlainObject(value["body"]["header"]) && ("resource" in value["body"]["header"] ? typeof value["body"]["header"]["resource"] === "string" : true) && ("resId" in value["body"]["header"] ? (typeof value["body"]["header"]["resId"] === "number" && Number.isInteger(value["body"]["header"]["resId"]) && value["body"]["header"]["resId"] >= 0 && value["body"]["header"]["resId"] <= 4294967295) : true) && ("encoding" in value["body"]["header"] ? (value["body"]["header"]["encoding"] === "json" || value["body"]["header"]["encoding"] === "binary" || value["body"]["header"]["encoding"] === "json+zlib" || value["body"]["header"]["encoding"] === "binary+zlib" || value["body"]["header"]["encoding"] === "mcoded7") : true) && ("flowControl" in value["body"]["header"] ? typeof value["body"]["header"]["flowControl"] === "boolean" : true) && ("status" in value["body"]["header"] ? (typeof value["body"]["header"]["status"] === "number" && Number.isInteger(value["body"]["header"]["status"]) && value["body"]["header"]["status"] >= 100 && value["body"]["header"]["status"] <= 999) : true) && ("message" in value["body"]["header"] ? typeof value["body"]["header"]["message"] === "string" : true) && ("cacheTime" in value["body"]["header"] ? (typeof value["body"]["header"]["cacheTime"] === "number" && Number.isInteger(value["body"]["header"]["cacheTime"]) && value["body"]["header"]["cacheTime"] >= 0 && true) : true) && ("mediaType" in value["body"]["header"] ? typeof value["body"]["header"]["mediaType"] === "string" : true) && hasOnlyKeys(value["body"]["header"], ["resource","resId","encoding","flowControl","status","message","cacheTime","mediaType"]) : true) && ("data" in value["body"] ? ((isPlainObject(value["body"]["data"]) && hasOnlyKeys(value["body"]["data"], [])) || ((Array.isArray(value["body"]["data"]) && true && true && value["body"]["data"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255))))) : true) && ("statusCodes" in value["body"] ? (Array.isArray(value["body"]["statusCodes"]) && true && true && value["body"]["statusCodes"].every(item => (item === 200 || item === 201 || item === 341 || item === 342 || item === 343 || item === 400 || item === 403 || item === 404 || item === 405 || item === 406 || item === 407 || item === 413 || item === 415 || item === 445 || item === 500))) : true) && ("timeoutStatus" in value["body"] ? (value["body"]["timeoutStatus"] === 100 || value["body"]["timeoutStatus"] === 408) : true) && ("flowControlError" in value["body"] ? (value["body"]["flowControlError"] === 406 || value["body"]["flowControlError"] === 407) : true) && ("deltaClockstampTicksPerQuarterNote" in value["body"] ? (typeof value["body"]["deltaClockstampTicksPerQuarterNote"] === "number" && Number.isInteger(value["body"]["deltaClockstampTicksPerQuarterNote"]) && value["body"]["deltaClockstampTicksPerQuarterNote"] >= 0 && value["body"]["deltaClockstampTicksPerQuarterNote"] <= 65535) : true) && ("cacheTime" in value["body"] ? (typeof value["body"]["cacheTime"] === "number" && Number.isInteger(value["body"]["cacheTime"]) && value["body"]["cacheTime"] >= 0 && true) : true) && ("flowControlAck" in value["body"] ? isPlainObject(value["body"]["flowControlAck"]) && ("requestId" in value["body"]["flowControlAck"] ? (typeof value["body"]["flowControlAck"]["requestId"] === "number" && Number.isInteger(value["body"]["flowControlAck"]["requestId"]) && value["body"]["flowControlAck"]["requestId"] >= 0 && value["body"]["flowControlAck"]["requestId"] <= 255) : true) && ("chunkNumber" in value["body"]["flowControlAck"] ? (typeof value["body"]["flowControlAck"]["chunkNumber"] === "number" && Number.isInteger(value["body"]["flowControlAck"]["chunkNumber"]) && value["body"]["flowControlAck"]["chunkNumber"] >= 0 && value["body"]["flowControlAck"]["chunkNumber"] <= 65535) : true) && ("messageLength" in value["body"]["flowControlAck"] ? (typeof value["body"]["flowControlAck"]["messageLength"] === "number" && Number.isInteger(value["body"]["flowControlAck"]["messageLength"]) && value["body"]["flowControlAck"]["messageLength"] >= 0 && value["body"]["flowControlAck"]["messageLength"] <= 65535) : true) && ("status" in value["body"]["flowControlAck"] ? value["body"]["flowControlAck"]["status"] === 17 : true) && hasOnlyKeys(value["body"]["flowControlAck"], ["requestId","chunkNumber","messageLength","status"]) : true) && ("flowControlNak" in value["body"] ? isPlainObject(value["body"]["flowControlNak"]) && ("status" in value["body"]["flowControlNak"] ? value["body"]["flowControlNak"]["status"] === 18 : true) && ("chunkNumber" in value["body"]["flowControlNak"] ? (typeof value["body"]["flowControlNak"]["chunkNumber"] === "number" && Number.isInteger(value["body"]["flowControlNak"]["chunkNumber"]) && value["body"]["flowControlNak"]["chunkNumber"] >= 0 && value["body"]["flowControlNak"]["chunkNumber"] <= 65535) : true) && hasOnlyKeys(value["body"]["flowControlNak"], ["status","chunkNumber"]) : true) && ("subscriptionCommand" in value["body"] ? (value["body"]["subscriptionCommand"] === "start" || value["body"]["subscriptionCommand"] === "partial" || value["body"]["subscriptionCommand"] === "full" || value["body"]["subscriptionCommand"] === "notify" || value["body"]["subscriptionCommand"] === "end") : true) && hasOnlyKeys(value["body"], ["command","subscriptionId","requestId","encoding","header","data","statusCodes","timeoutStatus","flowControlError","deltaClockstampTicksPerQuarterNote","cacheTime","flowControlAck","flowControlNak","subscriptionCommand"])) || (isPlainObject(value["body"]) && ("command" in value["body"] ? (value["body"]["command"] === "capInquiry" || value["body"]["command"] === "capReply" || value["body"]["command"] === "messageReport" || value["body"]["command"] === "messageReportReply" || value["body"]["command"] === "endReport") : true) && ("deviceId" in value["body"] ? (value["body"]["deviceId"] === 0 || value["body"]["deviceId"] === 1 || value["body"]["deviceId"] === 2 || value["body"]["deviceId"] === 3 || value["body"]["deviceId"] === 4 || value["body"]["deviceId"] === 5 || value["body"]["deviceId"] === 6 || value["body"]["deviceId"] === 7 || value["body"]["deviceId"] === 8 || value["body"]["deviceId"] === 9 || value["body"]["deviceId"] === 10 || value["body"]["deviceId"] === 11 || value["body"]["deviceId"] === 12 || value["body"]["deviceId"] === 13 || value["body"]["deviceId"] === 14 || value["body"]["deviceId"] === 15 || value["body"]["deviceId"] === 126 || value["body"]["deviceId"] === 127) : true) && ("messageDataControl" in value["body"] ? (value["body"]["messageDataControl"] === 0 || value["body"]["messageDataControl"] === 1 || value["body"]["messageDataControl"] === 127) : true) && ("systemMessages" in value["body"] ? isPlainObject(value["body"]["systemMessages"]) && ("mtcQuarterFrame" in value["body"]["systemMessages"] ? typeof value["body"]["systemMessages"]["mtcQuarterFrame"] === "boolean" : true) && ("songPosition" in value["body"]["systemMessages"] ? typeof value["body"]["systemMessages"]["songPosition"] === "boolean" : true) && ("songSelect" in value["body"]["systemMessages"] ? typeof value["body"]["systemMessages"]["songSelect"] === "boolean" : true) && hasOnlyKeys(value["body"]["systemMessages"], ["mtcQuarterFrame","songPosition","songSelect"]) : true) && ("channelControllerMessages" in value["body"] ? isPlainObject(value["body"]["channelControllerMessages"]) && ("pitchBend" in value["body"]["channelControllerMessages"] ? typeof value["body"]["channelControllerMessages"]["pitchBend"] === "boolean" : true) && ("controlChange" in value["body"]["channelControllerMessages"] ? typeof value["body"]["channelControllerMessages"]["controlChange"] === "boolean" : true) && ("registeredController" in value["body"]["channelControllerMessages"] ? typeof value["body"]["channelControllerMessages"]["registeredController"] === "boolean" : true) && ("assignableController" in value["body"]["channelControllerMessages"] ? typeof value["body"]["channelControllerMessages"]["assignableController"] === "boolean" : true) && ("programChange" in value["body"]["channelControllerMessages"] ? typeof value["body"]["channelControllerMessages"]["programChange"] === "boolean" : true) && ("channelPressure" in value["body"]["channelControllerMessages"] ? typeof value["body"]["channelControllerMessages"]["channelPressure"] === "boolean" : true) && hasOnlyKeys(value["body"]["channelControllerMessages"], ["pitchBend","controlChange","registeredController","assignableController","programChange","channelPressure"]) : true) && ("noteDataMessages" in value["body"] ? isPlainObject(value["body"]["noteDataMessages"]) && ("notes" in value["body"]["noteDataMessages"] ? typeof value["body"]["noteDataMessages"]["notes"] === "boolean" : true) && ("polyPressure" in value["body"]["noteDataMessages"] ? typeof value["body"]["noteDataMessages"]["polyPressure"] === "boolean" : true) && ("perNotePitchBend" in value["body"]["noteDataMessages"] ? typeof value["body"]["noteDataMessages"]["perNotePitchBend"] === "boolean" : true) && ("registeredPerNoteController" in value["body"]["noteDataMessages"] ? typeof value["body"]["noteDataMessages"]["registeredPerNoteController"] === "boolean" : true) && ("assignablePerNoteController" in value["body"]["noteDataMessages"] ? typeof value["body"]["noteDataMessages"]["assignablePerNoteController"] === "boolean" : true) && hasOnlyKeys(value["body"]["noteDataMessages"], ["notes","polyPressure","perNotePitchBend","registeredPerNoteController","assignablePerNoteController"]) : true) && ("supportedFeatures" in value["body"] ? isPlainObject(value["body"]["supportedFeatures"]) && ("messageReport" in value["body"]["supportedFeatures"] ? typeof value["body"]["supportedFeatures"]["messageReport"] === "boolean" : true) && hasOnlyKeys(value["body"]["supportedFeatures"], ["messageReport"]) : true) && hasOnlyKeys(value["body"], ["command","deviceId","messageDataControl","systemMessages","channelControllerMessages","noteDataMessages","supportedFeatures"])) || (isPlainObject(value["body"]) && ("ack" in value["body"] ? typeof value["body"]["ack"] === "boolean" : true) && ("statusCode" in value["body"] ? (typeof value["body"]["statusCode"] === "number" && Number.isInteger(value["body"]["statusCode"]) && value["body"]["statusCode"] >= 0 && value["body"]["statusCode"] <= 255) : true) && ("message" in value["body"] ? typeof value["body"]["message"] === "string" : true) && hasOnlyKeys(value["body"], ["ack","statusCode","message"])))) && hasOnlyKeys(value, ["scope","subId1","subId2","version","body"]);
}

export function isMidiCiProcessInquiryBody(value: unknown): value is MidiCiProcessInquiryBody {
  return isPlainObject(value) && ("command" in value ? (value["command"] === "capInquiry" || value["command"] === "capReply" || value["command"] === "messageReport" || value["command"] === "messageReportReply" || value["command"] === "endReport") : true) && ("deviceId" in value ? (value["deviceId"] === 0 || value["deviceId"] === 1 || value["deviceId"] === 2 || value["deviceId"] === 3 || value["deviceId"] === 4 || value["deviceId"] === 5 || value["deviceId"] === 6 || value["deviceId"] === 7 || value["deviceId"] === 8 || value["deviceId"] === 9 || value["deviceId"] === 10 || value["deviceId"] === 11 || value["deviceId"] === 12 || value["deviceId"] === 13 || value["deviceId"] === 14 || value["deviceId"] === 15 || value["deviceId"] === 126 || value["deviceId"] === 127) : true) && ("messageDataControl" in value ? (value["messageDataControl"] === 0 || value["messageDataControl"] === 1 || value["messageDataControl"] === 127) : true) && ("systemMessages" in value ? isPlainObject(value["systemMessages"]) && ("mtcQuarterFrame" in value["systemMessages"] ? typeof value["systemMessages"]["mtcQuarterFrame"] === "boolean" : true) && ("songPosition" in value["systemMessages"] ? typeof value["systemMessages"]["songPosition"] === "boolean" : true) && ("songSelect" in value["systemMessages"] ? typeof value["systemMessages"]["songSelect"] === "boolean" : true) && hasOnlyKeys(value["systemMessages"], ["mtcQuarterFrame","songPosition","songSelect"]) : true) && ("channelControllerMessages" in value ? isPlainObject(value["channelControllerMessages"]) && ("pitchBend" in value["channelControllerMessages"] ? typeof value["channelControllerMessages"]["pitchBend"] === "boolean" : true) && ("controlChange" in value["channelControllerMessages"] ? typeof value["channelControllerMessages"]["controlChange"] === "boolean" : true) && ("registeredController" in value["channelControllerMessages"] ? typeof value["channelControllerMessages"]["registeredController"] === "boolean" : true) && ("assignableController" in value["channelControllerMessages"] ? typeof value["channelControllerMessages"]["assignableController"] === "boolean" : true) && ("programChange" in value["channelControllerMessages"] ? typeof value["channelControllerMessages"]["programChange"] === "boolean" : true) && ("channelPressure" in value["channelControllerMessages"] ? typeof value["channelControllerMessages"]["channelPressure"] === "boolean" : true) && hasOnlyKeys(value["channelControllerMessages"], ["pitchBend","controlChange","registeredController","assignableController","programChange","channelPressure"]) : true) && ("noteDataMessages" in value ? isPlainObject(value["noteDataMessages"]) && ("notes" in value["noteDataMessages"] ? typeof value["noteDataMessages"]["notes"] === "boolean" : true) && ("polyPressure" in value["noteDataMessages"] ? typeof value["noteDataMessages"]["polyPressure"] === "boolean" : true) && ("perNotePitchBend" in value["noteDataMessages"] ? typeof value["noteDataMessages"]["perNotePitchBend"] === "boolean" : true) && ("registeredPerNoteController" in value["noteDataMessages"] ? typeof value["noteDataMessages"]["registeredPerNoteController"] === "boolean" : true) && ("assignablePerNoteController" in value["noteDataMessages"] ? typeof value["noteDataMessages"]["assignablePerNoteController"] === "boolean" : true) && hasOnlyKeys(value["noteDataMessages"], ["notes","polyPressure","perNotePitchBend","registeredPerNoteController","assignablePerNoteController"]) : true) && ("supportedFeatures" in value ? isPlainObject(value["supportedFeatures"]) && ("messageReport" in value["supportedFeatures"] ? typeof value["supportedFeatures"]["messageReport"] === "boolean" : true) && hasOnlyKeys(value["supportedFeatures"], ["messageReport"]) : true) && hasOnlyKeys(value, ["command","deviceId","messageDataControl","systemMessages","channelControllerMessages","noteDataMessages","supportedFeatures"]);
}

export function isMidiCiProfilesBody(value: unknown): value is MidiCiProfilesBody {
  return isPlainObject(value) && ("command" in value ? (value["command"] === "inquiry" || value["command"] === "reply" || value["command"] === "addedReport" || value["command"] === "removedReport" || value["command"] === "setOn" || value["command"] === "setOff" || value["command"] === "enabledReport" || value["command"] === "disabledReport" || value["command"] === "detailsInquiry" || value["command"] === "detailsReply" || value["command"] === "profileSpecificData") : true) && ("profileId" in value ? typeof value["profileId"] === "string" : true) && ("target" in value ? (value["target"] === "channel" || value["target"] === "group" || value["target"] === "functionBlock") : true) && ("channels" in value ? (Array.isArray(value["channels"]) && true && true && value["channels"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 15))) : true) && ("details" in value ? isPlainObject(value["details"]) && hasOnlyKeys(value["details"], []) : true) && hasOnlyKeys(value, ["command","profileId","target","channels","details"]);
}

export function isMidiCiPropertyExchangeBody(value: unknown): value is MidiCiPropertyExchangeBody {
  return isPlainObject(value) && ("command" in value ? (value["command"] === "capInquiry" || value["command"] === "capReply" || value["command"] === "get" || value["command"] === "getReply" || value["command"] === "set" || value["command"] === "setReply" || value["command"] === "subscribe" || value["command"] === "subscribeReply" || value["command"] === "notify" || value["command"] === "terminate") : true) && ("subscriptionId" in value ? typeof value["subscriptionId"] === "string" : true) && ("requestId" in value ? (typeof value["requestId"] === "number" && Number.isInteger(value["requestId"]) && value["requestId"] >= 0 && value["requestId"] <= 4294967295) : true) && ("encoding" in value ? (value["encoding"] === "json" || value["encoding"] === "binary" || value["encoding"] === "json+zlib" || value["encoding"] === "binary+zlib" || value["encoding"] === "mcoded7") : true) && ("header" in value ? isPlainObject(value["header"]) && ("resource" in value["header"] ? typeof value["header"]["resource"] === "string" : true) && ("resId" in value["header"] ? (typeof value["header"]["resId"] === "number" && Number.isInteger(value["header"]["resId"]) && value["header"]["resId"] >= 0 && value["header"]["resId"] <= 4294967295) : true) && ("encoding" in value["header"] ? (value["header"]["encoding"] === "json" || value["header"]["encoding"] === "binary" || value["header"]["encoding"] === "json+zlib" || value["header"]["encoding"] === "binary+zlib" || value["header"]["encoding"] === "mcoded7") : true) && ("flowControl" in value["header"] ? typeof value["header"]["flowControl"] === "boolean" : true) && ("status" in value["header"] ? (typeof value["header"]["status"] === "number" && Number.isInteger(value["header"]["status"]) && value["header"]["status"] >= 100 && value["header"]["status"] <= 999) : true) && ("message" in value["header"] ? typeof value["header"]["message"] === "string" : true) && ("cacheTime" in value["header"] ? (typeof value["header"]["cacheTime"] === "number" && Number.isInteger(value["header"]["cacheTime"]) && value["header"]["cacheTime"] >= 0 && true) : true) && ("mediaType" in value["header"] ? typeof value["header"]["mediaType"] === "string" : true) && hasOnlyKeys(value["header"], ["resource","resId","encoding","flowControl","status","message","cacheTime","mediaType"]) : true) && ("data" in value ? ((isPlainObject(value["data"]) && hasOnlyKeys(value["data"], [])) || ((Array.isArray(value["data"]) && true && true && value["data"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255))))) : true) && ("statusCodes" in value ? (Array.isArray(value["statusCodes"]) && true && true && value["statusCodes"].every(item => (item === 200 || item === 201 || item === 341 || item === 342 || item === 343 || item === 400 || item === 403 || item === 404 || item === 405 || item === 406 || item === 407 || item === 413 || item === 415 || item === 445 || item === 500))) : true) && ("timeoutStatus" in value ? (value["timeoutStatus"] === 100 || value["timeoutStatus"] === 408) : true) && ("flowControlError" in value ? (value["flowControlError"] === 406 || value["flowControlError"] === 407) : true) && ("deltaClockstampTicksPerQuarterNote" in value ? (typeof value["deltaClockstampTicksPerQuarterNote"] === "number" && Number.isInteger(value["deltaClockstampTicksPerQuarterNote"]) && value["deltaClockstampTicksPerQuarterNote"] >= 0 && value["deltaClockstampTicksPerQuarterNote"] <= 65535) : true) && ("cacheTime" in value ? (typeof value["cacheTime"] === "number" && Number.isInteger(value["cacheTime"]) && value["cacheTime"] >= 0 && true) : true) && ("flowControlAck" in value ? isPlainObject(value["flowControlAck"]) && ("requestId" in value["flowControlAck"] ? (typeof value["flowControlAck"]["requestId"] === "number" && Number.isInteger(value["flowControlAck"]["requestId"]) && value["flowControlAck"]["requestId"] >= 0 && value["flowControlAck"]["requestId"] <= 255) : true) && ("chunkNumber" in value["flowControlAck"] ? (typeof value["flowControlAck"]["chunkNumber"] === "number" && Number.isInteger(value["flowControlAck"]["chunkNumber"]) && value["flowControlAck"]["chunkNumber"] >= 0 && value["flowControlAck"]["chunkNumber"] <= 65535) : true) && ("messageLength" in value["flowControlAck"] ? (typeof value["flowControlAck"]["messageLength"] === "number" && Number.isInteger(value["flowControlAck"]["messageLength"]) && value["flowControlAck"]["messageLength"] >= 0 && value["flowControlAck"]["messageLength"] <= 65535) : true) && ("status" in value["flowControlAck"] ? value["flowControlAck"]["status"] === 17 : true) && hasOnlyKeys(value["flowControlAck"], ["requestId","chunkNumber","messageLength","status"]) : true) && ("flowControlNak" in value ? isPlainObject(value["flowControlNak"]) && ("status" in value["flowControlNak"] ? value["flowControlNak"]["status"] === 18 : true) && ("chunkNumber" in value["flowControlNak"] ? (typeof value["flowControlNak"]["chunkNumber"] === "number" && Number.isInteger(value["flowControlNak"]["chunkNumber"]) && value["flowControlNak"]["chunkNumber"] >= 0 && value["flowControlNak"]["chunkNumber"] <= 65535) : true) && hasOnlyKeys(value["flowControlNak"], ["status","chunkNumber"]) : true) && ("subscriptionCommand" in value ? (value["subscriptionCommand"] === "start" || value["subscriptionCommand"] === "partial" || value["subscriptionCommand"] === "full" || value["subscriptionCommand"] === "notify" || value["subscriptionCommand"] === "end") : true) && hasOnlyKeys(value, ["command","subscriptionId","requestId","encoding","header","data","statusCodes","timeoutStatus","flowControlError","deltaClockstampTicksPerQuarterNote","cacheTime","flowControlAck","flowControlNak","subscriptionCommand"]);
}

export function isNoteAttributeType(value: unknown): value is NoteAttributeType {
  return (typeof value === "number" && Number.isInteger(value) && value >= 0 && value <= 255);
}

export function isStreamBody(value: unknown): value is StreamBody {
  return isPlainObject(value) && ("opcode" in value && (value["opcode"] === 0 || value["opcode"] === 1 || value["opcode"] === 2 || value["opcode"] === 3 || value["opcode"] === 4 || value["opcode"] === 5 || value["opcode"] === 6 || value["opcode"] === 16 || value["opcode"] === 17 || value["opcode"] === 18 || value["opcode"] === 32 || value["opcode"] === 33)) && ("endpointDiscovery" in value ? isPlainObject(value["endpointDiscovery"]) && ("majorVersion" in value["endpointDiscovery"] ? (typeof value["endpointDiscovery"]["majorVersion"] === "number" && Number.isInteger(value["endpointDiscovery"]["majorVersion"]) && value["endpointDiscovery"]["majorVersion"] >= 0 && value["endpointDiscovery"]["majorVersion"] <= 255) : true) && ("minorVersion" in value["endpointDiscovery"] ? (typeof value["endpointDiscovery"]["minorVersion"] === "number" && Number.isInteger(value["endpointDiscovery"]["minorVersion"]) && value["endpointDiscovery"]["minorVersion"] >= 0 && value["endpointDiscovery"]["minorVersion"] <= 255) : true) && ("maxGroups" in value["endpointDiscovery"] ? (typeof value["endpointDiscovery"]["maxGroups"] === "number" && Number.isInteger(value["endpointDiscovery"]["maxGroups"]) && value["endpointDiscovery"]["maxGroups"] >= 0 && value["endpointDiscovery"]["maxGroups"] <= 15) : true) && ("filter" in value["endpointDiscovery"] ? isPlainObject(value["endpointDiscovery"]["filter"]) && ("endpointInfo" in value["endpointDiscovery"]["filter"] ? typeof value["endpointDiscovery"]["filter"]["endpointInfo"] === "boolean" : true) && ("deviceIdentity" in value["endpointDiscovery"]["filter"] ? typeof value["endpointDiscovery"]["filter"]["deviceIdentity"] === "boolean" : true) && ("endpointName" in value["endpointDiscovery"]["filter"] ? typeof value["endpointDiscovery"]["filter"]["endpointName"] === "boolean" : true) && ("productInstanceId" in value["endpointDiscovery"]["filter"] ? typeof value["endpointDiscovery"]["filter"]["productInstanceId"] === "boolean" : true) && ("streamConfig" in value["endpointDiscovery"]["filter"] ? typeof value["endpointDiscovery"]["filter"]["streamConfig"] === "boolean" : true) && hasOnlyKeys(value["endpointDiscovery"]["filter"], ["endpointInfo","deviceIdentity","endpointName","productInstanceId","streamConfig"]) : true) && hasOnlyKeys(value["endpointDiscovery"], ["majorVersion","minorVersion","maxGroups","filter"]) : true) && ("endpointInfoNotification" in value ? isPlainObject(value["endpointInfoNotification"]) && ("staticFunctionBlocks" in value["endpointInfoNotification"] ? typeof value["endpointInfoNotification"]["staticFunctionBlocks"] === "boolean" : true) && ("numberOfFunctionBlocks" in value["endpointInfoNotification"] ? (typeof value["endpointInfoNotification"]["numberOfFunctionBlocks"] === "number" && Number.isInteger(value["endpointInfoNotification"]["numberOfFunctionBlocks"]) && value["endpointInfoNotification"]["numberOfFunctionBlocks"] >= 0 && value["endpointInfoNotification"]["numberOfFunctionBlocks"] <= 32) : true) && ("umpVersionMajor" in value["endpointInfoNotification"] ? (typeof value["endpointInfoNotification"]["umpVersionMajor"] === "number" && Number.isInteger(value["endpointInfoNotification"]["umpVersionMajor"]) && value["endpointInfoNotification"]["umpVersionMajor"] >= 0 && value["endpointInfoNotification"]["umpVersionMajor"] <= 255) : true) && ("umpVersionMinor" in value["endpointInfoNotification"] ? (typeof value["endpointInfoNotification"]["umpVersionMinor"] === "number" && Number.isInteger(value["endpointInfoNotification"]["umpVersionMinor"]) && value["endpointInfoNotification"]["umpVersionMinor"] >= 0 && value["endpointInfoNotification"]["umpVersionMinor"] <= 255) : true) && ("midi2Supported" in value["endpointInfoNotification"] ? typeof value["endpointInfoNotification"]["midi2Supported"] === "boolean" : true) && ("midi1Supported" in value["endpointInfoNotification"] ? typeof value["endpointInfoNotification"]["midi1Supported"] === "boolean" : true) && ("jrTimestampsRx" in value["endpointInfoNotification"] ? typeof value["endpointInfoNotification"]["jrTimestampsRx"] === "boolean" : true) && ("jrTimestampsTx" in value["endpointInfoNotification"] ? typeof value["endpointInfoNotification"]["jrTimestampsTx"] === "boolean" : true) && hasOnlyKeys(value["endpointInfoNotification"], ["staticFunctionBlocks","numberOfFunctionBlocks","umpVersionMajor","umpVersionMinor","midi2Supported","midi1Supported","jrTimestampsRx","jrTimestampsTx"]) : true) && ("deviceIdentityNotification" in value ? isPlainObject(value["deviceIdentityNotification"]) && ("manufacturerId" in value["deviceIdentityNotification"] ? (((Array.isArray(value["deviceIdentityNotification"]["manufacturerId"]) && value["deviceIdentityNotification"]["manufacturerId"].length >= 1 && value["deviceIdentityNotification"]["manufacturerId"].length <= 1 && value["deviceIdentityNotification"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) || ((Array.isArray(value["deviceIdentityNotification"]["manufacturerId"]) && value["deviceIdentityNotification"]["manufacturerId"].length >= 3 && value["deviceIdentityNotification"]["manufacturerId"].length <= 3 && value["deviceIdentityNotification"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255))))) : true) && ("deviceFamily" in value["deviceIdentityNotification"] ? (typeof value["deviceIdentityNotification"]["deviceFamily"] === "number" && Number.isInteger(value["deviceIdentityNotification"]["deviceFamily"]) && value["deviceIdentityNotification"]["deviceFamily"] >= 0 && value["deviceIdentityNotification"]["deviceFamily"] <= 65535) : true) && ("deviceModel" in value["deviceIdentityNotification"] ? (typeof value["deviceIdentityNotification"]["deviceModel"] === "number" && Number.isInteger(value["deviceIdentityNotification"]["deviceModel"]) && value["deviceIdentityNotification"]["deviceModel"] >= 0 && value["deviceIdentityNotification"]["deviceModel"] <= 65535) : true) && ("softwareRevision" in value["deviceIdentityNotification"] ? (typeof value["deviceIdentityNotification"]["softwareRevision"] === "number" && Number.isInteger(value["deviceIdentityNotification"]["softwareRevision"]) && value["deviceIdentityNotification"]["softwareRevision"] >= 0 && value["deviceIdentityNotification"]["softwareRevision"] <= 4294967295) : true) && hasOnlyKeys(value["deviceIdentityNotification"], ["manufacturerId","deviceFamily","deviceModel","softwareRevision"]) : true) && ("endpointNameNotification" in value ? isPlainObject(value["endpointNameNotification"]) && ("name" in value["endpointNameNotification"] && typeof value["endpointNameNotification"]["name"] === "string") && hasOnlyKeys(value["endpointNameNotification"], ["name"]) : true) && ("productInstanceIdNotification" in value ? isPlainObject(value["productInstanceIdNotification"]) && ("productInstanceId" in value["productInstanceIdNotification"] && typeof value["productInstanceIdNotification"]["productInstanceId"] === "string") && hasOnlyKeys(value["productInstanceIdNotification"], ["productInstanceId"]) : true) && ("streamConfigRequest" in value ? isPlainObject(value["streamConfigRequest"]) && ("protocol" in value["streamConfigRequest"] ? (value["streamConfigRequest"]["protocol"] === "midi1" || value["streamConfigRequest"]["protocol"] === "midi2") : true) && ("jrTimestampsTx" in value["streamConfigRequest"] ? typeof value["streamConfigRequest"]["jrTimestampsTx"] === "boolean" : true) && ("jrTimestampsRx" in value["streamConfigRequest"] ? typeof value["streamConfigRequest"]["jrTimestampsRx"] === "boolean" : true) && hasOnlyKeys(value["streamConfigRequest"], ["protocol","jrTimestampsTx","jrTimestampsRx"]) : true) && ("streamConfigNotification" in value ? isPlainObject(value["streamConfigNotification"]) && ("protocol" in value["streamConfigNotification"] ? (value["streamConfigNotification"]["protocol"] === "midi1" || value["streamConfigNotification"]["protocol"] === "midi2") : true) && ("jrTimestampsTx" in value["streamConfigNotification"] ? typeof value["streamConfigNotification"]["jrTimestampsTx"] === "boolean" : true) && ("jrTimestampsRx" in value["streamConfigNotification"] ? typeof value["streamConfigNotification"]["jrTimestampsRx"] === "boolean" : true) && hasOnlyKeys(value["streamConfigNotification"], ["protocol","jrTimestampsTx","jrTimestampsRx"]) : true) && ("functionBlockDiscovery" in value ? isPlainObject(value["functionBlockDiscovery"]) && ("filterBitmap" in value["functionBlockDiscovery"] ? (typeof value["functionBlockDiscovery"]["filterBitmap"] === "number" && Number.isInteger(value["functionBlockDiscovery"]["filterBitmap"]) && value["functionBlockDiscovery"]["filterBitmap"] >= 0 && value["functionBlockDiscovery"]["filterBitmap"] <= 4294967295) : true) && hasOnlyKeys(value["functionBlockDiscovery"], ["filterBitmap"]) : true) && ("functionBlockInfo" in value ? isPlainObject(value["functionBlockInfo"]) && ("index" in value["functionBlockInfo"] ? (typeof value["functionBlockInfo"]["index"] === "number" && Number.isInteger(value["functionBlockInfo"]["index"]) && value["functionBlockInfo"]["index"] >= 0 && value["functionBlockInfo"]["index"] <= 255) : true) && ("firstGroup" in value["functionBlockInfo"] ? (typeof value["functionBlockInfo"]["firstGroup"] === "number" && Number.isInteger(value["functionBlockInfo"]["firstGroup"]) && value["functionBlockInfo"]["firstGroup"] >= 0 && value["functionBlockInfo"]["firstGroup"] <= 15) : true) && ("groupCount" in value["functionBlockInfo"] ? (typeof value["functionBlockInfo"]["groupCount"] === "number" && Number.isInteger(value["functionBlockInfo"]["groupCount"]) && value["functionBlockInfo"]["groupCount"] >= 0 && value["functionBlockInfo"]["groupCount"] <= 15) : true) && ("active" in value["functionBlockInfo"] ? typeof value["functionBlockInfo"]["active"] === "boolean" : true) && ("direction" in value["functionBlockInfo"] ? (value["functionBlockInfo"]["direction"] === 0 || value["functionBlockInfo"]["direction"] === 1 || value["functionBlockInfo"]["direction"] === 2 || value["functionBlockInfo"]["direction"] === 3) : true) && ("midi1Bandwidth" in value["functionBlockInfo"] ? (value["functionBlockInfo"]["midi1Bandwidth"] === 0 || value["functionBlockInfo"]["midi1Bandwidth"] === 1 || value["functionBlockInfo"]["midi1Bandwidth"] === 2) : true) && hasOnlyKeys(value["functionBlockInfo"], ["index","firstGroup","groupCount","active","direction","midi1Bandwidth"]) : true) && ("processInquiry" in value ? isPlainObject(value["processInquiry"]) && ("functionBlock" in value["processInquiry"] ? (typeof value["processInquiry"]["functionBlock"] === "number" && Number.isInteger(value["processInquiry"]["functionBlock"]) && value["processInquiry"]["functionBlock"] >= 0 && value["processInquiry"]["functionBlock"] <= 127) : true) && ("part" in value["processInquiry"] ? (typeof value["processInquiry"]["part"] === "number" && Number.isInteger(value["processInquiry"]["part"]) && value["processInquiry"]["part"] >= 0 && value["processInquiry"]["part"] <= 15) : true) && hasOnlyKeys(value["processInquiry"], ["functionBlock","part"]) : true) && ("processInquiryReply" in value ? isPlainObject(value["processInquiryReply"]) && ("functionBlock" in value["processInquiryReply"] ? (typeof value["processInquiryReply"]["functionBlock"] === "number" && Number.isInteger(value["processInquiryReply"]["functionBlock"]) && value["processInquiryReply"]["functionBlock"] >= 0 && value["processInquiryReply"]["functionBlock"] <= 127) : true) && ("part" in value["processInquiryReply"] ? (typeof value["processInquiryReply"]["part"] === "number" && Number.isInteger(value["processInquiryReply"]["part"]) && value["processInquiryReply"]["part"] >= 0 && value["processInquiryReply"]["part"] <= 15) : true) && hasOnlyKeys(value["processInquiryReply"], ["functionBlock","part"]) : true) && hasOnlyKeys(value, ["opcode","endpointDiscovery","endpointInfoNotification","deviceIdentityNotification","endpointNameNotification","productInstanceIdNotification","streamConfigRequest","streamConfigNotification","functionBlockDiscovery","functionBlockInfo","processInquiry","processInquiryReply"]);
}

export function isStreamOpcode(value: unknown): value is StreamOpcode {
  return (value === 0 || value === 1 || value === 2 || value === 3 || value === 4 || value === 5 || value === 6 || value === 16 || value === 17 || value === 18 || value === 32 || value === 33);
}

export function isSysEx7Body(value: unknown): value is SysEx7Body {
  return isPlainObject(value) && ("manufacturerId" in value && (((Array.isArray(value["manufacturerId"]) && value["manufacturerId"].length >= 1 && value["manufacturerId"].length <= 1 && value["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) || ((Array.isArray(value["manufacturerId"]) && value["manufacturerId"].length >= 3 && value["manufacturerId"].length <= 3 && value["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))))) && ("packets" in value && (Array.isArray(value["packets"]) && value["packets"].length >= 1 && true && value["packets"].every(item => isPlainObject(item) && ("streamStatus" in item && (item["streamStatus"] === "single" || item["streamStatus"] === "start" || item["streamStatus"] === "continue" || item["streamStatus"] === "end")) && ("payload" in item && (Array.isArray(item["payload"]) && item["payload"].length >= 0 && item["payload"].length <= 6 && item["payload"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) && hasOnlyKeys(item, ["streamStatus","payload"])))) && hasOnlyKeys(value, ["manufacturerId","packets"]);
}

export function isSysEx7Packet(value: unknown): value is SysEx7Packet {
  return isPlainObject(value) && ("streamStatus" in value && (value["streamStatus"] === "single" || value["streamStatus"] === "start" || value["streamStatus"] === "continue" || value["streamStatus"] === "end")) && ("payload" in value && (Array.isArray(value["payload"]) && value["payload"].length >= 0 && value["payload"].length <= 6 && value["payload"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) && hasOnlyKeys(value, ["streamStatus","payload"]);
}

export function isSystemCommonRealtimeBody(value: unknown): value is SystemCommonRealtimeBody {
  return isPlainObject(value) && ("status" in value && (value["status"] === 241 || value["status"] === 242 || value["status"] === 243 || value["status"] === 246 || value["status"] === 248 || value["status"] === 250 || value["status"] === 251 || value["status"] === 252 || value["status"] === 254 || value["status"] === 255)) && ("data1" in value ? (typeof value["data1"] === "number" && Number.isInteger(value["data1"]) && value["data1"] >= 0 && value["data1"] <= 255) : true) && ("data2" in value ? (typeof value["data2"] === "number" && Number.isInteger(value["data2"]) && value["data2"] >= 0 && value["data2"] <= 255) : true) && hasOnlyKeys(value, ["status","data1","data2"]);
}

export function isSystemStatus(value: unknown): value is SystemStatus {
  return (value === 241 || value === 242 || value === 243 || value === 246 || value === 248 || value === 250 || value === 251 || value === 252 || value === 254 || value === 255);
}

export function isUint14(value: unknown): value is Uint14 {
  return (typeof value === "number" && Number.isInteger(value) && value >= 0 && value <= 16383);
}

export function isUint16(value: unknown): value is Uint16 {
  return (typeof value === "number" && Number.isInteger(value) && value >= 0 && value <= 65535);
}

export function isUint21(value: unknown): value is Uint21 {
  return (typeof value === "number" && Number.isInteger(value) && value >= 0 && value <= 2097151);
}

export function isUint28(value: unknown): value is Uint28 {
  return (typeof value === "number" && Number.isInteger(value) && value >= 0 && value <= 268435455);
}

export function isUint32(value: unknown): value is Uint32 {
  return (typeof value === "number" && Number.isInteger(value) && value >= 0 && value <= 4294967295);
}

export function isUint4(value: unknown): value is Uint4 {
  return (typeof value === "number" && Number.isInteger(value) && value >= 0 && value <= 15);
}

export function isUint7(value: unknown): value is Uint7 {
  return (typeof value === "number" && Number.isInteger(value) && value >= 0 && value <= 127);
}

export function isUint8(value: unknown): value is Uint8 {
  return (typeof value === "number" && Number.isInteger(value) && value >= 0 && value <= 255);
}

export function isUmpHeader128(value: unknown): value is UmpHeader128 {
  return isPlainObject(value) && ("messageType" in value && (value["messageType"] === 5 || value["messageType"] === 13)) && ("group" in value ? isUint4(value["group"]) : true) && hasOnlyKeys(value, ["messageType","group"]);
}

export function isUmpHeader32(value: unknown): value is UmpHeader32 {
  return isPlainObject(value) && ("messageType" in value && (value["messageType"] === 0 || value["messageType"] === 1 || value["messageType"] === 2 || value["messageType"] === 3 || value["messageType"] === 15)) && ("group" in value ? isUint4(value["group"]) : true) && hasOnlyKeys(value, ["messageType","group"]);
}

export function isUmpHeader64(value: unknown): value is UmpHeader64 {
  return isPlainObject(value) && ("messageType" in value && value["messageType"] === 4) && ("group" in value && isUint4(value["group"])) && ("statusNibble" in value && (typeof value["statusNibble"] === "number" && Number.isInteger(value["statusNibble"]) && value["statusNibble"] >= 8 && value["statusNibble"] <= 15)) && ("channel" in value && (typeof value["channel"] === "number" && Number.isInteger(value["channel"]) && value["channel"] >= 0 && value["channel"] <= 15)) && hasOnlyKeys(value, ["messageType","group","statusNibble","channel"]);
}

export function isUmpMessageType(value: unknown): value is UmpMessageType {
  return (value === 0 || value === 1 || value === 2 || value === 3 || value === 4 || value === 5 || value === 13 || value === 15);
}

export function isUmpPacket(value: unknown): value is UmpPacket {
  return ((isPlainObject(value) && ("messageType" in value && (value["messageType"] === 0 || value["messageType"] === 1 || value["messageType"] === 2 || value["messageType"] === 3 || value["messageType"] === 15)) && ("group" in value ? isUint4(value["group"]) : true) && ("body" in value && ((isPlainObject(value["body"]) && ("opcode" in value["body"] && (value["body"]["opcode"] === 0 || value["body"]["opcode"] === 1 || value["body"]["opcode"] === 2)) && ("jrClock" in value["body"] ? isPlainObject(value["body"]["jrClock"]) && ("timestamp32" in value["body"]["jrClock"] && (typeof value["body"]["jrClock"]["timestamp32"] === "number" && Number.isInteger(value["body"]["jrClock"]["timestamp32"]) && value["body"]["jrClock"]["timestamp32"] >= 0 && value["body"]["jrClock"]["timestamp32"] <= 4294967295)) && hasOnlyKeys(value["body"]["jrClock"], ["timestamp32"]) : true) && ("jrTimestamp" in value["body"] ? isPlainObject(value["body"]["jrTimestamp"]) && ("time15" in value["body"]["jrTimestamp"] && (typeof value["body"]["jrTimestamp"]["time15"] === "number" && Number.isInteger(value["body"]["jrTimestamp"]["time15"]) && value["body"]["jrTimestamp"]["time15"] >= 0 && value["body"]["jrTimestamp"]["time15"] <= 32767)) && hasOnlyKeys(value["body"]["jrTimestamp"], ["time15"]) : true) && hasOnlyKeys(value["body"], ["opcode","jrClock","jrTimestamp"])) || (isPlainObject(value["body"]) && ("status" in value["body"] && (value["body"]["status"] === 241 || value["body"]["status"] === 242 || value["body"]["status"] === 243 || value["body"]["status"] === 246 || value["body"]["status"] === 248 || value["body"]["status"] === 250 || value["body"]["status"] === 251 || value["body"]["status"] === 252 || value["body"]["status"] === 254 || value["body"]["status"] === 255)) && ("data1" in value["body"] ? (typeof value["body"]["data1"] === "number" && Number.isInteger(value["body"]["data1"]) && value["body"]["data1"] >= 0 && value["body"]["data1"] <= 255) : true) && ("data2" in value["body"] ? (typeof value["body"]["data2"] === "number" && Number.isInteger(value["body"]["data2"]) && value["body"]["data2"] >= 0 && value["body"]["data2"] <= 255) : true) && hasOnlyKeys(value["body"], ["status","data1","data2"])) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] && (value["body"]["statusNibble"] === 8 || value["body"]["statusNibble"] === 9 || value["body"]["statusNibble"] === 10 || value["body"]["statusNibble"] === 11 || value["body"]["statusNibble"] === 12 || value["body"]["statusNibble"] === 13 || value["body"]["statusNibble"] === 14)) && ("channel" in value["body"] && (typeof value["body"]["channel"] === "number" && Number.isInteger(value["body"]["channel"]) && value["body"]["channel"] >= 0 && value["body"]["channel"] <= 15)) && ("noteNumber" in value["body"] ? (typeof value["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["noteNumber"]) && value["body"]["noteNumber"] >= 0 && value["body"]["noteNumber"] <= 127) : true) && ("velocity7" in value["body"] ? (typeof value["body"]["velocity7"] === "number" && Number.isInteger(value["body"]["velocity7"]) && value["body"]["velocity7"] >= 0 && value["body"]["velocity7"] <= 127) : true) && ("pressure7" in value["body"] ? (typeof value["body"]["pressure7"] === "number" && Number.isInteger(value["body"]["pressure7"]) && value["body"]["pressure7"] >= 0 && value["body"]["pressure7"] <= 127) : true) && ("control" in value["body"] ? (typeof value["body"]["control"] === "number" && Number.isInteger(value["body"]["control"]) && value["body"]["control"] >= 0 && value["body"]["control"] <= 127) : true) && ("value7" in value["body"] ? (typeof value["body"]["value7"] === "number" && Number.isInteger(value["body"]["value7"]) && value["body"]["value7"] >= 0 && value["body"]["value7"] <= 127) : true) && ("program" in value["body"] ? (typeof value["body"]["program"] === "number" && Number.isInteger(value["body"]["program"]) && value["body"]["program"] >= 0 && value["body"]["program"] <= 127) : true) && ("pitchBend14" in value["body"] ? (typeof value["body"]["pitchBend14"] === "number" && Number.isInteger(value["body"]["pitchBend14"]) && value["body"]["pitchBend14"] >= 0 && value["body"]["pitchBend14"] <= 16383) : true) && hasOnlyKeys(value["body"], ["statusNibble","channel","noteNumber","velocity7","pressure7","control","value7","program","pitchBend14"])) || (isPlainObject(value["body"]) && ("manufacturerId" in value["body"] && (((Array.isArray(value["body"]["manufacturerId"]) && value["body"]["manufacturerId"].length >= 1 && value["body"]["manufacturerId"].length <= 1 && value["body"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) || ((Array.isArray(value["body"]["manufacturerId"]) && value["body"]["manufacturerId"].length >= 3 && value["body"]["manufacturerId"].length <= 3 && value["body"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))))) && ("packets" in value["body"] && (Array.isArray(value["body"]["packets"]) && value["body"]["packets"].length >= 1 && true && value["body"]["packets"].every(item => isPlainObject(item) && ("streamStatus" in item && (item["streamStatus"] === "single" || item["streamStatus"] === "start" || item["streamStatus"] === "continue" || item["streamStatus"] === "end")) && ("payload" in item && (Array.isArray(item["payload"]) && item["payload"].length >= 0 && item["payload"].length <= 6 && item["payload"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) && hasOnlyKeys(item, ["streamStatus","payload"])))) && hasOnlyKeys(value["body"], ["manufacturerId","packets"])) || (isPlainObject(value["body"]) && ("opcode" in value["body"] && (value["body"]["opcode"] === 0 || value["body"]["opcode"] === 1 || value["body"]["opcode"] === 2 || value["body"]["opcode"] === 3 || value["body"]["opcode"] === 4 || value["body"]["opcode"] === 5 || value["body"]["opcode"] === 6 || value["body"]["opcode"] === 16 || value["body"]["opcode"] === 17 || value["body"]["opcode"] === 18 || value["body"]["opcode"] === 32 || value["body"]["opcode"] === 33)) && ("endpointDiscovery" in value["body"] ? isPlainObject(value["body"]["endpointDiscovery"]) && ("majorVersion" in value["body"]["endpointDiscovery"] ? (typeof value["body"]["endpointDiscovery"]["majorVersion"] === "number" && Number.isInteger(value["body"]["endpointDiscovery"]["majorVersion"]) && value["body"]["endpointDiscovery"]["majorVersion"] >= 0 && value["body"]["endpointDiscovery"]["majorVersion"] <= 255) : true) && ("minorVersion" in value["body"]["endpointDiscovery"] ? (typeof value["body"]["endpointDiscovery"]["minorVersion"] === "number" && Number.isInteger(value["body"]["endpointDiscovery"]["minorVersion"]) && value["body"]["endpointDiscovery"]["minorVersion"] >= 0 && value["body"]["endpointDiscovery"]["minorVersion"] <= 255) : true) && ("maxGroups" in value["body"]["endpointDiscovery"] ? (typeof value["body"]["endpointDiscovery"]["maxGroups"] === "number" && Number.isInteger(value["body"]["endpointDiscovery"]["maxGroups"]) && value["body"]["endpointDiscovery"]["maxGroups"] >= 0 && value["body"]["endpointDiscovery"]["maxGroups"] <= 15) : true) && ("filter" in value["body"]["endpointDiscovery"] ? isPlainObject(value["body"]["endpointDiscovery"]["filter"]) && ("endpointInfo" in value["body"]["endpointDiscovery"]["filter"] ? typeof value["body"]["endpointDiscovery"]["filter"]["endpointInfo"] === "boolean" : true) && ("deviceIdentity" in value["body"]["endpointDiscovery"]["filter"] ? typeof value["body"]["endpointDiscovery"]["filter"]["deviceIdentity"] === "boolean" : true) && ("endpointName" in value["body"]["endpointDiscovery"]["filter"] ? typeof value["body"]["endpointDiscovery"]["filter"]["endpointName"] === "boolean" : true) && ("productInstanceId" in value["body"]["endpointDiscovery"]["filter"] ? typeof value["body"]["endpointDiscovery"]["filter"]["productInstanceId"] === "boolean" : true) && ("streamConfig" in value["body"]["endpointDiscovery"]["filter"] ? typeof value["body"]["endpointDiscovery"]["filter"]["streamConfig"] === "boolean" : true) && hasOnlyKeys(value["body"]["endpointDiscovery"]["filter"], ["endpointInfo","deviceIdentity","endpointName","productInstanceId","streamConfig"]) : true) && hasOnlyKeys(value["body"]["endpointDiscovery"], ["majorVersion","minorVersion","maxGroups","filter"]) : true) && ("endpointInfoNotification" in value["body"] ? isPlainObject(value["body"]["endpointInfoNotification"]) && ("staticFunctionBlocks" in value["body"]["endpointInfoNotification"] ? typeof value["body"]["endpointInfoNotification"]["staticFunctionBlocks"] === "boolean" : true) && ("numberOfFunctionBlocks" in value["body"]["endpointInfoNotification"] ? (typeof value["body"]["endpointInfoNotification"]["numberOfFunctionBlocks"] === "number" && Number.isInteger(value["body"]["endpointInfoNotification"]["numberOfFunctionBlocks"]) && value["body"]["endpointInfoNotification"]["numberOfFunctionBlocks"] >= 0 && value["body"]["endpointInfoNotification"]["numberOfFunctionBlocks"] <= 32) : true) && ("umpVersionMajor" in value["body"]["endpointInfoNotification"] ? (typeof value["body"]["endpointInfoNotification"]["umpVersionMajor"] === "number" && Number.isInteger(value["body"]["endpointInfoNotification"]["umpVersionMajor"]) && value["body"]["endpointInfoNotification"]["umpVersionMajor"] >= 0 && value["body"]["endpointInfoNotification"]["umpVersionMajor"] <= 255) : true) && ("umpVersionMinor" in value["body"]["endpointInfoNotification"] ? (typeof value["body"]["endpointInfoNotification"]["umpVersionMinor"] === "number" && Number.isInteger(value["body"]["endpointInfoNotification"]["umpVersionMinor"]) && value["body"]["endpointInfoNotification"]["umpVersionMinor"] >= 0 && value["body"]["endpointInfoNotification"]["umpVersionMinor"] <= 255) : true) && ("midi2Supported" in value["body"]["endpointInfoNotification"] ? typeof value["body"]["endpointInfoNotification"]["midi2Supported"] === "boolean" : true) && ("midi1Supported" in value["body"]["endpointInfoNotification"] ? typeof value["body"]["endpointInfoNotification"]["midi1Supported"] === "boolean" : true) && ("jrTimestampsRx" in value["body"]["endpointInfoNotification"] ? typeof value["body"]["endpointInfoNotification"]["jrTimestampsRx"] === "boolean" : true) && ("jrTimestampsTx" in value["body"]["endpointInfoNotification"] ? typeof value["body"]["endpointInfoNotification"]["jrTimestampsTx"] === "boolean" : true) && hasOnlyKeys(value["body"]["endpointInfoNotification"], ["staticFunctionBlocks","numberOfFunctionBlocks","umpVersionMajor","umpVersionMinor","midi2Supported","midi1Supported","jrTimestampsRx","jrTimestampsTx"]) : true) && ("deviceIdentityNotification" in value["body"] ? isPlainObject(value["body"]["deviceIdentityNotification"]) && ("manufacturerId" in value["body"]["deviceIdentityNotification"] ? (((Array.isArray(value["body"]["deviceIdentityNotification"]["manufacturerId"]) && value["body"]["deviceIdentityNotification"]["manufacturerId"].length >= 1 && value["body"]["deviceIdentityNotification"]["manufacturerId"].length <= 1 && value["body"]["deviceIdentityNotification"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) || ((Array.isArray(value["body"]["deviceIdentityNotification"]["manufacturerId"]) && value["body"]["deviceIdentityNotification"]["manufacturerId"].length >= 3 && value["body"]["deviceIdentityNotification"]["manufacturerId"].length <= 3 && value["body"]["deviceIdentityNotification"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255))))) : true) && ("deviceFamily" in value["body"]["deviceIdentityNotification"] ? (typeof value["body"]["deviceIdentityNotification"]["deviceFamily"] === "number" && Number.isInteger(value["body"]["deviceIdentityNotification"]["deviceFamily"]) && value["body"]["deviceIdentityNotification"]["deviceFamily"] >= 0 && value["body"]["deviceIdentityNotification"]["deviceFamily"] <= 65535) : true) && ("deviceModel" in value["body"]["deviceIdentityNotification"] ? (typeof value["body"]["deviceIdentityNotification"]["deviceModel"] === "number" && Number.isInteger(value["body"]["deviceIdentityNotification"]["deviceModel"]) && value["body"]["deviceIdentityNotification"]["deviceModel"] >= 0 && value["body"]["deviceIdentityNotification"]["deviceModel"] <= 65535) : true) && ("softwareRevision" in value["body"]["deviceIdentityNotification"] ? (typeof value["body"]["deviceIdentityNotification"]["softwareRevision"] === "number" && Number.isInteger(value["body"]["deviceIdentityNotification"]["softwareRevision"]) && value["body"]["deviceIdentityNotification"]["softwareRevision"] >= 0 && value["body"]["deviceIdentityNotification"]["softwareRevision"] <= 4294967295) : true) && hasOnlyKeys(value["body"]["deviceIdentityNotification"], ["manufacturerId","deviceFamily","deviceModel","softwareRevision"]) : true) && ("endpointNameNotification" in value["body"] ? isPlainObject(value["body"]["endpointNameNotification"]) && ("name" in value["body"]["endpointNameNotification"] && typeof value["body"]["endpointNameNotification"]["name"] === "string") && hasOnlyKeys(value["body"]["endpointNameNotification"], ["name"]) : true) && ("productInstanceIdNotification" in value["body"] ? isPlainObject(value["body"]["productInstanceIdNotification"]) && ("productInstanceId" in value["body"]["productInstanceIdNotification"] && typeof value["body"]["productInstanceIdNotification"]["productInstanceId"] === "string") && hasOnlyKeys(value["body"]["productInstanceIdNotification"], ["productInstanceId"]) : true) && ("streamConfigRequest" in value["body"] ? isPlainObject(value["body"]["streamConfigRequest"]) && ("protocol" in value["body"]["streamConfigRequest"] ? (value["body"]["streamConfigRequest"]["protocol"] === "midi1" || value["body"]["streamConfigRequest"]["protocol"] === "midi2") : true) && ("jrTimestampsTx" in value["body"]["streamConfigRequest"] ? typeof value["body"]["streamConfigRequest"]["jrTimestampsTx"] === "boolean" : true) && ("jrTimestampsRx" in value["body"]["streamConfigRequest"] ? typeof value["body"]["streamConfigRequest"]["jrTimestampsRx"] === "boolean" : true) && hasOnlyKeys(value["body"]["streamConfigRequest"], ["protocol","jrTimestampsTx","jrTimestampsRx"]) : true) && ("streamConfigNotification" in value["body"] ? isPlainObject(value["body"]["streamConfigNotification"]) && ("protocol" in value["body"]["streamConfigNotification"] ? (value["body"]["streamConfigNotification"]["protocol"] === "midi1" || value["body"]["streamConfigNotification"]["protocol"] === "midi2") : true) && ("jrTimestampsTx" in value["body"]["streamConfigNotification"] ? typeof value["body"]["streamConfigNotification"]["jrTimestampsTx"] === "boolean" : true) && ("jrTimestampsRx" in value["body"]["streamConfigNotification"] ? typeof value["body"]["streamConfigNotification"]["jrTimestampsRx"] === "boolean" : true) && hasOnlyKeys(value["body"]["streamConfigNotification"], ["protocol","jrTimestampsTx","jrTimestampsRx"]) : true) && ("functionBlockDiscovery" in value["body"] ? isPlainObject(value["body"]["functionBlockDiscovery"]) && ("filterBitmap" in value["body"]["functionBlockDiscovery"] ? (typeof value["body"]["functionBlockDiscovery"]["filterBitmap"] === "number" && Number.isInteger(value["body"]["functionBlockDiscovery"]["filterBitmap"]) && value["body"]["functionBlockDiscovery"]["filterBitmap"] >= 0 && value["body"]["functionBlockDiscovery"]["filterBitmap"] <= 4294967295) : true) && hasOnlyKeys(value["body"]["functionBlockDiscovery"], ["filterBitmap"]) : true) && ("functionBlockInfo" in value["body"] ? isPlainObject(value["body"]["functionBlockInfo"]) && ("index" in value["body"]["functionBlockInfo"] ? (typeof value["body"]["functionBlockInfo"]["index"] === "number" && Number.isInteger(value["body"]["functionBlockInfo"]["index"]) && value["body"]["functionBlockInfo"]["index"] >= 0 && value["body"]["functionBlockInfo"]["index"] <= 255) : true) && ("firstGroup" in value["body"]["functionBlockInfo"] ? (typeof value["body"]["functionBlockInfo"]["firstGroup"] === "number" && Number.isInteger(value["body"]["functionBlockInfo"]["firstGroup"]) && value["body"]["functionBlockInfo"]["firstGroup"] >= 0 && value["body"]["functionBlockInfo"]["firstGroup"] <= 15) : true) && ("groupCount" in value["body"]["functionBlockInfo"] ? (typeof value["body"]["functionBlockInfo"]["groupCount"] === "number" && Number.isInteger(value["body"]["functionBlockInfo"]["groupCount"]) && value["body"]["functionBlockInfo"]["groupCount"] >= 0 && value["body"]["functionBlockInfo"]["groupCount"] <= 15) : true) && ("active" in value["body"]["functionBlockInfo"] ? typeof value["body"]["functionBlockInfo"]["active"] === "boolean" : true) && ("direction" in value["body"]["functionBlockInfo"] ? (value["body"]["functionBlockInfo"]["direction"] === 0 || value["body"]["functionBlockInfo"]["direction"] === 1 || value["body"]["functionBlockInfo"]["direction"] === 2 || value["body"]["functionBlockInfo"]["direction"] === 3) : true) && ("midi1Bandwidth" in value["body"]["functionBlockInfo"] ? (value["body"]["functionBlockInfo"]["midi1Bandwidth"] === 0 || value["body"]["functionBlockInfo"]["midi1Bandwidth"] === 1 || value["body"]["functionBlockInfo"]["midi1Bandwidth"] === 2) : true) && hasOnlyKeys(value["body"]["functionBlockInfo"], ["index","firstGroup","groupCount","active","direction","midi1Bandwidth"]) : true) && ("processInquiry" in value["body"] ? isPlainObject(value["body"]["processInquiry"]) && ("functionBlock" in value["body"]["processInquiry"] ? (typeof value["body"]["processInquiry"]["functionBlock"] === "number" && Number.isInteger(value["body"]["processInquiry"]["functionBlock"]) && value["body"]["processInquiry"]["functionBlock"] >= 0 && value["body"]["processInquiry"]["functionBlock"] <= 127) : true) && ("part" in value["body"]["processInquiry"] ? (typeof value["body"]["processInquiry"]["part"] === "number" && Number.isInteger(value["body"]["processInquiry"]["part"]) && value["body"]["processInquiry"]["part"] >= 0 && value["body"]["processInquiry"]["part"] <= 15) : true) && hasOnlyKeys(value["body"]["processInquiry"], ["functionBlock","part"]) : true) && ("processInquiryReply" in value["body"] ? isPlainObject(value["body"]["processInquiryReply"]) && ("functionBlock" in value["body"]["processInquiryReply"] ? (typeof value["body"]["processInquiryReply"]["functionBlock"] === "number" && Number.isInteger(value["body"]["processInquiryReply"]["functionBlock"]) && value["body"]["processInquiryReply"]["functionBlock"] >= 0 && value["body"]["processInquiryReply"]["functionBlock"] <= 127) : true) && ("part" in value["body"]["processInquiryReply"] ? (typeof value["body"]["processInquiryReply"]["part"] === "number" && Number.isInteger(value["body"]["processInquiryReply"]["part"]) && value["body"]["processInquiryReply"]["part"] >= 0 && value["body"]["processInquiryReply"]["part"] <= 15) : true) && hasOnlyKeys(value["body"]["processInquiryReply"], ["functionBlock","part"]) : true) && hasOnlyKeys(value["body"], ["opcode","endpointDiscovery","endpointInfoNotification","deviceIdentityNotification","endpointNameNotification","productInstanceIdNotification","streamConfigRequest","streamConfigNotification","functionBlockDiscovery","functionBlockInfo","processInquiry","processInquiryReply"])))) && hasOnlyKeys(value, ["messageType","group","body"])) || (isPlainObject(value) && ("messageType" in value && value["messageType"] === 4) && ("group" in value && isUint4(value["group"])) && ("statusNibble" in value && (value["statusNibble"] === 8 || value["statusNibble"] === 9 || value["statusNibble"] === 10 || value["statusNibble"] === 11 || value["statusNibble"] === 12 || value["statusNibble"] === 13 || value["statusNibble"] === 14 || value["statusNibble"] === 15)) && ("channel" in value && (typeof value["channel"] === "number" && Number.isInteger(value["channel"]) && value["channel"] >= 0 && value["channel"] <= 15)) && ("body" in value && (isPlainObject(value["body"]) && ("statusNibble" in value["body"] && (value["body"]["statusNibble"] === 8 || value["body"]["statusNibble"] === 9 || value["body"]["statusNibble"] === 10 || value["body"]["statusNibble"] === 11 || value["body"]["statusNibble"] === 12 || value["body"]["statusNibble"] === 13 || value["body"]["statusNibble"] === 14 || value["body"]["statusNibble"] === 15)) && ("channel" in value["body"] && (typeof value["body"]["channel"] === "number" && Number.isInteger(value["body"]["channel"]) && value["body"]["channel"] >= 0 && value["body"]["channel"] <= 15)) && hasOnlyKeys(value["body"], ["statusNibble","channel","body"])) && ((isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 8 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("velocity16" in value["body"]["body"] && (typeof value["body"]["body"]["velocity16"] === "number" && Number.isInteger(value["body"]["body"]["velocity16"]) && value["body"]["body"]["velocity16"] >= 0 && value["body"]["body"]["velocity16"] <= 65535)) && ("attributeType" in value["body"]["body"] ? (typeof value["body"]["body"]["attributeType"] === "number" && Number.isInteger(value["body"]["body"]["attributeType"]) && value["body"]["body"]["attributeType"] >= 0 && value["body"]["body"]["attributeType"] <= 255) : true) && ("attributeData16" in value["body"]["body"] ? (typeof value["body"]["body"]["attributeData16"] === "number" && Number.isInteger(value["body"]["body"]["attributeData16"]) && value["body"]["body"]["attributeData16"] >= 0 && value["body"]["body"]["attributeData16"] <= 65535) : true) && hasOnlyKeys(value["body"]["body"], ["noteNumber","velocity16","attributeType","attributeData16"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 9 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("velocity16" in value["body"]["body"] && (typeof value["body"]["body"]["velocity16"] === "number" && Number.isInteger(value["body"]["body"]["velocity16"]) && value["body"]["body"]["velocity16"] >= 0 && value["body"]["body"]["velocity16"] <= 65535)) && ("attributeType" in value["body"]["body"] ? (typeof value["body"]["body"]["attributeType"] === "number" && Number.isInteger(value["body"]["body"]["attributeType"]) && value["body"]["body"]["attributeType"] >= 0 && value["body"]["body"]["attributeType"] <= 255) : true) && ("attributeData16" in value["body"]["body"] ? (typeof value["body"]["body"]["attributeData16"] === "number" && Number.isInteger(value["body"]["body"]["attributeData16"]) && value["body"]["body"]["attributeData16"] >= 0 && value["body"]["body"]["attributeData16"] <= 65535) : true) && hasOnlyKeys(value["body"]["body"], ["noteNumber","velocity16","attributeType","attributeData16"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 10 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("polyPressure32" in value["body"]["body"] && (typeof value["body"]["body"]["polyPressure32"] === "number" && Number.isInteger(value["body"]["body"]["polyPressure32"]) && value["body"]["body"]["polyPressure32"] >= 0 && value["body"]["body"]["polyPressure32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["noteNumber","polyPressure32"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 11 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("control" in value["body"]["body"] && (typeof value["body"]["body"]["control"] === "number" && Number.isInteger(value["body"]["body"]["control"]) && value["body"]["body"]["control"] >= 0 && value["body"]["body"]["control"] <= 127)) && ("controlValue32" in value["body"]["body"] && (typeof value["body"]["body"]["controlValue32"] === "number" && Number.isInteger(value["body"]["body"]["controlValue32"]) && value["body"]["body"]["controlValue32"] >= 0 && value["body"]["body"]["controlValue32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["control","controlValue32"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 12 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("program" in value["body"]["body"] && (typeof value["body"]["body"]["program"] === "number" && Number.isInteger(value["body"]["body"]["program"]) && value["body"]["body"]["program"] >= 0 && value["body"]["body"]["program"] <= 127)) && ("bankMsb" in value["body"]["body"] ? (typeof value["body"]["body"]["bankMsb"] === "number" && Number.isInteger(value["body"]["body"]["bankMsb"]) && value["body"]["body"]["bankMsb"] >= 0 && value["body"]["body"]["bankMsb"] <= 127) : true) && ("bankLsb" in value["body"]["body"] ? (typeof value["body"]["body"]["bankLsb"] === "number" && Number.isInteger(value["body"]["body"]["bankLsb"]) && value["body"]["body"]["bankLsb"] >= 0 && value["body"]["body"]["bankLsb"] <= 127) : true) && ("bankValid" in value["body"]["body"] ? typeof value["body"]["body"]["bankValid"] === "boolean" : true) && hasOnlyKeys(value["body"]["body"], ["program","bankMsb","bankLsb","bankValid"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 13 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("channelPressure32" in value["body"]["body"] && (typeof value["body"]["body"]["channelPressure32"] === "number" && Number.isInteger(value["body"]["body"]["channelPressure32"]) && value["body"]["body"]["channelPressure32"] >= 0 && value["body"]["body"]["channelPressure32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["channelPressure32"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 14 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("pitchBend32" in value["body"]["body"] && (typeof value["body"]["body"]["pitchBend32"] === "number" && Number.isInteger(value["body"]["body"]["pitchBend32"]) && value["body"]["body"]["pitchBend32"] >= 0 && value["body"]["body"]["pitchBend32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["pitchBend32"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 15 : true) && ("body" in value["body"] ? ((isPlainObject(value["body"]["body"]) && ("rpnIndexMsb" in value["body"]["body"] && (typeof value["body"]["body"]["rpnIndexMsb"] === "number" && Number.isInteger(value["body"]["body"]["rpnIndexMsb"]) && value["body"]["body"]["rpnIndexMsb"] >= 0 && value["body"]["body"]["rpnIndexMsb"] <= 127)) && ("rpnIndexLsb" in value["body"]["body"] && (typeof value["body"]["body"]["rpnIndexLsb"] === "number" && Number.isInteger(value["body"]["body"]["rpnIndexLsb"]) && value["body"]["body"]["rpnIndexLsb"] >= 0 && value["body"]["body"]["rpnIndexLsb"] <= 127)) && ("rpnData32" in value["body"]["body"] && (typeof value["body"]["body"]["rpnData32"] === "number" && Number.isInteger(value["body"]["body"]["rpnData32"]) && value["body"]["body"]["rpnData32"] >= 0 && value["body"]["body"]["rpnData32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["rpnIndexMsb","rpnIndexLsb","rpnData32"])) || (isPlainObject(value["body"]["body"]) && ("nrpnIndexMsb" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnIndexMsb"] === "number" && Number.isInteger(value["body"]["body"]["nrpnIndexMsb"]) && value["body"]["body"]["nrpnIndexMsb"] >= 0 && value["body"]["body"]["nrpnIndexMsb"] <= 127)) && ("nrpnIndexLsb" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnIndexLsb"] === "number" && Number.isInteger(value["body"]["body"]["nrpnIndexLsb"]) && value["body"]["body"]["nrpnIndexLsb"] >= 0 && value["body"]["body"]["nrpnIndexLsb"] <= 127)) && ("nrpnData32" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnData32"] === "number" && Number.isInteger(value["body"]["body"]["nrpnData32"]) && value["body"]["body"]["nrpnData32"] >= 0 && value["body"]["body"]["nrpnData32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["nrpnIndexMsb","nrpnIndexLsb","nrpnData32"])) || (isPlainObject(value["body"]["body"]) && ("rpnIndexMsb" in value["body"]["body"] && (typeof value["body"]["body"]["rpnIndexMsb"] === "number" && Number.isInteger(value["body"]["body"]["rpnIndexMsb"]) && value["body"]["body"]["rpnIndexMsb"] >= 0 && value["body"]["body"]["rpnIndexMsb"] <= 127)) && ("rpnIndexLsb" in value["body"]["body"] && (typeof value["body"]["body"]["rpnIndexLsb"] === "number" && Number.isInteger(value["body"]["body"]["rpnIndexLsb"]) && value["body"]["body"]["rpnIndexLsb"] >= 0 && value["body"]["body"]["rpnIndexLsb"] <= 127)) && ("rpnDelta32" in value["body"]["body"] && (typeof value["body"]["body"]["rpnDelta32"] === "number" && Number.isInteger(value["body"]["body"]["rpnDelta32"]) && value["body"]["body"]["rpnDelta32"] >= -2147483648 && value["body"]["body"]["rpnDelta32"] <= 2147483647)) && hasOnlyKeys(value["body"]["body"], ["rpnIndexMsb","rpnIndexLsb","rpnDelta32"])) || (isPlainObject(value["body"]["body"]) && ("nrpnIndexMsb" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnIndexMsb"] === "number" && Number.isInteger(value["body"]["body"]["nrpnIndexMsb"]) && value["body"]["body"]["nrpnIndexMsb"] >= 0 && value["body"]["body"]["nrpnIndexMsb"] <= 127)) && ("nrpnIndexLsb" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnIndexLsb"] === "number" && Number.isInteger(value["body"]["body"]["nrpnIndexLsb"]) && value["body"]["body"]["nrpnIndexLsb"] >= 0 && value["body"]["body"]["nrpnIndexLsb"] <= 127)) && ("nrpnDelta32" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnDelta32"] === "number" && Number.isInteger(value["body"]["body"]["nrpnDelta32"]) && value["body"]["body"]["nrpnDelta32"] >= -2147483648 && value["body"]["body"]["nrpnDelta32"] <= 2147483647)) && hasOnlyKeys(value["body"]["body"], ["nrpnIndexMsb","nrpnIndexLsb","nrpnDelta32"])) || (isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("detach" in value["body"]["body"] && typeof value["body"]["body"]["detach"] === "boolean") && ("reset" in value["body"]["body"] && typeof value["body"]["body"]["reset"] === "boolean") && hasOnlyKeys(value["body"]["body"], ["noteNumber","detach","reset"])) || (isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("regPerNoteCtrlIndex" in value["body"]["body"] && (typeof value["body"]["body"]["regPerNoteCtrlIndex"] === "number" && Number.isInteger(value["body"]["body"]["regPerNoteCtrlIndex"]) && value["body"]["body"]["regPerNoteCtrlIndex"] >= 0 && value["body"]["body"]["regPerNoteCtrlIndex"] <= 255)) && ("regPerNoteCtrlValue32" in value["body"]["body"] && (typeof value["body"]["body"]["regPerNoteCtrlValue32"] === "number" && Number.isInteger(value["body"]["body"]["regPerNoteCtrlValue32"]) && value["body"]["body"]["regPerNoteCtrlValue32"] >= 0 && value["body"]["body"]["regPerNoteCtrlValue32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["noteNumber","regPerNoteCtrlIndex","regPerNoteCtrlValue32"])) || (isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("assignPerNoteCtrlIndex" in value["body"]["body"] && (typeof value["body"]["body"]["assignPerNoteCtrlIndex"] === "number" && Number.isInteger(value["body"]["body"]["assignPerNoteCtrlIndex"]) && value["body"]["body"]["assignPerNoteCtrlIndex"] >= 0 && value["body"]["body"]["assignPerNoteCtrlIndex"] <= 255)) && ("assignPerNoteCtrlValue32" in value["body"]["body"] && (typeof value["body"]["body"]["assignPerNoteCtrlValue32"] === "number" && Number.isInteger(value["body"]["body"]["assignPerNoteCtrlValue32"]) && value["body"]["body"]["assignPerNoteCtrlValue32"] >= 0 && value["body"]["body"]["assignPerNoteCtrlValue32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["noteNumber","assignPerNoteCtrlIndex","assignPerNoteCtrlValue32"]))) : true)))) && hasOnlyKeys(value, ["messageType","group","statusNibble","channel","body"])) || (isPlainObject(value) && ("messageType" in value && (value["messageType"] === 5 || value["messageType"] === 13)) && ("group" in value ? isUint4(value["group"]) : true) && ("body" in value && ((isPlainObject(value["body"]) && ("kind" in value["body"] && (value["body"]["kind"] === "sysex8" || value["body"]["kind"] === "mds")) && ("sysex8" in value["body"] ? isPlainObject(value["body"]["sysex8"]) && ("manufacturerId" in value["body"]["sysex8"] && (((Array.isArray(value["body"]["sysex8"]["manufacturerId"]) && value["body"]["sysex8"]["manufacturerId"].length >= 1 && value["body"]["sysex8"]["manufacturerId"].length <= 1 && value["body"]["sysex8"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) || ((Array.isArray(value["body"]["sysex8"]["manufacturerId"]) && value["body"]["sysex8"]["manufacturerId"].length >= 3 && value["body"]["sysex8"]["manufacturerId"].length <= 3 && value["body"]["sysex8"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))))) && ("length" in value["body"]["sysex8"] && (typeof value["body"]["sysex8"]["length"] === "number" && Number.isInteger(value["body"]["sysex8"]["length"]) && value["body"]["sysex8"]["length"] >= 0 && value["body"]["sysex8"]["length"] <= 268435455)) && ("data" in value["body"]["sysex8"] && (Array.isArray(value["body"]["sysex8"]["data"]) && true && true && value["body"]["sysex8"]["data"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) && hasOnlyKeys(value["body"]["sysex8"], ["manufacturerId","length","data"]) : true) && ("mds" in value["body"] ? isPlainObject(value["body"]["mds"]) && ("messageId" in value["body"]["mds"] && (typeof value["body"]["mds"]["messageId"] === "number" && Number.isInteger(value["body"]["mds"]["messageId"]) && value["body"]["mds"]["messageId"] >= 0 && value["body"]["mds"]["messageId"] <= 65535)) && ("totalChunks" in value["body"]["mds"] && (typeof value["body"]["mds"]["totalChunks"] === "number" && Number.isInteger(value["body"]["mds"]["totalChunks"]) && value["body"]["mds"]["totalChunks"] >= 0 && value["body"]["mds"]["totalChunks"] <= 65535)) && ("chunks" in value["body"]["mds"] && (Array.isArray(value["body"]["mds"]["chunks"]) && true && true && value["body"]["mds"]["chunks"].every(item => isPlainObject(item) && ("index" in item && (typeof item["index"] === "number" && Number.isInteger(item["index"]) && item["index"] >= 0 && item["index"] <= 65535)) && ("validByteCount" in item && (typeof item["validByteCount"] === "number" && Number.isInteger(item["validByteCount"]) && item["validByteCount"] >= 0 && item["validByteCount"] <= 255)) && ("payload" in item && (Array.isArray(item["payload"]) && true && item["payload"].length <= 14 && item["payload"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) && hasOnlyKeys(item, ["index","validByteCount","payload"])))) && hasOnlyKeys(value["body"]["mds"], ["messageId","totalChunks","chunks"]) : true) && hasOnlyKeys(value["body"], ["kind","sysex8","mds"])) || (((isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 16) && ("status" in value["body"] && value["body"]["status"] === 1) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("bpm" in value["body"]["data"] && (typeof value["body"]["data"]["bpm"] === "number" && Number.isFinite(value["body"]["data"]["bpm"]) && value["body"]["data"]["bpm"] >= 1 && true)) && hasOnlyKeys(value["body"]["data"], ["bpm"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 16) && ("status" in value["body"] && value["body"]["status"] === 2) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("numerator" in value["body"]["data"] && (typeof value["body"]["data"]["numerator"] === "number" && Number.isInteger(value["body"]["data"]["numerator"]) && value["body"]["data"]["numerator"] >= 1 && true)) && ("denominatorPow2" in value["body"]["data"] && (typeof value["body"]["data"]["denominatorPow2"] === "number" && Number.isInteger(value["body"]["data"]["denominatorPow2"]) && value["body"]["data"]["denominatorPow2"] >= 0 && true)) && hasOnlyKeys(value["body"]["data"], ["numerator","denominatorPow2"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 16) && ("status" in value["body"] && value["body"]["status"] === 3) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("clicksPerBeat" in value["body"]["data"] ? (typeof value["body"]["data"]["clicksPerBeat"] === "number" && Number.isInteger(value["body"]["data"]["clicksPerBeat"]) && value["body"]["data"]["clicksPerBeat"] >= 1 && true) : true) && ("accentPattern" in value["body"]["data"] ? typeof value["body"]["data"]["accentPattern"] === "string" : true) && hasOnlyKeys(value["body"]["data"], ["clicksPerBeat","accentPattern"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 16) && ("status" in value["body"] && value["body"]["status"] === 4) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("key" in value["body"]["data"] && typeof value["body"]["data"]["key"] === "string") && hasOnlyKeys(value["body"]["data"], ["key"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 16) && ("status" in value["body"] && value["body"]["status"] === 5) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("chord" in value["body"]["data"] && typeof value["body"]["data"]["chord"] === "string") && hasOnlyKeys(value["body"]["data"], ["chord"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 17) && ("status" in value["body"] && value["body"]["status"] === 1) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("text" in value["body"]["data"] && typeof value["body"]["data"]["text"] === "string") && hasOnlyKeys(value["body"]["data"], ["text"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 17) && ("status" in value["body"] && value["body"]["status"] === 2) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("lyric" in value["body"]["data"] && typeof value["body"]["data"]["lyric"] === "string") && hasOnlyKeys(value["body"]["data"], ["lyric"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 17) && ("status" in value["body"] && value["body"]["status"] === 3) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("ruby" in value["body"]["data"] && typeof value["body"]["data"]["ruby"] === "string") && hasOnlyKeys(value["body"]["data"], ["ruby"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])))))) && hasOnlyKeys(value, ["messageType","group","body"])));
}

export function isUmpPacket128(value: unknown): value is UmpPacket128 {
  return isPlainObject(value) && ("messageType" in value && (value["messageType"] === 5 || value["messageType"] === 13)) && ("group" in value ? isUint4(value["group"]) : true) && ("body" in value && ((isPlainObject(value["body"]) && ("kind" in value["body"] && (value["body"]["kind"] === "sysex8" || value["body"]["kind"] === "mds")) && ("sysex8" in value["body"] ? isPlainObject(value["body"]["sysex8"]) && ("manufacturerId" in value["body"]["sysex8"] && (((Array.isArray(value["body"]["sysex8"]["manufacturerId"]) && value["body"]["sysex8"]["manufacturerId"].length >= 1 && value["body"]["sysex8"]["manufacturerId"].length <= 1 && value["body"]["sysex8"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) || ((Array.isArray(value["body"]["sysex8"]["manufacturerId"]) && value["body"]["sysex8"]["manufacturerId"].length >= 3 && value["body"]["sysex8"]["manufacturerId"].length <= 3 && value["body"]["sysex8"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))))) && ("length" in value["body"]["sysex8"] && (typeof value["body"]["sysex8"]["length"] === "number" && Number.isInteger(value["body"]["sysex8"]["length"]) && value["body"]["sysex8"]["length"] >= 0 && value["body"]["sysex8"]["length"] <= 268435455)) && ("data" in value["body"]["sysex8"] && (Array.isArray(value["body"]["sysex8"]["data"]) && true && true && value["body"]["sysex8"]["data"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) && hasOnlyKeys(value["body"]["sysex8"], ["manufacturerId","length","data"]) : true) && ("mds" in value["body"] ? isPlainObject(value["body"]["mds"]) && ("messageId" in value["body"]["mds"] && (typeof value["body"]["mds"]["messageId"] === "number" && Number.isInteger(value["body"]["mds"]["messageId"]) && value["body"]["mds"]["messageId"] >= 0 && value["body"]["mds"]["messageId"] <= 65535)) && ("totalChunks" in value["body"]["mds"] && (typeof value["body"]["mds"]["totalChunks"] === "number" && Number.isInteger(value["body"]["mds"]["totalChunks"]) && value["body"]["mds"]["totalChunks"] >= 0 && value["body"]["mds"]["totalChunks"] <= 65535)) && ("chunks" in value["body"]["mds"] && (Array.isArray(value["body"]["mds"]["chunks"]) && true && true && value["body"]["mds"]["chunks"].every(item => isPlainObject(item) && ("index" in item && (typeof item["index"] === "number" && Number.isInteger(item["index"]) && item["index"] >= 0 && item["index"] <= 65535)) && ("validByteCount" in item && (typeof item["validByteCount"] === "number" && Number.isInteger(item["validByteCount"]) && item["validByteCount"] >= 0 && item["validByteCount"] <= 255)) && ("payload" in item && (Array.isArray(item["payload"]) && true && item["payload"].length <= 14 && item["payload"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) && hasOnlyKeys(item, ["index","validByteCount","payload"])))) && hasOnlyKeys(value["body"]["mds"], ["messageId","totalChunks","chunks"]) : true) && hasOnlyKeys(value["body"], ["kind","sysex8","mds"])) || (((isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 16) && ("status" in value["body"] && value["body"]["status"] === 1) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("bpm" in value["body"]["data"] && (typeof value["body"]["data"]["bpm"] === "number" && Number.isFinite(value["body"]["data"]["bpm"]) && value["body"]["data"]["bpm"] >= 1 && true)) && hasOnlyKeys(value["body"]["data"], ["bpm"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 16) && ("status" in value["body"] && value["body"]["status"] === 2) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("numerator" in value["body"]["data"] && (typeof value["body"]["data"]["numerator"] === "number" && Number.isInteger(value["body"]["data"]["numerator"]) && value["body"]["data"]["numerator"] >= 1 && true)) && ("denominatorPow2" in value["body"]["data"] && (typeof value["body"]["data"]["denominatorPow2"] === "number" && Number.isInteger(value["body"]["data"]["denominatorPow2"]) && value["body"]["data"]["denominatorPow2"] >= 0 && true)) && hasOnlyKeys(value["body"]["data"], ["numerator","denominatorPow2"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 16) && ("status" in value["body"] && value["body"]["status"] === 3) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("clicksPerBeat" in value["body"]["data"] ? (typeof value["body"]["data"]["clicksPerBeat"] === "number" && Number.isInteger(value["body"]["data"]["clicksPerBeat"]) && value["body"]["data"]["clicksPerBeat"] >= 1 && true) : true) && ("accentPattern" in value["body"]["data"] ? typeof value["body"]["data"]["accentPattern"] === "string" : true) && hasOnlyKeys(value["body"]["data"], ["clicksPerBeat","accentPattern"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 16) && ("status" in value["body"] && value["body"]["status"] === 4) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("key" in value["body"]["data"] && typeof value["body"]["data"]["key"] === "string") && hasOnlyKeys(value["body"]["data"], ["key"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 16) && ("status" in value["body"] && value["body"]["status"] === 5) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("chord" in value["body"]["data"] && typeof value["body"]["data"]["chord"] === "string") && hasOnlyKeys(value["body"]["data"], ["chord"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 17) && ("status" in value["body"] && value["body"]["status"] === 1) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("text" in value["body"]["data"] && typeof value["body"]["data"]["text"] === "string") && hasOnlyKeys(value["body"]["data"], ["text"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 17) && ("status" in value["body"] && value["body"]["status"] === 2) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("lyric" in value["body"]["data"] && typeof value["body"]["data"]["lyric"] === "string") && hasOnlyKeys(value["body"]["data"], ["lyric"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])) || (isPlainObject(value["body"]) && ("statusClass" in value["body"] && value["body"]["statusClass"] === 17) && ("status" in value["body"] && value["body"]["status"] === 3) && ("address" in value["body"] ? isPlainObject(value["body"]["address"]) && ("scope" in value["body"]["address"] ? (value["body"]["address"]["scope"] === "group" || value["body"]["address"]["scope"] === "channel") : true) && ("group" in value["body"]["address"] ? (typeof value["body"]["address"]["group"] === "number" && Number.isInteger(value["body"]["address"]["group"]) && value["body"]["address"]["group"] >= 0 && value["body"]["address"]["group"] <= 15) : true) && ("channel" in value["body"]["address"] ? (typeof value["body"]["address"]["channel"] === "number" && Number.isInteger(value["body"]["address"]["channel"]) && value["body"]["address"]["channel"] >= 0 && value["body"]["address"]["channel"] <= 15) : true) && hasOnlyKeys(value["body"]["address"], ["scope","group","channel"]) : true) && ("data" in value["body"] && isPlainObject(value["body"]["data"]) && ("ruby" in value["body"]["data"] && typeof value["body"]["data"]["ruby"] === "string") && hasOnlyKeys(value["body"]["data"], ["ruby"])) && hasOnlyKeys(value["body"], ["statusClass","status","address","data"])))))) && hasOnlyKeys(value, ["messageType","group","body"]);
}

export function isUmpPacket32(value: unknown): value is UmpPacket32 {
  return isPlainObject(value) && ("messageType" in value && (value["messageType"] === 0 || value["messageType"] === 1 || value["messageType"] === 2 || value["messageType"] === 3 || value["messageType"] === 15)) && ("group" in value ? isUint4(value["group"]) : true) && ("body" in value && ((isPlainObject(value["body"]) && ("opcode" in value["body"] && (value["body"]["opcode"] === 0 || value["body"]["opcode"] === 1 || value["body"]["opcode"] === 2)) && ("jrClock" in value["body"] ? isPlainObject(value["body"]["jrClock"]) && ("timestamp32" in value["body"]["jrClock"] && (typeof value["body"]["jrClock"]["timestamp32"] === "number" && Number.isInteger(value["body"]["jrClock"]["timestamp32"]) && value["body"]["jrClock"]["timestamp32"] >= 0 && value["body"]["jrClock"]["timestamp32"] <= 4294967295)) && hasOnlyKeys(value["body"]["jrClock"], ["timestamp32"]) : true) && ("jrTimestamp" in value["body"] ? isPlainObject(value["body"]["jrTimestamp"]) && ("time15" in value["body"]["jrTimestamp"] && (typeof value["body"]["jrTimestamp"]["time15"] === "number" && Number.isInteger(value["body"]["jrTimestamp"]["time15"]) && value["body"]["jrTimestamp"]["time15"] >= 0 && value["body"]["jrTimestamp"]["time15"] <= 32767)) && hasOnlyKeys(value["body"]["jrTimestamp"], ["time15"]) : true) && hasOnlyKeys(value["body"], ["opcode","jrClock","jrTimestamp"])) || (isPlainObject(value["body"]) && ("status" in value["body"] && (value["body"]["status"] === 241 || value["body"]["status"] === 242 || value["body"]["status"] === 243 || value["body"]["status"] === 246 || value["body"]["status"] === 248 || value["body"]["status"] === 250 || value["body"]["status"] === 251 || value["body"]["status"] === 252 || value["body"]["status"] === 254 || value["body"]["status"] === 255)) && ("data1" in value["body"] ? (typeof value["body"]["data1"] === "number" && Number.isInteger(value["body"]["data1"]) && value["body"]["data1"] >= 0 && value["body"]["data1"] <= 255) : true) && ("data2" in value["body"] ? (typeof value["body"]["data2"] === "number" && Number.isInteger(value["body"]["data2"]) && value["body"]["data2"] >= 0 && value["body"]["data2"] <= 255) : true) && hasOnlyKeys(value["body"], ["status","data1","data2"])) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] && (value["body"]["statusNibble"] === 8 || value["body"]["statusNibble"] === 9 || value["body"]["statusNibble"] === 10 || value["body"]["statusNibble"] === 11 || value["body"]["statusNibble"] === 12 || value["body"]["statusNibble"] === 13 || value["body"]["statusNibble"] === 14)) && ("channel" in value["body"] && (typeof value["body"]["channel"] === "number" && Number.isInteger(value["body"]["channel"]) && value["body"]["channel"] >= 0 && value["body"]["channel"] <= 15)) && ("noteNumber" in value["body"] ? (typeof value["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["noteNumber"]) && value["body"]["noteNumber"] >= 0 && value["body"]["noteNumber"] <= 127) : true) && ("velocity7" in value["body"] ? (typeof value["body"]["velocity7"] === "number" && Number.isInteger(value["body"]["velocity7"]) && value["body"]["velocity7"] >= 0 && value["body"]["velocity7"] <= 127) : true) && ("pressure7" in value["body"] ? (typeof value["body"]["pressure7"] === "number" && Number.isInteger(value["body"]["pressure7"]) && value["body"]["pressure7"] >= 0 && value["body"]["pressure7"] <= 127) : true) && ("control" in value["body"] ? (typeof value["body"]["control"] === "number" && Number.isInteger(value["body"]["control"]) && value["body"]["control"] >= 0 && value["body"]["control"] <= 127) : true) && ("value7" in value["body"] ? (typeof value["body"]["value7"] === "number" && Number.isInteger(value["body"]["value7"]) && value["body"]["value7"] >= 0 && value["body"]["value7"] <= 127) : true) && ("program" in value["body"] ? (typeof value["body"]["program"] === "number" && Number.isInteger(value["body"]["program"]) && value["body"]["program"] >= 0 && value["body"]["program"] <= 127) : true) && ("pitchBend14" in value["body"] ? (typeof value["body"]["pitchBend14"] === "number" && Number.isInteger(value["body"]["pitchBend14"]) && value["body"]["pitchBend14"] >= 0 && value["body"]["pitchBend14"] <= 16383) : true) && hasOnlyKeys(value["body"], ["statusNibble","channel","noteNumber","velocity7","pressure7","control","value7","program","pitchBend14"])) || (isPlainObject(value["body"]) && ("manufacturerId" in value["body"] && (((Array.isArray(value["body"]["manufacturerId"]) && value["body"]["manufacturerId"].length >= 1 && value["body"]["manufacturerId"].length <= 1 && value["body"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) || ((Array.isArray(value["body"]["manufacturerId"]) && value["body"]["manufacturerId"].length >= 3 && value["body"]["manufacturerId"].length <= 3 && value["body"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))))) && ("packets" in value["body"] && (Array.isArray(value["body"]["packets"]) && value["body"]["packets"].length >= 1 && true && value["body"]["packets"].every(item => isPlainObject(item) && ("streamStatus" in item && (item["streamStatus"] === "single" || item["streamStatus"] === "start" || item["streamStatus"] === "continue" || item["streamStatus"] === "end")) && ("payload" in item && (Array.isArray(item["payload"]) && item["payload"].length >= 0 && item["payload"].length <= 6 && item["payload"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) && hasOnlyKeys(item, ["streamStatus","payload"])))) && hasOnlyKeys(value["body"], ["manufacturerId","packets"])) || (isPlainObject(value["body"]) && ("opcode" in value["body"] && (value["body"]["opcode"] === 0 || value["body"]["opcode"] === 1 || value["body"]["opcode"] === 2 || value["body"]["opcode"] === 3 || value["body"]["opcode"] === 4 || value["body"]["opcode"] === 5 || value["body"]["opcode"] === 6 || value["body"]["opcode"] === 16 || value["body"]["opcode"] === 17 || value["body"]["opcode"] === 18 || value["body"]["opcode"] === 32 || value["body"]["opcode"] === 33)) && ("endpointDiscovery" in value["body"] ? isPlainObject(value["body"]["endpointDiscovery"]) && ("majorVersion" in value["body"]["endpointDiscovery"] ? (typeof value["body"]["endpointDiscovery"]["majorVersion"] === "number" && Number.isInteger(value["body"]["endpointDiscovery"]["majorVersion"]) && value["body"]["endpointDiscovery"]["majorVersion"] >= 0 && value["body"]["endpointDiscovery"]["majorVersion"] <= 255) : true) && ("minorVersion" in value["body"]["endpointDiscovery"] ? (typeof value["body"]["endpointDiscovery"]["minorVersion"] === "number" && Number.isInteger(value["body"]["endpointDiscovery"]["minorVersion"]) && value["body"]["endpointDiscovery"]["minorVersion"] >= 0 && value["body"]["endpointDiscovery"]["minorVersion"] <= 255) : true) && ("maxGroups" in value["body"]["endpointDiscovery"] ? (typeof value["body"]["endpointDiscovery"]["maxGroups"] === "number" && Number.isInteger(value["body"]["endpointDiscovery"]["maxGroups"]) && value["body"]["endpointDiscovery"]["maxGroups"] >= 0 && value["body"]["endpointDiscovery"]["maxGroups"] <= 15) : true) && ("filter" in value["body"]["endpointDiscovery"] ? isPlainObject(value["body"]["endpointDiscovery"]["filter"]) && ("endpointInfo" in value["body"]["endpointDiscovery"]["filter"] ? typeof value["body"]["endpointDiscovery"]["filter"]["endpointInfo"] === "boolean" : true) && ("deviceIdentity" in value["body"]["endpointDiscovery"]["filter"] ? typeof value["body"]["endpointDiscovery"]["filter"]["deviceIdentity"] === "boolean" : true) && ("endpointName" in value["body"]["endpointDiscovery"]["filter"] ? typeof value["body"]["endpointDiscovery"]["filter"]["endpointName"] === "boolean" : true) && ("productInstanceId" in value["body"]["endpointDiscovery"]["filter"] ? typeof value["body"]["endpointDiscovery"]["filter"]["productInstanceId"] === "boolean" : true) && ("streamConfig" in value["body"]["endpointDiscovery"]["filter"] ? typeof value["body"]["endpointDiscovery"]["filter"]["streamConfig"] === "boolean" : true) && hasOnlyKeys(value["body"]["endpointDiscovery"]["filter"], ["endpointInfo","deviceIdentity","endpointName","productInstanceId","streamConfig"]) : true) && hasOnlyKeys(value["body"]["endpointDiscovery"], ["majorVersion","minorVersion","maxGroups","filter"]) : true) && ("endpointInfoNotification" in value["body"] ? isPlainObject(value["body"]["endpointInfoNotification"]) && ("staticFunctionBlocks" in value["body"]["endpointInfoNotification"] ? typeof value["body"]["endpointInfoNotification"]["staticFunctionBlocks"] === "boolean" : true) && ("numberOfFunctionBlocks" in value["body"]["endpointInfoNotification"] ? (typeof value["body"]["endpointInfoNotification"]["numberOfFunctionBlocks"] === "number" && Number.isInteger(value["body"]["endpointInfoNotification"]["numberOfFunctionBlocks"]) && value["body"]["endpointInfoNotification"]["numberOfFunctionBlocks"] >= 0 && value["body"]["endpointInfoNotification"]["numberOfFunctionBlocks"] <= 32) : true) && ("umpVersionMajor" in value["body"]["endpointInfoNotification"] ? (typeof value["body"]["endpointInfoNotification"]["umpVersionMajor"] === "number" && Number.isInteger(value["body"]["endpointInfoNotification"]["umpVersionMajor"]) && value["body"]["endpointInfoNotification"]["umpVersionMajor"] >= 0 && value["body"]["endpointInfoNotification"]["umpVersionMajor"] <= 255) : true) && ("umpVersionMinor" in value["body"]["endpointInfoNotification"] ? (typeof value["body"]["endpointInfoNotification"]["umpVersionMinor"] === "number" && Number.isInteger(value["body"]["endpointInfoNotification"]["umpVersionMinor"]) && value["body"]["endpointInfoNotification"]["umpVersionMinor"] >= 0 && value["body"]["endpointInfoNotification"]["umpVersionMinor"] <= 255) : true) && ("midi2Supported" in value["body"]["endpointInfoNotification"] ? typeof value["body"]["endpointInfoNotification"]["midi2Supported"] === "boolean" : true) && ("midi1Supported" in value["body"]["endpointInfoNotification"] ? typeof value["body"]["endpointInfoNotification"]["midi1Supported"] === "boolean" : true) && ("jrTimestampsRx" in value["body"]["endpointInfoNotification"] ? typeof value["body"]["endpointInfoNotification"]["jrTimestampsRx"] === "boolean" : true) && ("jrTimestampsTx" in value["body"]["endpointInfoNotification"] ? typeof value["body"]["endpointInfoNotification"]["jrTimestampsTx"] === "boolean" : true) && hasOnlyKeys(value["body"]["endpointInfoNotification"], ["staticFunctionBlocks","numberOfFunctionBlocks","umpVersionMajor","umpVersionMinor","midi2Supported","midi1Supported","jrTimestampsRx","jrTimestampsTx"]) : true) && ("deviceIdentityNotification" in value["body"] ? isPlainObject(value["body"]["deviceIdentityNotification"]) && ("manufacturerId" in value["body"]["deviceIdentityNotification"] ? (((Array.isArray(value["body"]["deviceIdentityNotification"]["manufacturerId"]) && value["body"]["deviceIdentityNotification"]["manufacturerId"].length >= 1 && value["body"]["deviceIdentityNotification"]["manufacturerId"].length <= 1 && value["body"]["deviceIdentityNotification"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255)))) || ((Array.isArray(value["body"]["deviceIdentityNotification"]["manufacturerId"]) && value["body"]["deviceIdentityNotification"]["manufacturerId"].length >= 3 && value["body"]["deviceIdentityNotification"]["manufacturerId"].length <= 3 && value["body"]["deviceIdentityNotification"]["manufacturerId"].every(item => (typeof item === "number" && Number.isInteger(item) && item >= 0 && item <= 255))))) : true) && ("deviceFamily" in value["body"]["deviceIdentityNotification"] ? (typeof value["body"]["deviceIdentityNotification"]["deviceFamily"] === "number" && Number.isInteger(value["body"]["deviceIdentityNotification"]["deviceFamily"]) && value["body"]["deviceIdentityNotification"]["deviceFamily"] >= 0 && value["body"]["deviceIdentityNotification"]["deviceFamily"] <= 65535) : true) && ("deviceModel" in value["body"]["deviceIdentityNotification"] ? (typeof value["body"]["deviceIdentityNotification"]["deviceModel"] === "number" && Number.isInteger(value["body"]["deviceIdentityNotification"]["deviceModel"]) && value["body"]["deviceIdentityNotification"]["deviceModel"] >= 0 && value["body"]["deviceIdentityNotification"]["deviceModel"] <= 65535) : true) && ("softwareRevision" in value["body"]["deviceIdentityNotification"] ? (typeof value["body"]["deviceIdentityNotification"]["softwareRevision"] === "number" && Number.isInteger(value["body"]["deviceIdentityNotification"]["softwareRevision"]) && value["body"]["deviceIdentityNotification"]["softwareRevision"] >= 0 && value["body"]["deviceIdentityNotification"]["softwareRevision"] <= 4294967295) : true) && hasOnlyKeys(value["body"]["deviceIdentityNotification"], ["manufacturerId","deviceFamily","deviceModel","softwareRevision"]) : true) && ("endpointNameNotification" in value["body"] ? isPlainObject(value["body"]["endpointNameNotification"]) && ("name" in value["body"]["endpointNameNotification"] && typeof value["body"]["endpointNameNotification"]["name"] === "string") && hasOnlyKeys(value["body"]["endpointNameNotification"], ["name"]) : true) && ("productInstanceIdNotification" in value["body"] ? isPlainObject(value["body"]["productInstanceIdNotification"]) && ("productInstanceId" in value["body"]["productInstanceIdNotification"] && typeof value["body"]["productInstanceIdNotification"]["productInstanceId"] === "string") && hasOnlyKeys(value["body"]["productInstanceIdNotification"], ["productInstanceId"]) : true) && ("streamConfigRequest" in value["body"] ? isPlainObject(value["body"]["streamConfigRequest"]) && ("protocol" in value["body"]["streamConfigRequest"] ? (value["body"]["streamConfigRequest"]["protocol"] === "midi1" || value["body"]["streamConfigRequest"]["protocol"] === "midi2") : true) && ("jrTimestampsTx" in value["body"]["streamConfigRequest"] ? typeof value["body"]["streamConfigRequest"]["jrTimestampsTx"] === "boolean" : true) && ("jrTimestampsRx" in value["body"]["streamConfigRequest"] ? typeof value["body"]["streamConfigRequest"]["jrTimestampsRx"] === "boolean" : true) && hasOnlyKeys(value["body"]["streamConfigRequest"], ["protocol","jrTimestampsTx","jrTimestampsRx"]) : true) && ("streamConfigNotification" in value["body"] ? isPlainObject(value["body"]["streamConfigNotification"]) && ("protocol" in value["body"]["streamConfigNotification"] ? (value["body"]["streamConfigNotification"]["protocol"] === "midi1" || value["body"]["streamConfigNotification"]["protocol"] === "midi2") : true) && ("jrTimestampsTx" in value["body"]["streamConfigNotification"] ? typeof value["body"]["streamConfigNotification"]["jrTimestampsTx"] === "boolean" : true) && ("jrTimestampsRx" in value["body"]["streamConfigNotification"] ? typeof value["body"]["streamConfigNotification"]["jrTimestampsRx"] === "boolean" : true) && hasOnlyKeys(value["body"]["streamConfigNotification"], ["protocol","jrTimestampsTx","jrTimestampsRx"]) : true) && ("functionBlockDiscovery" in value["body"] ? isPlainObject(value["body"]["functionBlockDiscovery"]) && ("filterBitmap" in value["body"]["functionBlockDiscovery"] ? (typeof value["body"]["functionBlockDiscovery"]["filterBitmap"] === "number" && Number.isInteger(value["body"]["functionBlockDiscovery"]["filterBitmap"]) && value["body"]["functionBlockDiscovery"]["filterBitmap"] >= 0 && value["body"]["functionBlockDiscovery"]["filterBitmap"] <= 4294967295) : true) && hasOnlyKeys(value["body"]["functionBlockDiscovery"], ["filterBitmap"]) : true) && ("functionBlockInfo" in value["body"] ? isPlainObject(value["body"]["functionBlockInfo"]) && ("index" in value["body"]["functionBlockInfo"] ? (typeof value["body"]["functionBlockInfo"]["index"] === "number" && Number.isInteger(value["body"]["functionBlockInfo"]["index"]) && value["body"]["functionBlockInfo"]["index"] >= 0 && value["body"]["functionBlockInfo"]["index"] <= 255) : true) && ("firstGroup" in value["body"]["functionBlockInfo"] ? (typeof value["body"]["functionBlockInfo"]["firstGroup"] === "number" && Number.isInteger(value["body"]["functionBlockInfo"]["firstGroup"]) && value["body"]["functionBlockInfo"]["firstGroup"] >= 0 && value["body"]["functionBlockInfo"]["firstGroup"] <= 15) : true) && ("groupCount" in value["body"]["functionBlockInfo"] ? (typeof value["body"]["functionBlockInfo"]["groupCount"] === "number" && Number.isInteger(value["body"]["functionBlockInfo"]["groupCount"]) && value["body"]["functionBlockInfo"]["groupCount"] >= 0 && value["body"]["functionBlockInfo"]["groupCount"] <= 15) : true) && ("active" in value["body"]["functionBlockInfo"] ? typeof value["body"]["functionBlockInfo"]["active"] === "boolean" : true) && ("direction" in value["body"]["functionBlockInfo"] ? (value["body"]["functionBlockInfo"]["direction"] === 0 || value["body"]["functionBlockInfo"]["direction"] === 1 || value["body"]["functionBlockInfo"]["direction"] === 2 || value["body"]["functionBlockInfo"]["direction"] === 3) : true) && ("midi1Bandwidth" in value["body"]["functionBlockInfo"] ? (value["body"]["functionBlockInfo"]["midi1Bandwidth"] === 0 || value["body"]["functionBlockInfo"]["midi1Bandwidth"] === 1 || value["body"]["functionBlockInfo"]["midi1Bandwidth"] === 2) : true) && hasOnlyKeys(value["body"]["functionBlockInfo"], ["index","firstGroup","groupCount","active","direction","midi1Bandwidth"]) : true) && ("processInquiry" in value["body"] ? isPlainObject(value["body"]["processInquiry"]) && ("functionBlock" in value["body"]["processInquiry"] ? (typeof value["body"]["processInquiry"]["functionBlock"] === "number" && Number.isInteger(value["body"]["processInquiry"]["functionBlock"]) && value["body"]["processInquiry"]["functionBlock"] >= 0 && value["body"]["processInquiry"]["functionBlock"] <= 127) : true) && ("part" in value["body"]["processInquiry"] ? (typeof value["body"]["processInquiry"]["part"] === "number" && Number.isInteger(value["body"]["processInquiry"]["part"]) && value["body"]["processInquiry"]["part"] >= 0 && value["body"]["processInquiry"]["part"] <= 15) : true) && hasOnlyKeys(value["body"]["processInquiry"], ["functionBlock","part"]) : true) && ("processInquiryReply" in value["body"] ? isPlainObject(value["body"]["processInquiryReply"]) && ("functionBlock" in value["body"]["processInquiryReply"] ? (typeof value["body"]["processInquiryReply"]["functionBlock"] === "number" && Number.isInteger(value["body"]["processInquiryReply"]["functionBlock"]) && value["body"]["processInquiryReply"]["functionBlock"] >= 0 && value["body"]["processInquiryReply"]["functionBlock"] <= 127) : true) && ("part" in value["body"]["processInquiryReply"] ? (typeof value["body"]["processInquiryReply"]["part"] === "number" && Number.isInteger(value["body"]["processInquiryReply"]["part"]) && value["body"]["processInquiryReply"]["part"] >= 0 && value["body"]["processInquiryReply"]["part"] <= 15) : true) && hasOnlyKeys(value["body"]["processInquiryReply"], ["functionBlock","part"]) : true) && hasOnlyKeys(value["body"], ["opcode","endpointDiscovery","endpointInfoNotification","deviceIdentityNotification","endpointNameNotification","productInstanceIdNotification","streamConfigRequest","streamConfigNotification","functionBlockDiscovery","functionBlockInfo","processInquiry","processInquiryReply"])))) && hasOnlyKeys(value, ["messageType","group","body"]);
}

export function isUmpPacket64(value: unknown): value is UmpPacket64 {
  return isPlainObject(value) && ("messageType" in value && value["messageType"] === 4) && ("group" in value && isUint4(value["group"])) && ("statusNibble" in value && (value["statusNibble"] === 8 || value["statusNibble"] === 9 || value["statusNibble"] === 10 || value["statusNibble"] === 11 || value["statusNibble"] === 12 || value["statusNibble"] === 13 || value["statusNibble"] === 14 || value["statusNibble"] === 15)) && ("channel" in value && (typeof value["channel"] === "number" && Number.isInteger(value["channel"]) && value["channel"] >= 0 && value["channel"] <= 15)) && ("body" in value && (isPlainObject(value["body"]) && ("statusNibble" in value["body"] && (value["body"]["statusNibble"] === 8 || value["body"]["statusNibble"] === 9 || value["body"]["statusNibble"] === 10 || value["body"]["statusNibble"] === 11 || value["body"]["statusNibble"] === 12 || value["body"]["statusNibble"] === 13 || value["body"]["statusNibble"] === 14 || value["body"]["statusNibble"] === 15)) && ("channel" in value["body"] && (typeof value["body"]["channel"] === "number" && Number.isInteger(value["body"]["channel"]) && value["body"]["channel"] >= 0 && value["body"]["channel"] <= 15)) && hasOnlyKeys(value["body"], ["statusNibble","channel","body"])) && ((isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 8 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("velocity16" in value["body"]["body"] && (typeof value["body"]["body"]["velocity16"] === "number" && Number.isInteger(value["body"]["body"]["velocity16"]) && value["body"]["body"]["velocity16"] >= 0 && value["body"]["body"]["velocity16"] <= 65535)) && ("attributeType" in value["body"]["body"] ? (typeof value["body"]["body"]["attributeType"] === "number" && Number.isInteger(value["body"]["body"]["attributeType"]) && value["body"]["body"]["attributeType"] >= 0 && value["body"]["body"]["attributeType"] <= 255) : true) && ("attributeData16" in value["body"]["body"] ? (typeof value["body"]["body"]["attributeData16"] === "number" && Number.isInteger(value["body"]["body"]["attributeData16"]) && value["body"]["body"]["attributeData16"] >= 0 && value["body"]["body"]["attributeData16"] <= 65535) : true) && hasOnlyKeys(value["body"]["body"], ["noteNumber","velocity16","attributeType","attributeData16"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 9 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("velocity16" in value["body"]["body"] && (typeof value["body"]["body"]["velocity16"] === "number" && Number.isInteger(value["body"]["body"]["velocity16"]) && value["body"]["body"]["velocity16"] >= 0 && value["body"]["body"]["velocity16"] <= 65535)) && ("attributeType" in value["body"]["body"] ? (typeof value["body"]["body"]["attributeType"] === "number" && Number.isInteger(value["body"]["body"]["attributeType"]) && value["body"]["body"]["attributeType"] >= 0 && value["body"]["body"]["attributeType"] <= 255) : true) && ("attributeData16" in value["body"]["body"] ? (typeof value["body"]["body"]["attributeData16"] === "number" && Number.isInteger(value["body"]["body"]["attributeData16"]) && value["body"]["body"]["attributeData16"] >= 0 && value["body"]["body"]["attributeData16"] <= 65535) : true) && hasOnlyKeys(value["body"]["body"], ["noteNumber","velocity16","attributeType","attributeData16"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 10 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("polyPressure32" in value["body"]["body"] && (typeof value["body"]["body"]["polyPressure32"] === "number" && Number.isInteger(value["body"]["body"]["polyPressure32"]) && value["body"]["body"]["polyPressure32"] >= 0 && value["body"]["body"]["polyPressure32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["noteNumber","polyPressure32"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 11 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("control" in value["body"]["body"] && (typeof value["body"]["body"]["control"] === "number" && Number.isInteger(value["body"]["body"]["control"]) && value["body"]["body"]["control"] >= 0 && value["body"]["body"]["control"] <= 127)) && ("controlValue32" in value["body"]["body"] && (typeof value["body"]["body"]["controlValue32"] === "number" && Number.isInteger(value["body"]["body"]["controlValue32"]) && value["body"]["body"]["controlValue32"] >= 0 && value["body"]["body"]["controlValue32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["control","controlValue32"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 12 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("program" in value["body"]["body"] && (typeof value["body"]["body"]["program"] === "number" && Number.isInteger(value["body"]["body"]["program"]) && value["body"]["body"]["program"] >= 0 && value["body"]["body"]["program"] <= 127)) && ("bankMsb" in value["body"]["body"] ? (typeof value["body"]["body"]["bankMsb"] === "number" && Number.isInteger(value["body"]["body"]["bankMsb"]) && value["body"]["body"]["bankMsb"] >= 0 && value["body"]["body"]["bankMsb"] <= 127) : true) && ("bankLsb" in value["body"]["body"] ? (typeof value["body"]["body"]["bankLsb"] === "number" && Number.isInteger(value["body"]["body"]["bankLsb"]) && value["body"]["body"]["bankLsb"] >= 0 && value["body"]["body"]["bankLsb"] <= 127) : true) && ("bankValid" in value["body"]["body"] ? typeof value["body"]["body"]["bankValid"] === "boolean" : true) && hasOnlyKeys(value["body"]["body"], ["program","bankMsb","bankLsb","bankValid"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 13 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("channelPressure32" in value["body"]["body"] && (typeof value["body"]["body"]["channelPressure32"] === "number" && Number.isInteger(value["body"]["body"]["channelPressure32"]) && value["body"]["body"]["channelPressure32"] >= 0 && value["body"]["body"]["channelPressure32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["channelPressure32"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 14 : true) && ("body" in value["body"] ? isPlainObject(value["body"]["body"]) && ("pitchBend32" in value["body"]["body"] && (typeof value["body"]["body"]["pitchBend32"] === "number" && Number.isInteger(value["body"]["body"]["pitchBend32"]) && value["body"]["body"]["pitchBend32"] >= 0 && value["body"]["body"]["pitchBend32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["pitchBend32"]) : true)) || (isPlainObject(value["body"]) && ("statusNibble" in value["body"] ? value["body"]["statusNibble"] === 15 : true) && ("body" in value["body"] ? ((isPlainObject(value["body"]["body"]) && ("rpnIndexMsb" in value["body"]["body"] && (typeof value["body"]["body"]["rpnIndexMsb"] === "number" && Number.isInteger(value["body"]["body"]["rpnIndexMsb"]) && value["body"]["body"]["rpnIndexMsb"] >= 0 && value["body"]["body"]["rpnIndexMsb"] <= 127)) && ("rpnIndexLsb" in value["body"]["body"] && (typeof value["body"]["body"]["rpnIndexLsb"] === "number" && Number.isInteger(value["body"]["body"]["rpnIndexLsb"]) && value["body"]["body"]["rpnIndexLsb"] >= 0 && value["body"]["body"]["rpnIndexLsb"] <= 127)) && ("rpnData32" in value["body"]["body"] && (typeof value["body"]["body"]["rpnData32"] === "number" && Number.isInteger(value["body"]["body"]["rpnData32"]) && value["body"]["body"]["rpnData32"] >= 0 && value["body"]["body"]["rpnData32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["rpnIndexMsb","rpnIndexLsb","rpnData32"])) || (isPlainObject(value["body"]["body"]) && ("nrpnIndexMsb" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnIndexMsb"] === "number" && Number.isInteger(value["body"]["body"]["nrpnIndexMsb"]) && value["body"]["body"]["nrpnIndexMsb"] >= 0 && value["body"]["body"]["nrpnIndexMsb"] <= 127)) && ("nrpnIndexLsb" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnIndexLsb"] === "number" && Number.isInteger(value["body"]["body"]["nrpnIndexLsb"]) && value["body"]["body"]["nrpnIndexLsb"] >= 0 && value["body"]["body"]["nrpnIndexLsb"] <= 127)) && ("nrpnData32" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnData32"] === "number" && Number.isInteger(value["body"]["body"]["nrpnData32"]) && value["body"]["body"]["nrpnData32"] >= 0 && value["body"]["body"]["nrpnData32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["nrpnIndexMsb","nrpnIndexLsb","nrpnData32"])) || (isPlainObject(value["body"]["body"]) && ("rpnIndexMsb" in value["body"]["body"] && (typeof value["body"]["body"]["rpnIndexMsb"] === "number" && Number.isInteger(value["body"]["body"]["rpnIndexMsb"]) && value["body"]["body"]["rpnIndexMsb"] >= 0 && value["body"]["body"]["rpnIndexMsb"] <= 127)) && ("rpnIndexLsb" in value["body"]["body"] && (typeof value["body"]["body"]["rpnIndexLsb"] === "number" && Number.isInteger(value["body"]["body"]["rpnIndexLsb"]) && value["body"]["body"]["rpnIndexLsb"] >= 0 && value["body"]["body"]["rpnIndexLsb"] <= 127)) && ("rpnDelta32" in value["body"]["body"] && (typeof value["body"]["body"]["rpnDelta32"] === "number" && Number.isInteger(value["body"]["body"]["rpnDelta32"]) && value["body"]["body"]["rpnDelta32"] >= -2147483648 && value["body"]["body"]["rpnDelta32"] <= 2147483647)) && hasOnlyKeys(value["body"]["body"], ["rpnIndexMsb","rpnIndexLsb","rpnDelta32"])) || (isPlainObject(value["body"]["body"]) && ("nrpnIndexMsb" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnIndexMsb"] === "number" && Number.isInteger(value["body"]["body"]["nrpnIndexMsb"]) && value["body"]["body"]["nrpnIndexMsb"] >= 0 && value["body"]["body"]["nrpnIndexMsb"] <= 127)) && ("nrpnIndexLsb" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnIndexLsb"] === "number" && Number.isInteger(value["body"]["body"]["nrpnIndexLsb"]) && value["body"]["body"]["nrpnIndexLsb"] >= 0 && value["body"]["body"]["nrpnIndexLsb"] <= 127)) && ("nrpnDelta32" in value["body"]["body"] && (typeof value["body"]["body"]["nrpnDelta32"] === "number" && Number.isInteger(value["body"]["body"]["nrpnDelta32"]) && value["body"]["body"]["nrpnDelta32"] >= -2147483648 && value["body"]["body"]["nrpnDelta32"] <= 2147483647)) && hasOnlyKeys(value["body"]["body"], ["nrpnIndexMsb","nrpnIndexLsb","nrpnDelta32"])) || (isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("detach" in value["body"]["body"] && typeof value["body"]["body"]["detach"] === "boolean") && ("reset" in value["body"]["body"] && typeof value["body"]["body"]["reset"] === "boolean") && hasOnlyKeys(value["body"]["body"], ["noteNumber","detach","reset"])) || (isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("regPerNoteCtrlIndex" in value["body"]["body"] && (typeof value["body"]["body"]["regPerNoteCtrlIndex"] === "number" && Number.isInteger(value["body"]["body"]["regPerNoteCtrlIndex"]) && value["body"]["body"]["regPerNoteCtrlIndex"] >= 0 && value["body"]["body"]["regPerNoteCtrlIndex"] <= 255)) && ("regPerNoteCtrlValue32" in value["body"]["body"] && (typeof value["body"]["body"]["regPerNoteCtrlValue32"] === "number" && Number.isInteger(value["body"]["body"]["regPerNoteCtrlValue32"]) && value["body"]["body"]["regPerNoteCtrlValue32"] >= 0 && value["body"]["body"]["regPerNoteCtrlValue32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["noteNumber","regPerNoteCtrlIndex","regPerNoteCtrlValue32"])) || (isPlainObject(value["body"]["body"]) && ("noteNumber" in value["body"]["body"] && (typeof value["body"]["body"]["noteNumber"] === "number" && Number.isInteger(value["body"]["body"]["noteNumber"]) && value["body"]["body"]["noteNumber"] >= 0 && value["body"]["body"]["noteNumber"] <= 127)) && ("assignPerNoteCtrlIndex" in value["body"]["body"] && (typeof value["body"]["body"]["assignPerNoteCtrlIndex"] === "number" && Number.isInteger(value["body"]["body"]["assignPerNoteCtrlIndex"]) && value["body"]["body"]["assignPerNoteCtrlIndex"] >= 0 && value["body"]["body"]["assignPerNoteCtrlIndex"] <= 255)) && ("assignPerNoteCtrlValue32" in value["body"]["body"] && (typeof value["body"]["body"]["assignPerNoteCtrlValue32"] === "number" && Number.isInteger(value["body"]["body"]["assignPerNoteCtrlValue32"]) && value["body"]["body"]["assignPerNoteCtrlValue32"] >= 0 && value["body"]["body"]["assignPerNoteCtrlValue32"] <= 4294967295)) && hasOnlyKeys(value["body"]["body"], ["noteNumber","assignPerNoteCtrlIndex","assignPerNoteCtrlValue32"]))) : true)))) && hasOnlyKeys(value, ["messageType","group","statusNibble","channel","body"]);
}

export function isUtilityBody(value: unknown): value is UtilityBody {
  return isPlainObject(value) && ("opcode" in value && (value["opcode"] === 0 || value["opcode"] === 1 || value["opcode"] === 2)) && ("jrClock" in value ? isPlainObject(value["jrClock"]) && ("timestamp32" in value["jrClock"] && (typeof value["jrClock"]["timestamp32"] === "number" && Number.isInteger(value["jrClock"]["timestamp32"]) && value["jrClock"]["timestamp32"] >= 0 && value["jrClock"]["timestamp32"] <= 4294967295)) && hasOnlyKeys(value["jrClock"], ["timestamp32"]) : true) && ("jrTimestamp" in value ? isPlainObject(value["jrTimestamp"]) && ("time15" in value["jrTimestamp"] && (typeof value["jrTimestamp"]["time15"] === "number" && Number.isInteger(value["jrTimestamp"]["time15"]) && value["jrTimestamp"]["time15"] >= 0 && value["jrTimestamp"]["time15"] <= 32767)) && hasOnlyKeys(value["jrTimestamp"], ["time15"]) : true) && hasOnlyKeys(value, ["opcode","jrClock","jrTimestamp"]);
}

export function isUtilityOpcode(value: unknown): value is UtilityOpcode {
  return (value === 0 || value === 1 || value === 2);
}
