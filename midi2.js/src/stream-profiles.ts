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

export function updateProfileAssociation(index: number, profileId: string, enabled: boolean): void {
  const key = index & 0xff;
  const entry = profileMap.get(key) ?? { profiles: [], lastUpdated: Date.now() };
  const next = new Set(entry.profiles);
  if (enabled) {
    next.add(profileId);
  } else {
    next.delete(profileId);
  }
  profileMap.set(key, { profiles: Array.from(next), lastUpdated: Date.now() });
}
