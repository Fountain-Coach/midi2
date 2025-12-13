const profileMap = new Map<number, string[]>();

export function setProfileAssociations(index: number, profiles: string[]): void {
  profileMap.set(index & 0xff, profiles.slice());
}

export function getProfileAssociations(index: number): string[] {
  return profileMap.get(index & 0xff)?.slice() ?? [];
}
