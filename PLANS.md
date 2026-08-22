# PLANS Protocol (FCIS RFC 0001)

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
