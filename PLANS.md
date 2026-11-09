# PLANS Protocol (FCIS RFC 0001)

## Active: cross-machine Discovery repair (2026-09-21)

Goal: make the existing midi2umpd Discovery responder answer a remote RTP peer.
Scope: UDP reply address, multi-packet framing/dispatch, complete SysEx8
reassembly, and Discovery envelope serialization. Reuse MidiCiDiscoveryResponder.
Acceptance: bidirectional transport and incomplete-fragment regression tests;
build and activate the exact candidate on Linux; decode its Discovery response
on the remote initiator. Promote to main only after this exchange succeeds.
Non-goals: protocol redesign, enrollment, Store admission, unrelated CI changes.

## Purpose
Define the planning protocol for multi-step or high-risk work in this repository. Plans capture intent, scope, and acceptance criteria before implementation begins.

## When a Plan Is Required
A plan is required when work is:
- Multi-step or cross-cutting across packages
- Release-related or security-sensitive
- Likely to change public APIs, CI, or compliance artifacts
- Non-trivial refactors or migrations

## Plan Format (Template)
A plan must answer **what** and **why**, not **how**. Use this template in issues, PRs, or planning docs:

```
Goal:
Scope:
Non-goals:
Constraints:
Dependencies:
Risks:
Steps:
  - [ ] Step 1 (intent + outcome)
  - [ ] Step 2 (intent + outcome)
Validation:
Acceptance Criteria:
```

## Status Conventions
- `pending` / `in_progress` / `completed`
- One `in_progress` step at a time

## Storage
Plans may live in:
- The PR description
- An issue description
- A dedicated planning document referenced by the PR

## Relationship to Skills
Execution details belong in `.codex/skills/*/SKILL.md`. Plans should link to relevant skills rather than include procedures.

---

Goal:
Align this repo with FCIS-VRT naming by migrating VRT-Protocol protocol baselines and references to VRT-Protocol, while preserving any legacy aliases needed for compatibility.
Scope:
Docs, tests, and scripts that reference VRT-Protocol protocol baselines.
Non-goals:
Renaming internal runtime identifiers or changing baseline content.
Constraints:
Keep existing baselines intact; update references and paths without altering data.
Dependencies:
Org-level FCIS-VRT standard and repo-wide rename agreement.
Risks:
Broken links or test failures if any path updates are missed.
Steps:
  - [x] Rename docs/pb-vrt to docs/vrt-protocol and update references.
  - [x] Rename VRT-Protocol test names/paths to VRT-Protocol.
  - [x] Update documentation to reflect FCIS-VRT Protocol terminology and legacy alias mapping.
Validation:
Search for VRT-Protocol references and ensure all paths resolve; run JS tests if needed.

---

Goal:
Make issue #129's PDF-to-semantic-object traceability claim mechanically verifiable on every commit.
Scope:
Canonical schema provenance, schema/OpenAPI parity, generated traceability artifacts, executable verification, mutation coverage, and CI integration.
Non-goals:
Claim complete runtime implementation or hardware interoperability; change the MIDI2 semantic contract; add Reframe-specific operations to this repository.
Constraints:
The closed JSON Schema remains canonical for semantic assertions; provenance must be embedded in that object and generated reports must not become independent authorities.
Dependencies:
The checked-in MIDI Association PDF set, existing schema/OpenAPI artifacts, Swift and TypeScript test trees, and the protected-main pull-request workflow.
Risks:
Existing documentation contains stale manual percentages and pending rows; replacing it with generated output may expose real gaps that must remain explicit until resolved.
Steps:
  - [ ] Add a machine-readable provenance manifest and embed provenance/verification metadata into every normative schema definition.
  - [ ] Add deterministic verification and report generation, including schema/OpenAPI parity and test-reference resolution.
  - [ ] Add mutation tests proving the verifier fails for removed/invalid provenance, missing tests, schema drift, and stale generated reports.
  - [ ] Run the full source-repository validation and resolve every finding within the issue's semantic-traceability scope.
  - [ ] Commit and push through a pull request; close issue #129 only after all acceptance gates pass.
Validation:
Run `python3 Scripts/verify_spec_provenance.py`, its mutation suite, `python3 Scripts/verify_docs.py`, Swift tests, and midi2.js check/test/build gates as applicable.
Acceptance Criteria:
Every normative schema definition has valid source provenance and verification metadata; generated documents are current; the closed schema and OpenAPI provenance are equivalent; CI fails on the specified mutations; no unresolved traceability status remains inside the published semantic claim.

---

Goal:
Close the owned software-runtime gaps without making a physical-hardware claim.
Scope:
Swift and TypeScript core runtime parity, Profile session behavior, negative validation, machine-readable runtime boundary, current conformance documentation, and CI verification.
Non-goals:
Physical MIDI2 device interoperability, hardware MIDI-CI/JR acceptance, optional host-adapter completeness, and VRT-only visual baselines.
Constraints:
The MIDI2 semantic contract remains unchanged. Runtime completeness is bounded to the named core surface in `docs/runtime-completeness.json`; hardware must remain excluded.
Dependencies:
The committed schema/provenance and claim registers, existing Swift/TypeScript tests, and protected-main pull-request workflow.
Risks:
Historical audit prose can overstate or understate current implementation; the machine-readable ledger and executable verification are authoritative for this bounded claim.
Steps:
  - [x] Read the repository operating guide and validation/claim requirements; record the boundary and exclusions.
  - [x] Add TypeScript Profile session runtime parity and lifecycle tests.
  - [x] Add the machine-readable runtime completeness ledger, generated report, and verifier.
  - [x] Reconcile the current conformance checklist and claim register with executable evidence.
  - [ ] Run the full Swift/TypeScript/docs validation and inspect the resulting diff.
  - [ ] Commit and push through a pull request; do not claim hardware interoperability.
Validation:
`swift test`, `npm run ci --prefix midi2.js`, `python3 Scripts/verify_runtime_completeness.py`, `python3 Scripts/verify_claims.py`, and documentation/provenance checks.
Acceptance Criteria:
The owned core software boundary is explicit and verified by both runtime test suites; Profile behavior is parity-tested; CI rejects a stale or hardware-claiming runtime ledger; hardware interoperability remains explicitly excluded.

Governance reading record:
- Chapters read — repository `AGENTS.md` invariants and claim boundary; `.codex/skills/governance-read/SKILL.md` floor/resolution rules; `.codex/skills/repo-ops/SKILL.md` validation contract.
- What they forbid here — claiming physical hardware behavior from software tests; changing the MIDI2 IDL; bypassing runtime validation; treating stale documentation as operational authority.
- Conflicts — none found between the repository guide, the claim register policy, and this bounded runtime objective.
- Excluded, and why — Reframe governance chapters and GUI/live-drive skills are outside this MIDI2 source-repository runtime task; hardware and optional host adapters are explicitly non-goals.

---

Goal:
Implement and release the bounded Swift and TypeScript MIDI2 runtime surfaces corresponding to the modeled normative behavior, with cross-language evidence.
Scope:
MIDI Clip file lifecycle parity, existing negotiation/profile/property/UMP runtime surfaces, tests, generated coverage evidence, and the Swift/TypeScript package release.
Non-goals:
Physical hardware interoperability, optional host adapters, and changing the MIDI Association semantic contract.
Constraints:
Do not promote a modeled behavior without executable evidence; preserve the explicit runtime and hardware claim boundaries.
Dependencies:
The merged normative coverage ledger, existing Swift/TypeScript implementations, local package toolchains, and protected-main release workflow.
Risks:
Version or generated-artifact drift could publish a package whose evidence does not match the source. Release gates must run locally before publication.
Steps:
  - [x] Audit existing Swift and TypeScript implementations and identify the genuine cross-language gap.
  - [ ] Add MIDI Clip API parity and cross-language tests.
  - [ ] Promote only tested modeled behaviors and regenerate reports.
  - [ ] Run Swift, TypeScript, documentation, provenance, and claim validation.
  - [ ] Bump both package versions, publish through a PR, and create the release artifacts.
Validation:
Swift tests; `npm run check`, `npm test`, `npm run build`; provenance, coverage, runtime, claims, and documentation verifiers; clean diff and package dry run.
Acceptance Criteria:
The Swift and TypeScript packages expose tested MIDI Clip lifecycle behavior; promoted runtime evidence is reproducible; package versions and changelog agree; no hardware interoperability claim is added.

---

Goal:
Publish only evidence-backed MIDI2 claims with explicit scope and exclusions.
Scope:
Machine-readable claim register, generated public claim documentation, README/dashboard links, and CI verification.
Non-goals:
Claim global runtime completeness or physical MIDI2 hardware interoperability.
Constraints:
Semantic traceability, measured test results, feature-level runtime support, and hardware evidence remain separate claim classes.
Dependencies:
Issue #129 provenance gate and the feature-level conformance checklist.
Risks:
Historical audit documents contain broader or older status language; the claim register must be the public boundary for current claims.
Steps:
  - [ ] Define each allowed claim with a reason, evidence paths, status, and exclusions.
  - [ ] Generate the human-readable claim register from the canonical JSON source.
  - [ ] Reject missing evidence, unscoped statuses, stale generated output, and unsupported global claims in CI.
  - [ ] Align README and compliance dashboard with the claim register.
Validation:
Run `python3 Scripts/generate_claim_register.py --check`, `python3 Scripts/verify_claims.py`, the provenance gates, documentation verification, Swift tests, and midi2.js checks/tests/build.
Acceptance Criteria:
The repository can claim semantic traceability, provenance parity, automated verification, measured test results, and explicitly partial feature-level runtime support; it explicitly does not claim global runtime completeness or hardware interoperability.

---

Goal:
Add a bidirectional, machine-verifiable normative coverage contract for the declared MIDI 2.0 source corpus.
Scope:
The six declared MIDI Association PDFs, source hashes and version records, normative requirement ledger, reverse verifier, generated coverage report, provenance fallback policy, mutation tests, CI, claim register, and MIDI-vs-Fountain Coach boundary documentation.
Non-goals:
Claiming complete runtime implementation, physical hardware interoperability, or completion of the unresolved source-prose audit before the ledger contains source-backed dispositions.
Constraints:
The existing object-to-source provenance verifier remains authoritative and is strengthened rather than replaced. The MIDI Association remains normative. Fountain Coach extensions cannot satisfy MIDI requirements without explicit justification.
Dependencies:
The checked-in PDF corpus, `midi2.full.closed.schema.json`, `midi2.full.openapi.json`, and the protected-main pull-request workflow.
Risks:
The current object mapping does not by itself inventory every normative prose rule. The ledger therefore records explicit unresolved audit frontiers and the public claim remains partial.
Steps:
  - [x] Add exact corpus hashes, scope metadata, source policy, and remove generic provenance fallback.
  - [x] Add the canonical normative requirement ledger with structural dispositions and explicit unresolved source-audit frontiers.
  - [x] Add reverse verification, generated coverage reporting, methodology, third-party source notice, and extension boundary.
  - [x] Add mutation tests for ledger deletion, broken representation, version/hash drift, and missing schema provenance; wire gates into CI.
  - [x] Update claim register and documentation indexes without claiming full specification coverage.
  - [ ] Decompose every unresolved audit frontier into source-backed normative requirements or explicit exclusions.
Validation:
Run `python3 Scripts/generate_spec_traceability.py --check`, `python3 Scripts/verify_spec_provenance.py`, `python3 Scripts/generate_normative_coverage.py --check`, `python3 Scripts/verify_normative_coverage.py`, both Python mutation suites, `python3 Scripts/verify_docs.py`, `python3 Scripts/verify_claims.py`, Swift tests, and midi2.js checks/tests/build as applicable.
Acceptance Criteria:
An external reviewer can identify the exact corpus and hashes, inspect every current ledger disposition and representation target, detect missing schema-to-ledger links, detect source/version/hash drift, reproduce the generated report, and see the six unresolved limitations without a misleading percentage or global conformance claim.

Governance reading record:
- Chapters/readings applied — repository `AGENTS.md`; `.codex/skills/spec-pdf-to-schema/SKILL.md`; repository claim-register and publication-boundary guidance.
- What they require here — preserve the canonical schema contract; cite PDF pages; validate generated artifacts; distinguish semantic, runtime, and hardware claims; never use stale prose as operational authority.
- Conflicts — none found.
- Excluded, and why — GUI/live-drive and Reframe runtime skills are outside this static MIDI2 corpus/accounting task; physical hardware remains explicitly out of scope.

---

Goal:
Build the next layer of the full machine-readable MIDI 2.0 object by promoting verified behavioral protocol slices from prose-only dispositions into canonical state-machine data.
Scope:
Property Exchange subscription lifecycle, Stream Configuration negotiation, MIDI-CI Profile lifecycle, and Mixed Data Set transfer; the normative ledger, reverse verifier, generated report, methodology, and focused mutation tests.
Non-goals:
Claiming that the complete six-document corpus is now implemented; claiming hardware interoperability; inventing behavioral semantics not supported by repository source, tests, or cited specification material.
Constraints:
The closed JSON Schema remains the structural object. Behavioral protocol rules must be represented in a separate machine-readable model and linked from the inverse ledger. Existing object-to-source provenance remains unchanged.
Dependencies:
`docs/spec-provenance.json`, `docs/normative-requirements.json`, `midi2.full.closed.schema.json`, existing Swift/TypeScript protocol implementations and tests.
Risks:
Some existing prose summarizes implementation behavior without a complete source-page extraction. Those items must remain explicitly bounded or unresolved until the source audit is complete.
Steps:
  - [x] Read repository operating, validation, schema-mapping, and claim-boundary guidance; record the phase boundary.
  - [x] Inventory existing behavioral implementations and verification artifacts.
  - [ ] Add canonical machine-readable behavioral state machines and invariants for the verified slices.
  - [ ] Link every modeled slice from the normative ledger and validate model references in reverse coverage verification.
  - [ ] Regenerate coverage artifacts, add mutation coverage, and run focused/full validation.
  - [ ] Record remaining corpus gaps without upgrading the full-specification claim.
Validation:
`python3 Scripts/verify_normative_coverage.py`, generated report freshness, mutation tests, `swift test`, `npm run ci --prefix midi2.js`, `python3 Scripts/verify_claims.py`, `python3 Scripts/verify_docs.py`, and `git diff --check`.
Acceptance Criteria:
The repository contains a canonical machine-readable behavioral model with source, implementation, and test links; the inverse verifier rejects missing or invalid model references; the report distinguishes structural, operational, runtime, and unresolved coverage; no public claim implies full runtime or hardware conformance.

Governance reading record:
- Chapters/readings applied — repository `AGENTS.md` (PR-only changes, schema contract, evidence boundaries); Reframe governance 07 (planning, authority, no invented semantics); Reframe governance 08 (artifact-backed claims and validation); `.codex/skills/governance-read/SKILL.md`; `.codex/skills/spec-pdf-to-schema/SKILL.md`; `.codex/skills/repo-ops/SKILL.md`.
- What they forbid here — treating prose or screenshots as protocol authority; forcing behavioral rules into JSON Schema; claiming runtime or hardware completeness from static/model tests; editing without a phase plan.
- Conflicts — none found between the user’s request for the full object and the repository’s requirement to make incomplete coverage explicit.
- Excluded, and why — GUI/live-drive, deployment, and physical-device acceptance are outside this static protocol-model phase; the remaining source-prose audit stays visible as unresolved or explicitly bounded work.

---

Goal:
Implement the remaining modeled frontiers as owned Swift and TypeScript runtime behavior and release the bounded software claim.
Scope:
Compatibility selection, MIDI-CI transaction failure, Profile channel allocation, Property Exchange resource errors, UMP ordering/reserved-value validation, parity tests, runtime evidence, claims, and the v0.11.0 package release.
Non-goals:
Physical MIDI 2.0 hardware interoperability, external-device acceptance, and optional host adapters.
Constraints:
Every promoted behavior must have executable negative-path evidence in both languages; the MIDI Association remains normative and software validation must not be described as hardware proof.
Dependencies:
The merged v0.10.0 provenance/coverage/runtime gates and the protected-main pull-request workflow.
Risks:
Modeled state machines may be broader than a bounded helper API. The implementation ledger therefore names the exact software symbols and tests rather than claiming the full physical protocol environment.
Steps:
  - [x] Add cross-language stateful APIs for all five remaining modeled frontiers.
  - [x] Add parity and negative-path tests; run Swift and TypeScript suites.
  - [x] Promote the five behavior records and add runtime completeness evidence while retaining hardware exclusion.
  - [x] Regenerate runtime and claim reports; run provenance, coverage, claims, docs, and diff checks.
  - [ ] Bump package versions, publish through a pull request, merge, and create release artifacts.
Validation:
`swift test --parallel`, `npm run ci --prefix midi2.js`, runtime/provenance/normative/claim/docs verifiers, generated-artifact freshness, and `git diff --check`.
Acceptance Criteria:
All five remaining modeled frontiers have tested Swift and TypeScript software surfaces; the core software claim is evidence-backed; hardware interoperability remains excluded; v0.11.0 artifacts are prepared through the PR workflow.

---

Goal:
Promote the RTP-MIDI2 host capabilities currently duplicated in the estate workspace into the authoritative Fountain-Coach/midi2 transport package, then let estate consumers depend on that owned implementation directly.
Scope:
RTPMidiSession Bonjour peer discovery, typed peer connection, pre-bound UDP descriptor adoption, datagram delivery of 32/64-bit UMP and contiguous SysEx8-style 128-bit packet sequences, focused tests, changelog, and public runtime documentation.
Non-goals:
Estate-specific joining-machine capability names, static-release semantics, owner authorization, Caddy behavior, or Keychain policy; those remain estate-layer concerns.
Constraints:
Preserve existing explicit-listen/explicit-connect semantics, fail closed on listener/bind errors, keep Linux and Network.framework behavior aligned, and make no hardware-interoperability claim.
Dependencies:
Current main at a9813fa21fd416a6ff27d76cd57c57012e082922 and existing MIDI2Transports loopback coverage.
Risks:
The workspace duplicate accumulated APIs beyond the released package. Migration must preserve existing one-message behavior while adding only generic transport capabilities supported by focused tests.
Steps:
  - [x] Compare the estate duplicate with authoritative MIDI2Transports and identify generic deltas.
  - [x] Move generic discovery, typed peer, descriptor-adoption, and multi-packet SysEx8 datagram support into the authoritative transport.
  - [x] Add focused tests for 32/64/128-bit sends, multi-packet 128-bit datagrams, descriptor adoption, and typed discovery where deterministic.
  - [x] Run Swift tests and repository documentation/claim gates relevant to the change.
  - [ ] Publish through the protected PR workflow and then repoint estate consumers to the merged revision.
Validation:
`swift test --filter RTPMidiSessionTests`, descriptor tests, full `swift test`, documentation verification, claim verification, and `git diff --check`.
Acceptance Criteria:
The authoritative package exposes every generic RTP-MIDI2 host capability needed by joining-machine consumers; existing transport behavior remains tested; estate-specific semantics stay out of midi2; no second transport implementation is needed by EstatePublisher.

---

## Active: M2-124 software-peer transport scenario and instrument seam (2026-11-09)

**Intent:** Establish a standards-facing, independently testable Network MIDI 2.0 UDP software-peer path without changing the identity or operation vocabulary of any existing Fountain Coach MIDI2 instrument.

**Status:** scenario-definition candidate; no M2-124 implementation, admission, release, publication, or conformance claim has been established by this plan.

**Owner and identity:** `Fountain-Coach/midi2` owns the `MIDI2Transports` kit and proposed `NetworkMidi2Session: MIDITransport` seam. A Reframe peer is a later consumer of a released kit; a transport adapter is not a new registered MIDI2 command or an independently admitted FCIS instrument. Preserve `RTPMidiSession` unchanged.

**History-first reconstruction (FCIS-KIT-16):**
- Observed in source: `MIDI2Transports`, `RTPMidiSession`, `MIDITransport`, and package version 0.12.8 exist; `NetworkMidi2Session` was not found in the current source tree.
- Existing work to reuse: UMP core, MIDI-CI core, transport interface, `RTPMidiSession` regression tests, the source-provenance verifier, and the explicit hardware exclusion.
- Unestablished: current M2-124-UM v1.0.1 PDF hash, exact 1.0 -> 1.0.1 changes, independent standards-facing interoperability, live two-peer run, and kit/consumer release evidence.
- Missing seam: a distinct `NetworkMidi2Session` conforming to the source-verified M2-124-UM wire and session behavior; not a rewrite or alias of the Fountain RTP/UMP transport.
- Stop condition: do not implement version-specific packet fields or claim M2-124 conformance until the authoritative versioned PDF, version differences and page/section citations are verified. Do not promote software-peer or hardware claims without independent witnesses.

**Governance reading record:**
- Chapters read: 07 goal fidelity and non-invention; 08 separate evidence authorities; 73 versioned, scenario-first acceptance and independently witnessed outcomes; 91 the IDL / kit / host / Store separation; 93 instrument lifecycle and non-self-admission; 81 universal MIDI2 operation plane. Chapter 150 was read as a transport architecture proposal: a new transport belongs below `MIDITransport`, not in a new command vocabulary.
- Forbidden: treating RTP/UMP as M2-124, inventing wire semantics from marketing prose, making transport discovery equal instrument authorization, self-certifying interop, bypassing the owned kit, or claiming hardware success from software traces.
- Conflicts: the official M2-124-UM catalogue currently names v1.0.1, but the accessible third-party references describe v1.0 and do not establish v1.0.1 deltas; the catalogue remains authoritative. No other governance conflict resolved by this plan.
- Excluded: CoreMIDI/CoreAudio integration, physical devices, Reframe GUI/AX/live-drive, product authorization changes, release and public deployment; these need separate consumer scenarios after upstream transport evidence.

**Scenario source:** `Tests/Scenarios/network-midi2-udp-peer.yaml` — system-boundary candidate. A checked executable JSON projection and an independently witnessed software-peer run are prerequisites to promotion; this YAML is not yet a live-accepted executable scenario.

**Scope:** source admission for M2-124-UM v1.0.1; discovery/session/data/loss/teardown and unsupported command cases; named independent software peers; preservation of existing MIDI2/FCIS operation identity and admission across transport choice.

**Non-goals:** new MIDI2 IDL topics solely for network transport; importing Windows or third-party transport code; replacing `RTPMidiSession`; editing the existing six-document core corpus to silently include a transport spec; hardware interoperability; publication.

**Risks:** unverified spec revisions, conflating software transport connectivity with MIDI-CI or host authorization, silently losing packet ordering/loss recovery, or advertising interoperability after a self-to-self test.

**Steps:**
- [x] Inspect the current transport and core evidence boundary; resolve governance and select one system-boundary scenario.
- [x] Author the candidate scenario with explicit failure, cancellation, timeout, packet-loss and independent-peer witness requirements.
- [ ] Admit a source-verified M2-124-UM v1.0.1 artifact by hash and page/section delta audit; keep third-party PDF redistribution rights separate.
- [x] Generate and check a deterministic YAML-to-JSON scenario projection and add a CI structure/claim-boundary gate. This is a **candidate contract projection**, not yet an executable runner-admitted scenario.
- [ ] Check the projected scenario against the appropriate admitted scenario runner; no such execution authority is established for this kit-only transport candidate yet.
- [ ] Implement the smallest source-verified `NetworkMidi2Session` slice in `MIDI2Transports`, with focused positive/negative tests.
- [ ] Run the Swift kit tests, source/claim gates and independent external software-peer session; record source/build/run tuple and trace evidence.
- [ ] Seek independent instrument admission, release the kit by semver, and only then integrate a consumer with the unchanged IDL operation plane.

**Validation / acceptance:** check exact versioned source and hashes; prove two distinct processes/ports/executables exchange named UMP data after valid session setup; test malformed/unknown messages, timeout, duplicate, packet loss/recovery, sequence wrap, teardown and reconnect; record negative cases and trace digest; confirm no transport-driven authority escalation; compare application operation identity and terminal evidence across RTP and M2-124. A self-peer run establishes internal behavior only; a separate implementation is required for software interoperability; a physical MIDI2 device is required for hardware interoperability.

**Rollback:** leave existing RTP implementation, core claims, release tags, and production website unchanged; discard the isolated candidate branch if source verification or scenario acceptance fails.

### 2026-11-09 source-admitted framing slice (PR #203)

- **Observed source:** M2-124-UM v1.0.1, published 2025-12-03, PDF SHA-256 `21262fe97d69ff99f194d7bc0b78a566e431687a78e0a4cdb4cbc12ad894dd24`. The prior v1.0 is separately hash-pinned in `docs/network-midi2-udp-source.json`. PDF source inspected via rendered p. 22 and p. 42 images; copyrighted files remain outside Git and publication.
- **Source delta:** v1.0.1 explicitly adds non-empty invitation endpoint and product identities (§6.4 p. 29), and new multi-client host/session isolation rules (§8 p. 48). For the reviewed §5 framing pages and §7.1 UMP payload page, no behavioral wire-field delta was observed. This is a *selected review*, not an exhaustive delta certificate.
- **Bounded implementation:** `NetworkMidi2PacketCodec` in existing `MIDI2Transports`. Source-backed datagram signature, big-endian command header, multiple commands, invitation identity and 64-word UMP Data bounds. No new IDL topic, new package, extra dependencies, host authorization, or second transport command plane.
- **Scenario:** `Tests/Scenarios/network-midi2-udp-peer.yaml` and checked JSON point to the machine-readable transport addendum manifest. The scenario remains `candidate`. Its software-peer terminal criteria are **not** settled by codec tests.
- **Acceptance:** focused Swift codec tests and existing RTP tests, source/claim/runtime checks, YAML/JSON parity, negative mutation check for manifest drift, and `git diff --check`. The planned `NetworkMidi2Session` remains unimplemented pending independent state and network tests.
- **Governance:** chapters 07 (no invented prerequisite), 08 (separate evidence authority), 73 (scenario owns terminal predicates), 91/93 (kit/host/operation boundaries), chapter 150 proposed transport replacement seam. No current conflict. Excludes Reframe/AX, hardware interoperability, certification, release, and publication.
- **Next explicit bounded phase:** protocol state machine with host/client session identity, per-peer admission, invitation/accepted/bye/NAK/ping, UMP sequencing/deduplication, cancellation/timeout and retransmission behavior. Only after that: a NetworkMidi2Session transport conforming to MIDITransport, with two-process and third-party peer evidence.

### 2026-11-09 stacked scenario: bounded session core (candidate)
- Goal: extend reviewed M2-124 v1.0.1 framing with source-backed deterministic no-I/O session state transitions, without new IDL or host authority.
- Governance read: chapters 07 (goal fidelity), 08 (independent witnesses), 73 (scenario-first), 91 and 93 (kit and admission), 150 (transport proposal). Root AGENTS and existing PLANS read. No conflicting rule found.
- History-first: base 6bfdd92 contains source-verified packet codec and manifest, but no NetworkMidi2Session socket transport. Preserve unchanged RTP adapter and reuse the base codec.
- Scope: no-auth invitation, accept/pending, ping/NAK, ordered UMP command/duplicate/gap observation, reset and Bye. Default refusal of unpermitted peers; separate host/FCIS admission.
- Focused acceptance: explicit success/failure transitions, malformed input, deterministic two-role codec exchange, all relevant Swift and claim gates.
- Excluded: real UDP, DNS-SD, crypto, FEC/retransmission timers, multi-client networking, hardware, releases, Reframe integration and publication.
- Stop: a source-backed state model is neither NetworkMidi2Session nor independent software-peer interoperability; retain candidate status.
- Source: M2-124-UM v1.0.1 SHA-256 21262fe97d69ff99f194d7bc0b78a566e431687a78e0a4cdb4cbc12ad894dd24; source PDF not committed (rights).
- Git workflow: separate stacked PR to avoid concurrent writes to PR #203, preserving its independent source review.
