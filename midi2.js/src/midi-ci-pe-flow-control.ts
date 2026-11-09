/**
 * M2-101-UM v1.2.1: MIDI-CI ACK/NAK Property Exchange flow control.
 * Sections 5.10.2/5.11.2, Tables 14 and 16, pp. 34 and 36.
 * This is only the eight 7-bit status/detail bytes after MUIDs.
 * It is not an entire SysEx message, nor legacy PE Notify (0x3F).
 */
export type MidiCiPEFlowAction = "sendNextChunks" | "resendMostRecentChunk";

export interface MidiCiPEFlowControl {
  action: MidiCiPEFlowAction;
  originalTransactionSubId2: number;
  peStreamId: number;
  peChunkNumber: number;
}

export function midiCiPEFlowControlStatus(
  action: MidiCiPEFlowAction,
): { subId2: number; statusCode: number; statusData: 0 } {
  return action === "sendNextChunks"
    ? { subId2: 0x7d, statusCode: 0x11, statusData: 0 }
    : { subId2: 0x7f, statusCode: 0x12, statusData: 0 };
}

function validate(flow: MidiCiPEFlowControl): void {
  if (!Number.isInteger(flow.originalTransactionSubId2) ||
      flow.originalTransactionSubId2 < 0x30 ||
      flow.originalTransactionSubId2 > 0x3f) {
    throw new RangeError("PE transaction classification must be 0x30..0x3F");
  }
  if (!Number.isInteger(flow.peStreamId) || flow.peStreamId < 0 ||
      flow.peStreamId > 0x7f) {
    throw new RangeError("PE stream ID must be 7-bit");
  }
  if (!Number.isInteger(flow.peChunkNumber) || flow.peChunkNumber < 0 ||
      flow.peChunkNumber > 0x3fff) {
    throw new RangeError("PE chunk must fit two 7-bit bytes");
  }
}

export function encodeMidiCiPEFlowControl(
  flow: MidiCiPEFlowControl,
): { subId2: number; statusFields: Uint8Array } {
  validate(flow);
  const header = midiCiPEFlowControlStatus(flow.action);
  return {
    subId2: header.subId2,
    statusFields: Uint8Array.from([
      flow.originalTransactionSubId2, header.statusCode, 0,
      flow.peStreamId, flow.peChunkNumber & 0x7f,
      (flow.peChunkNumber >> 7) & 0x7f, 0, 0,
    ]),
  };
}

export function decodeMidiCiPEFlowControl(
  subId2: number, statusFields: Uint8Array,
): MidiCiPEFlowControl {
  if (statusFields.length !== 8 || Array.from(statusFields).some((n) => n > 127)) {
    throw new RangeError("Malformed 7-bit ACK/NAK status fields");
  }
  const code = statusFields[1];
  const action: MidiCiPEFlowAction =
    subId2 === 0x7d && code === 0x11 ? "sendNextChunks" :
    subId2 === 0x7f && code === 0x12 ? "resendMostRecentChunk" :
    (() => { throw new RangeError("ACK/NAK Sub-ID or flow status mismatch"); })();
  if (statusFields[2] !== 0) throw new RangeError("Invalid flow-control status data");
  const decoded: MidiCiPEFlowControl = {
    action,
    originalTransactionSubId2: statusFields[0],
    peStreamId: statusFields[3],
    peChunkNumber: statusFields[4] | (statusFields[5] << 7),
  };
  validate(decoded);
  return decoded;
}
