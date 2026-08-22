<!-- generated: Scripts/generate_claim_register.py -->
# Evidence-backed Claim Register

> Public claims must name their scope, reason, evidence, and exclusions.

This register distinguishes semantic evidence, runtime evidence, measured tests, and hardware evidence.

## `semantic-traceability` — established

The canonical MIDI2 semantic schema is source-traceable.

**Reason:** All 67 schema definitions carry deliberate embedded MIDI Association provenance and declared verification metadata. This is object-to-source traceability; inverse corpus accounting is reported separately.

**Evidence:**
- `midi2.full.closed.schema.json` — canonical semantic object
- `Scripts/verify_spec_provenance.py` — machine-checks provenance
- `docs/generated/spec-traceability.md` — generated definition-level report

**Exclusions:**
- This does not claim runtime implementation completeness or hardware interoperability.

## `normative-coverage-accounting` — established

The declared MIDI 2.0 corpus is represented as a complete machine-readable Fountain Coach object with no normative requirement excluded.

**Reason:** The full object joins structural schema/OpenAPI projections, twelve operational ledger entries, six behavioral models, and 1,316 source records. Every source record and every normalized requirement has a machine-resolvable representation; source hashes, versions, representations, generated reports, provenance, and mutation gates are verified in CI.

**Evidence:**
- `docs/spec-provenance.json` — declared six-document corpus, versions, and source hashes
- `docs/normative-requirements.json` — canonical inverse requirement ledger
- `docs/normative-behavior.json` — machine-readable behavioral protocol slices
- `docs/normative-source-inventory.json` — hash-bound machine-readable source inventory
- `docs/normative-source-dispositions.json` — machine-readable representation for every extracted source record
- `midi2.full.object.json` — machine-readable composition of structural and behavioral projections
- `Scripts/verify_normative_coverage.py` — reverse-traceability verifier
- `docs/generated/normative-coverage.md` — generated disposition report
- `docs/normative-coverage-methodology.md` — extraction and scope methodology

**Exclusions:**
- This does not claim runtime implementation completeness or physical hardware interoperability.
- MIDI Association remains the normative authority for the represented corpus.

## `schema-openapi-provenance-parity` — established

The closed schema and OpenAPI representation carry equivalent provenance metadata.

**Reason:** CI compares the embedded provenance entries for every shared schema definition.

**Evidence:**
- `midi2.full.closed.schema.json` — closed schema provenance
- `midi2.full.openapi.json` — OpenAPI provenance
- `Scripts/verify_spec_provenance.py` — parity verifier

**Exclusions:**
- This is provenance parity, not a claim that both artifacts expose identical runtime behavior.

## `automated-verification` — established

The provenance contract is protected by deterministic CI and mutation checks.

**Reason:** CI rejects missing or invalid provenance, missing verification references, OpenAPI drift, stale generated reports, and unannotated schema definitions.

**Evidence:**
- `Tests/test_spec_provenance.py` — six mutation cases
- `.github/workflows/ci.yml` — pull-request gate

**Exclusions:**
- These checks verify the repository contract; they do not simulate physical MIDI2 devices.

## `measured-test-runs` — established

The recorded validation run passed 354 Swift tests and 200 TypeScript tests, with one TypeScript test skipped.

**Reason:** The claim reports one identified local validation run rather than extrapolating from it to full conformance.

**Evidence:**
- `Package.swift` — Swift package under test
- `midi2.js/package.json` — TypeScript package test commands
- `docs/claim-register.md` — this claim's recorded scope

**Exclusions:**
- Test counts are not a runtime-completeness percentage and are not hardware evidence.

## `feature-level-runtime-support` — partial

Selected MIDI2 runtime features are implemented and tested, including UMP, MIDI-CI, Property Exchange, Stream/Function Block, MIDI Clip lifecycle, and jitter-reduction paths.

**Reason:** The conformance checklist provides feature-level code and test references while explicitly recording remaining partial areas.

**Evidence:**
- `docs/conformance-checklist.md` — feature-level implementation status
- `Sources` — Swift runtime implementation
- `midi2.js/src` — TypeScript runtime implementation
- `Tests` — Swift runtime tests
- `midi2.js/src/__tests__` — TypeScript runtime tests

**Exclusions:**
- No global claim of complete MIDI2 runtime implementation is made.
- No hardware interoperability claim is made.

## `core-software-runtime-completeness` — established

The declared owned core software surface is runtime-complete across the Swift and TypeScript implementations.

**Reason:** The machine-readable runtime boundary names the required protocol surfaces, marks each as verified, and is protected by Swift and TypeScript validation gates.

**Evidence:**
- `docs/runtime-completeness.json` — canonical runtime boundary and status ledger
- `docs/runtime-completeness.md` — generated human-readable boundary
- `Scripts/verify_runtime_completeness.py` — machine-checks the ledger and hardware exclusion
- `Tests` — Swift runtime tests
- `midi2.js/src/__tests__` — TypeScript runtime tests

**Exclusions:**
- This is bounded to the named core software surface; it is not a claim that every optional MIDI2 extension or host adapter is implemented.
- It does not claim physical MIDI2 hardware interoperability.

## `hardware-interoperability` — not-claimed

Hardware interoperability is not claimed.

**Reason:** The repository has no physical MIDI2 devices or external-device acceptance evidence in scope.

**Evidence:**
- `docs/conformance-checklist.md` — records hardware interoperability as missing

**Exclusions:**
- No claim about successful operation with physical MIDI2 hardware.

## Claim boundary

The repository may claim semantic traceability and the specifically measured validations listed here. It may not claim global runtime completeness or physical MIDI2 hardware interoperability.
