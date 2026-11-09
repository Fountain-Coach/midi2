# Release Process — GitHub-first MIDI2

## Purpose
Coordinate signed MIDI2 Swift and TypeScript releases via canonical Git and
GitHub Releases. No npm registry account or package publication is required.

## When to Use
Version bumps, scheduled releases, hotfixes, release checks, and publication
status corrections.

## Required Steps
1. Inspect AGENTS.md, RELEASE.md, PLANS.md, changelog, versions, release
   evidence, normative source manifest and bounded claims.
2. Build and test Swift and TypeScript, verify provenance and negative
   scenarios, and enforce required protected CI/coverage.
3. Merge the changes through protected main using the required PR workflow.
4. Create, verify and push a signed annotated version tag on exact source.
5. Publish GitHub Release with source commit, test evidence and limitations.
6. Independently verify public tag, Release and Git-based Swift/JS source
   consumption. Reconcile human and machine docs.
7. Declare the GitHub source release COMPLETE after those predicates pass.

## Optional registries
npm and other registries are independent, optional publication mirrors.
Never require registry signup, account access, tokens or npm publish for a
source release; never infer npm availability without registry evidence.
npm CLI use to test/build TypeScript is unrelated to npm-site publication.

## Boundaries
No unsigned tag fallback, moved released tags, credentials in Git,
unverified hardware interoperability, protocol certification or broader
runtime conformance inference. Follow RELEASE.md and AGENTS.md.

## Output Contract
Signed tag, exact source SHA, public GitHub Release, Swift/JS test evidence,
Git-based consumption, and optional registry state reported separately.
