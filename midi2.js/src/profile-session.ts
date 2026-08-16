import { ProfileEvent } from "./types";

type ProfileTarget = ProfileEvent["target"];

/** Stateful MIDI-CI Profile session for the TypeScript runtime. */
export class ProfileSession {
  private supported = new Set<string>();
  private psdCapable = new Set<string>();
  private enabled = new Map<string, Set<string>>();
  private details = new Map<string, ProfileEvent>();

  constructor(supportedProfiles: Iterable<string> = [], psdCapableProfiles?: Iterable<string>) {
    this.supported = new Set(supportedProfiles);
    this.psdCapable = new Set(psdCapableProfiles ?? this.supported);
  }

  private key(target?: ProfileTarget, channels?: number[]): string {
    const scope = target ?? "none";
    const channelScope = channels?.length ? [...channels].sort((a, b) => a - b).join(",") : "*";
    return `${scope}|${channelScope}`;
  }

  private mask(channels?: number[]): { cmL: number; cmH: number } {
    let mask = 0;
    for (const channel of channels ?? []) {
      if (Number.isInteger(channel) && channel >= 0 && channel <= 15) mask |= 1 << channel;
    }
    return { cmL: mask & 0xff, cmH: (mask >>> 8) & 0xff };
  }

  private event(base: Omit<ProfileEvent, "kind" | "group">, group = 0): ProfileEvent {
    return { kind: "profile", group, ...base };
  }

  updateSupportedProfiles(profiles: Iterable<string>, target?: ProfileTarget, channels?: number[]): ProfileEvent[] {
    const next = new Set(profiles);
    const added = [...next].filter(profile => !this.supported.has(profile)).sort();
    const removed = [...this.supported].filter(profile => !next.has(profile)).sort();
    this.supported = next;
    for (const profile of removed) this.psdCapable.delete(profile);
    for (const profile of added) this.psdCapable.add(profile);
    for (const set of this.enabled.values()) for (const profile of removed) set.delete(profile);
    const scope = this.mask(channels);
    return [
      ...added.map(profile => this.event({ command: "addedReport", profileId: profile, target, channels, details: { ok: 1, ...scope } })),
      ...removed.map(profile => this.event({ command: "removedReport", profileId: profile, target, channels, details: { ok: 1, ...scope } })),
    ];
  }

  lastDetails(target?: ProfileTarget, channels?: number[]): ProfileEvent | undefined {
    return this.details.get(this.key(target, channels));
  }

  handle(request: ProfileEvent): ProfileEvent[] {
    if (!request.profileId) return [];
    const key = this.key(request.target, request.channels);
    const scope = this.mask(request.channels);
    switch (request.command) {
      case "inquiry": {
        const reply = this.event({
          command: "reply", profileId: request.profileId, target: request.target, channels: request.channels,
          details: { ver: 1, supported: this.supported.has(request.profileId) ? 1 : 0, cmL: scope.cmL, cmH: scope.cmH },
        });
        this.details.set(key, reply);
        return [reply];
      }
      case "setOn": {
        if (!request.target) return [];
        const set = this.enabled.get(key) ?? new Set<string>();
        if (!this.supported.has(request.profileId)) {
          return [this.event({ command: "disabledReport", profileId: request.profileId, target: request.target, channels: request.channels, details: { ok: 0, ...scope } })];
        }
        set.add(request.profileId);
        this.enabled.set(key, set);
        return [this.event({ command: "enabledReport", profileId: request.profileId, target: request.target, channels: request.channels, details: { ok: 1, ...scope } })];
      }
      case "setOff": {
        if (!request.target) return [];
        this.enabled.get(key)?.delete(request.profileId);
        return [this.event({ command: "disabledReport", profileId: request.profileId, target: request.target, channels: request.channels, details: { ok: 1, ...scope } })];
      }
      case "detailsInquiry": {
        if (!request.target) return [];
        const reply = this.event({
          command: "detailsReply", profileId: request.profileId, target: request.target, channels: request.channels,
          details: {
            ver: 1,
            supported: this.supported.has(request.profileId) ? 1 : 0,
            enabled: this.enabled.get(key)?.has(request.profileId) ? 1 : 0,
            psd: this.psdCapable.has(request.profileId) ? 1 : 0,
            ...scope,
          },
        });
        this.details.set(key, reply);
        return [reply];
      }
      case "detailsReply":
        this.details.set(key, request);
        return [];
      default:
        return [];
    }
  }
}
