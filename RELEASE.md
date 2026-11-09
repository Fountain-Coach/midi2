# MIDI2 release policy — GitHub-first

The canonical release authority is the Fountain-Coach/midi2 Git repository.
Signed Git tags, passing Swift and TypeScript tests, and public GitHub Releases
are the versioned software distribution contract. Package registries
(including npm) are OPTIONAL mirrors and must NEVER block a source release.

Binding rules: [AGENTS.md](AGENTS.md), protected-main PR checks, the
[release-process Skill](.codex/skills/release-process/SKILL.md), and
[claim register](docs/claim-register.md).

## Required release DoD

1. Update matching Swift Package.swift, midi2.js/package.json, lockfile,
   changelog, normative-source records, claims, and documentation.
2. Run Swift and TypeScript builds/tests, CI coverage (minimum 80%),
   source-provenance, normative inverse-ledger, runtime-boundary, claim and
   negative-scenario verification. Do not redistribute third-party PDFs
   without rights.
3. Merge through reviewed protected-main PR with green required checks.
4. Create, verify and push a SIGNED vMAJOR.MINOR.PATCH annotated Git tag
   on exactly the tested source commit. Never use an unsigned fallback.
5. Publish the public GitHub Release for the same tag, with accurate
   changelog, tests, source version and limitations.
6. Independently verify public Git tag/Release, Swift dependency resolution,
   and the versioned TypeScript/JavaScript source checkout and build.
7. Report GitHub source release COMPLETE when the preceding gates pass.
   Normative conformance, independent devices and hardware acceptance
   remain separately evidenced and cannot be inferred from release success.

## Consumer installation

Swift Package Manager, matching the signed v0.13.0 source tag:

~~~swift
.package(url: "https://github.com/Fountain-Coach/midi2.git", from: "0.13.0")
~~~

JavaScript/TypeScript consumers use the SAME versioned source under midi2.js:

~~~sh
git clone --depth 1 --branch v0.13.0 https://github.com/Fountain-Coach/midi2.git
cd midi2/midi2.js
npm ci
npm run check
npm run build
~~~

Here the npm CLI is only the local dependency/build tool. A MIDI2 npm
publisher account or registered @fountain-coach/midi2 package is NOT required
to obtain or build the tagged source. Consumers must explicitly link/bundle
the resulting midi2.js/dist output. Do not recommend registry installation
when no registry artifact exists.

A versioned, checksum-verified JavaScript build artifact on GitHub Releases
may improve convenience; that is OPTIONAL and must not be claimed without
its own asset and integrity receipt.

## Optional registry mirrors

An authorized maintainer MAY publish a separate copy to npm or any other
registry. Such an action has its own account authorization, legal rights,
version/integrity verification and receipt. Registry signup, npm whoami,
npm publish, token creation and registry availability are NOT required
checks for a MIDI2 GitHub source release. Registry failures MUST NOT
block signing, publishing or completing GitHub release acceptance.

## Verification and rollback

~~~sh
swift build -Xswiftc -warnings-as-errors
swift test
cd midi2.js
npm ci --ignore-scripts
npm run check
npm test
npm run build
cd ..
python3 Scripts/verify_spec_provenance.py
python3 Scripts/verify_normative_coverage.py
python3 Scripts/verify_runtime_completeness.py
python3 Scripts/verify_claims.py
python3 Scripts/verify_docs_release_status.py
python3 Scripts/verify_docs.py
~~~

The normative source verifier may require a separately fetched, SHA-256
pinned official PDF; only ephemeral verified sources may be used.

To hotfix: create a PR for a new SemVer patch, test and sign a NEW tag.
Never move or force-push an existing released tag. To rollback, direct
consumers to a previous known-good signed tag and document the limitation.
Website releases are a separate governed delivery and require HTTP/SHA-256
readback and an immutable predecessor.

### Current example

v0.13.0: signed Git tag and public GitHub Release at
https://github.com/Fountain-Coach/midi2/releases/tag/v0.13.0.
The Swift and JS source was tested. There is no npm registry artifact; this
does NOT render the GitHub source release incomplete. Full MIDI-CI PE
transaction recovery, M2-124 independent transport interoperability, and
physical-device acceptance remain separate evidence boundaries.
