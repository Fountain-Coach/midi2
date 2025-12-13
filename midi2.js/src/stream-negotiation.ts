import { StreamEvent } from "./types";

export type StreamProtocol = "midi1" | "midi2";

export type StreamCapabilities = {
  supportsMIDI2?: boolean;
  jrTx?: boolean;
  jrRx?: boolean;
};

export type StreamConfigShape = {
  protocol: StreamProtocol;
  jrTimestampsTx?: boolean;
  jrTimestampsRx?: boolean;
};

export type StreamConfigMismatch =
  | { kind: "protocolDowngraded"; requested: StreamProtocol; selected: StreamProtocol }
  | { kind: "jrTxRejected" }
  | { kind: "jrRxRejected" };

export type StreamConfigNegotiationOptions = {
  previous?: StreamConfigShape;
  forceNotification?: boolean;
};

export type StreamConfigNegotiationResult = {
  notification: StreamConfigShape;
  mismatches: StreamConfigMismatch[];
  switchedProtocol: boolean;
  shouldNotifyPeer: boolean;
  accepted: boolean;
  nextConfiguration: StreamConfigShape;
};

function normalizeCaps(caps?: StreamCapabilities) {
  return {
    supportsMIDI2: caps?.supportsMIDI2 ?? true,
    jrTx: caps?.jrTx ?? true,
    jrRx: caps?.jrRx ?? true,
  };
}

/**
 * Stateless negotiation helper mirroring the Stream Configuration rules:
 * - Downgrade to MIDI 1.0 when responder lacks MIDI 2.0 support.
 * - Clear unsupported JR directions.
 * - Emit mismatch reasons and notification policy flags.
 */
export function negotiateStreamConfig(
  request: StreamConfigShape,
  caps?: StreamCapabilities,
  opts?: StreamConfigNegotiationOptions,
): StreamConfigNegotiationResult {
  const normCaps = normalizeCaps(caps);
  const mismatches: StreamConfigMismatch[] = [];

  const selectedProtocol: StreamProtocol = normCaps.supportsMIDI2 && request.protocol === "midi2" ? "midi2" : "midi1";
  if (selectedProtocol !== request.protocol) {
    mismatches.push({ kind: "protocolDowngraded", requested: request.protocol, selected: selectedProtocol });
  }

  const jrTx = normCaps.jrTx && !!request.jrTimestampsTx;
  const jrRx = normCaps.jrRx && !!request.jrTimestampsRx;

  if (jrTx !== !!request.jrTimestampsTx) {
    mismatches.push({ kind: "jrTxRejected" });
  }
  if (jrRx !== !!request.jrTimestampsRx) {
    mismatches.push({ kind: "jrRxRejected" });
  }

  const notification: StreamConfigShape = {
    protocol: selectedProtocol,
    jrTimestampsTx: jrTx,
    jrTimestampsRx: jrRx,
  };

  const previous = opts?.previous;
  const switchedProtocol = previous ? previous.protocol !== selectedProtocol : true;
  const shouldNotifyPeer = !!opts?.forceNotification || mismatches.length > 0 || !previous || switchedProtocol;

  return {
    notification,
    mismatches,
    switchedProtocol,
    shouldNotifyPeer,
    accepted: mismatches.length === 0,
    nextConfiguration: notification,
  };
}

/**
 * Stateful session that tracks the last negotiated configuration.
 */
export class StreamNegotiationSession {
  readonly responderCaps: StreamCapabilities;
  currentConfiguration?: StreamConfigShape;
  lastMismatchReasons: StreamConfigMismatch[] = [];
  lastConfigMismatch = false;

  constructor(caps?: StreamCapabilities) {
    this.responderCaps = caps ?? {};
  }

  negotiate(request: StreamConfigShape, opts?: { forceNotification?: boolean }): StreamConfigNegotiationResult {
    const result = negotiateStreamConfig(request, this.responderCaps, { previous: this.currentConfiguration, forceNotification: opts?.forceNotification });
    this.currentConfiguration = result.nextConfiguration;
    this.lastMismatchReasons = result.mismatches;
    this.lastConfigMismatch = result.mismatches.length > 0;
    return result;
  }

  /**
   * Convenience to produce a `StreamEvent` notification for encoding.
   */
  toStreamEvent(group: number, cfg: StreamConfigShape): StreamEvent {
    return {
      kind: "stream",
      group,
      opcode: "streamConfigNotification",
      streamConfigNotification: {
        protocol: cfg.protocol,
        jrTimestampsTx: cfg.jrTimestampsTx,
        jrTimestampsRx: cfg.jrTimestampsRx,
      },
    };
  }
}
