export interface PeerState {
  muid: number;
  lastSeenMs: number;
}

export interface MuidManagerOptions {
  ttlMs?: number;
  now?: () => number;
  localHint?: number;
}

/**
 * Manages allocation and lifetime of MIDI-CI MUIDs (MIDI Universal IDs).
 * Tracks peers, detects conflicts, and expires stale entries.
 */
export class MuidManager {
  private readonly ttlMs: number;
  private readonly now: () => number;
  private peers = new Map<number, number>();
  public localMuid: number;

  constructor(options: MuidManagerOptions = {}) {
    this.ttlMs = options.ttlMs ?? 120_000;
    this.now = options.now ?? (() => Date.now());
    this.localMuid = this.allocateUnique(options.localHint);
  }

  /**
   * Registers or refreshes a peer MUID. Returns true if this registration
   * conflicted with the local MUID and forced a rotation.
   */
  registerPeer(muid: number, at?: number): boolean {
    if (!this.isUsable(muid)) return false;
    const ts = at ?? this.now();
    this.peers.set(muid >>> 0, ts);
    if (muid === this.localMuid) {
      this.rotateLocal();
      return true;
    }
    return false;
  }

  /** Releases a tracked peer. */
  releasePeer(muid: number): boolean {
    return this.peers.delete(muid >>> 0);
  }

  /** Removes peers whose lastSeen timestamp is older than the TTL. */
  cleanup(at?: number): number[] {
    const cutoff = (at ?? this.now()) - this.ttlMs;
    const expired: number[] = [];
    for (const [muid, lastSeen] of this.peers.entries()) {
      if (lastSeen < cutoff) {
        expired.push(muid);
        this.peers.delete(muid);
      }
    }
    return expired;
  }

  /** Snapshot of tracked peers. */
  get peersSnapshot(): PeerState[] {
    return Array.from(this.peers.entries()).map(([muid, lastSeenMs]) => ({ muid, lastSeenMs }));
  }

  /** Forces a new local MUID, avoiding collisions with peers. */
  rotateLocal(): number {
    this.localMuid = this.allocateUnique();
    return this.localMuid;
  }

  private allocateUnique(preferred?: number): number {
    const isFree = (candidate: number) => this.isUsable(candidate) && candidate !== this.localMuid && !this.peers.has(candidate >>> 0);
    if (preferred !== undefined && isFree(preferred)) {
      return preferred >>> 0;
    }
    for (let i = 0; i < 16; i++) {
      const candidate = (Math.floor(Math.random() * 0xffffffff) + 1) >>> 0;
      if (isFree(candidate)) return candidate;
    }
    let candidate = 1;
    while (!isFree(candidate)) {
      candidate = (candidate + 1) >>> 0;
      if (candidate === 0) candidate = 1;
    }
    return candidate >>> 0;
  }

  private isUsable(muid: number): boolean {
    return Number.isInteger(muid) && muid > 0 && muid <= 0xffffffff;
  }
}
