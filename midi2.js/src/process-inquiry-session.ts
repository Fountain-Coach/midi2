import { ProcessInquiryEvent } from "./types";

function isValidDeviceId(id: number): boolean {
  return Number.isInteger(id) && (id <= 0x0f || id === 0x7e || id === 0x7f);
}

function clampFilters(requested: Record<string, number> | undefined, supported: Record<string, number>): Record<string, number> {
  if (!requested) return {};
  const out: Record<string, number> = {};
  for (const [key, reqVal] of Object.entries(requested)) {
    if (!Number.isInteger(reqVal) || reqVal < 0 || reqVal > 0x7f) continue;
    if (key === "messageDataControl" && reqVal !== 0x00 && reqVal !== 0x01 && reqVal !== 0x7f) continue;
    const sup = supported[key];
    if (sup && sup > 0) {
      out[key] = Math.min(reqVal, sup);
    }
  }
  return out;
}

/**
 * Minimal Process Inquiry runtime helper: echoes capability (capReply) and clamps messageReport filters.
 */
export class ProcessInquirySession {
  private readonly supported: Record<string, number>;
  private readonly deviceId: number;

  constructor(opts: { filters?: Record<string, number>; deviceId?: number } = {}) {
    this.supported = opts.filters ?? {};
    this.deviceId = opts.deviceId ?? 0x7f;
  }

  handle(evt: ProcessInquiryEvent): ProcessInquiryEvent | null {
    if (!isValidDeviceId(this.deviceId)) return null;
    switch (evt.command) {
      case "capInquiry":
        return { kind: "processInquiry", group: evt.group, command: "capReply", filters: this.supported };
      case "messageReport": {
        const clamped = clampFilters(evt.filters, this.supported);
        return { kind: "processInquiry", group: evt.group, command: "messageReportReply", filters: clamped };
      }
      case "endReport":
        return null;
      default:
        return null;
    }
  }
}
