const profileMap = new Map<number, { profiles: string[]; lastUpdated: number }>();

export function setProfileAssociations(index: number, profiles: string[]): void {
  profileMap.set(index & 0xff, { profiles: profiles.slice(), lastUpdated: Date.now() });
}

export function getProfileAssociations(index: number): string[] {
  const entry = profileMap.get(index & 0xff);
  return entry?.profiles.slice() ?? [];
}

export function getProfileAssociationsWithTimestamp(index: number): { profiles: string[]; lastUpdated: number | null } {
  const entry = profileMap.get(index & 0xff);
  return { profiles: entry?.profiles.slice() ?? [], lastUpdated: entry?.lastUpdated ?? null };
}
