# midi2.js release checklist — GitHub-first

The signed MIDI2 Git tag and public GitHub Release are the authoritative
distribution of the TypeScript/JavaScript source. npm registry publication
is optional and never blocks the source-release DoD. See RELEASE.md.

## Required
- [ ] Matching Swift and JS version metadata and committed lockfile.
- [ ] CI and coverage green; source checkout clean and tied to tested commit.
- [ ] JS source passes npm ci, npm run check, npm test and npm run build.
      npm CLI is local build tooling, not a publisher account prerequisite.
- [ ] Built entrypoints and types resolve; no copyrighted specification PDF
      or private artifacts are distributed.
- [ ] Signed tag on exact tested commit; public GitHub Release and accurate
      limitations and installation instructions.
- [ ] Clean Git checkout at release tag can build midi2.js from source.

## Optional
- [ ] GitHub Releases JS binary/tarball with verified source SHA/digest.
- [ ] Authorized optional registry mirror with its own public integrity
      receipt (npm or otherwise). NEVER a prerequisite for GitHub release.
