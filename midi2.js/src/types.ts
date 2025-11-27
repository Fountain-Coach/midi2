export type MidiTimestamp = number;

export interface Midi2ChannelVoiceBase {
  group: number;
  channel: number;
  timestamp?: MidiTimestamp;
}

export interface Midi2NoteOnEvent extends Midi2ChannelVoiceBase {
  kind: "noteOn";
  note: number;
  velocity: number;
  attributeType?: number;
  attributeData?: number;
}

export interface Midi2NoteOffEvent extends Midi2ChannelVoiceBase {
  kind: "noteOff";
  note: number;
  velocity?: number;
  attributeType?: number;
  attributeData?: number;
}

export interface Midi2PolyPressureEvent extends Midi2ChannelVoiceBase {
  kind: "polyPressure";
  note: number;
  pressure: number;
}

export interface Midi2ControlChangeEvent extends Midi2ChannelVoiceBase {
  kind: "controlChange";
  controller: number;
  value: number;
}

export interface Midi2ProgramChangeEvent extends Midi2ChannelVoiceBase {
  kind: "programChange";
  program: number;
  bankMsb?: number;
  bankLsb?: number;
}

export interface Midi2ChannelPressureEvent extends Midi2ChannelVoiceBase {
  kind: "channelPressure";
  pressure: number;
}

export interface Midi2PitchBendEvent extends Midi2ChannelVoiceBase {
  kind: "pitchBend";
  value: number;
}

export interface Midi2RpnEvent extends Midi2ChannelVoiceBase {
  kind: "rpn";
  bank: number;
  index: number;
  value: number;
}

export interface Midi2NrpnEvent extends Midi2ChannelVoiceBase {
  kind: "nrpn";
  bank: number;
  index: number;
  value: number;
}

export interface Midi2RpnRelativeEvent extends Midi2ChannelVoiceBase {
  kind: "rpnRelative";
  bank: number;
  index: number;
  delta: number;
}

export interface Midi2NrpnRelativeEvent extends Midi2ChannelVoiceBase {
  kind: "nrpnRelative";
  bank: number;
  index: number;
  delta: number;
}

export interface Midi2PerNoteManagementEvent extends Midi2ChannelVoiceBase {
  kind: "perNoteManagement";
  note: number;
  detach: boolean;
  reset: boolean;
}

export interface Midi2PerNoteRegisteredControllerEvent extends Midi2ChannelVoiceBase {
  kind: "perNoteRegisteredController";
  note: number;
  controller: number;
  value: number;
}

export interface Midi2PerNoteAssignableControllerEvent extends Midi2ChannelVoiceBase {
  kind: "perNoteAssignableController";
  note: number;
  controller: number;
  value: number;
}

export interface SysEx7Event {
  kind: "sysex7";
  group: number;
  manufacturerId: number[];
  payload: Uint8Array;
  timestamp?: MidiTimestamp;
}

export interface SysEx8Event {
  kind: "sysex8";
  group: number;
  manufacturerId: number[];
  payload: Uint8Array;
  timestamp?: MidiTimestamp;
}

export interface MidiCiEvent {
  kind: "midiCi";
  group: number;
  scope: "nonRealtime" | "realtime";
  subId2: number;
  version: number;
  payload: Uint8Array;
  format: "sysex7" | "sysex8";
  timestamp?: MidiTimestamp;
}

export interface Midi2SystemEvent {
  kind: "system";
  group: number;
  status: number;
  data1?: number;
  data2?: number;
  timestamp?: MidiTimestamp;
}

export interface Midi1ChannelVoiceEvent {
  kind: "midi1ChannelVoice";
  group: number;
  status: number;
  data1?: number;
  data2?: number;
  timestamp?: MidiTimestamp;
}

export interface UtilityEvent {
  kind: "utility";
  status: "noop" | "jrClock" | "jrTimestamp";
  value?: number;
  timestamp?: MidiTimestamp;
}

export interface RawUMPEvent {
  kind: "rawUMP";
  words: Uint32Array;
  timestamp?: MidiTimestamp;
}

export type Midi2Event =
  | Midi2NoteOnEvent
  | Midi2NoteOffEvent
  | Midi2PolyPressureEvent
  | Midi2ControlChangeEvent
  | Midi2ProgramChangeEvent
  | Midi2ChannelPressureEvent
  | Midi2PitchBendEvent
  | Midi2RpnEvent
  | Midi2NrpnEvent
  | Midi2RpnRelativeEvent
  | Midi2NrpnRelativeEvent
  | Midi2PerNoteManagementEvent
  | Midi2PerNoteRegisteredControllerEvent
  | Midi2PerNoteAssignableControllerEvent
  | Midi2SystemEvent
  | Midi1ChannelVoiceEvent
  | UtilityEvent
  | SysEx7Event
  | SysEx8Event
  | MidiCiEvent
  | RawUMPEvent;

export type MidiEventHandler = (event: Midi2Event) => void;
