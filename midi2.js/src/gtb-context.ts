const gtbAllowedByGroup = new Map<number, Set<number>>();

export function setGtbAllowedMessageTypes(group: number, allowed: Set<number>): void {
  gtbAllowedByGroup.set(group & 0xf, new Set(Array.from(allowed).map(n => n & 0xf)));
}

export function getGtbAllowedMessageTypesForGroup(group: number): Set<number> | null {
  return gtbAllowedByGroup.get(group & 0xf) ?? null;
}

export function clearGtbContext(): void {
  gtbAllowedByGroup.clear();
}
