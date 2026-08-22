# Normative coverage methodology

## Purpose

The inverse coverage ledger answers a machine-readability question distinct from runtime conformance: for every source record and every normative requirement identified in the declared MIDI Association corpus, where is its representation recorded? The full object is authoritative for that coverage; schema, behavioral models, source records, and runtime are complementary representation targets.

## Corpus and extraction

The corpus is the six exact document/version pairs declared in `docs/spec-provenance.json`. Each PDF is identified by filename and SHA-256. A source update is a versioned event in the corpus manifest; replacing a PDF without updating the manifest is a failure.

Extraction starts with normative tables, figures, field constraints, and prose. RFC-style `MUST`, `MUST NOT`, `SHALL`, and `SHALL NOT` are normative. `SHOULD`, `SHOULD NOT`, and `MAY` are recorded when the source uses them normatively, with the term preserved in `normative_level`. Examples, explanatory notes, historical commentary, and informative appendices are not requirements unless the source gives them normative force.

The reproducible source-page inventory at `docs/normative-source-inventory.json` is part of the machine-readable full object. It is generated from the hash-verified PDFs using a bounded keyword scan (`shall`, `must`, `should`, `may`, `required`, and negative forms). Every occurrence is retained as a typed source record; normative-language records and non-normative publication/vocabulary records are represented differently, but neither is discarded.

Every extracted candidate also appears in `docs/normative-source-dispositions.json` with status `represented-by-source-record`. The record class distinguishes normative-language material from publication and vocabulary material. Refining a record's semantic subtype must update its representation, never remove it or mark it excluded.

Duplicated requirements are normalized to one stable ledger ID and retain all relevant page/section references in the record. Requirements spanning pages cite the first page and explain the span in `notes`. Tables and figures are requirements when they constrain message structure, values, ordering, or interpretation; a JSON Schema pointer is only an honest target for the structural portion.

The ledger contains behavioral entries per declared document for normative prose that belongs to protocol, runtime, transport, file-format, or conformance behavior rather than a static JSON Schema definition. These entries point to state machines and operational invariants, so behavioral standards are represented without pretending they are static JSON Schema facts.

Behavioral requirements that have been verified from repository implementation and tests are promoted into `docs/normative-behavior.json`. Each state machine names its source document/version/page, states, transitions, invariants, implementation artifacts, and verification artifacts. A modeled slice is not a claim that the entire source document's behavior has been implemented; remaining source frontiers stay explicit in both the model and the ledger.

## Dispositions

The controlled status vocabulary is:

- `represented-structurally`: represented in the closed JSON Schema/OpenAPI object.
- `represented-operationally`: represented by an operational artifact such as a state machine or protocol invariant.
- `represented-by-constraint`: represented by a validation rule that is not naturally a schema definition.
- `represented-by-runtime`: represented by runtime behavior and its verification.
- `represented-by-source-record`: represented by a hash-bound source locator and typed record in the full object.

Behavioral, temporal, sequencing, negotiation, acknowledgement, timeout, reserved-value, and invalid-message rules must not be forced into `$defs`. They belong in operational, constraint, runtime, state-machine, or test targets where appropriate. The state-machine model is the canonical representation for the behavioral slices it explicitly names; it is not a substitute for source extraction of the remaining frontier. Runtime tests do not establish hardware interoperability.

## Meaning of 100% accounted for

“100% machine-readable” means every source record and every identified normative requirement in the declared source corpus has an explicit machine-readable representation in the full object. It does not mean every requirement is implemented, supported by hardware evidence, or representable as JSON Schema; behavioral requirements are represented by behavioral models and source records. There is no exclusion disposition in this model: a missing representation is a verifier failure.

The inverse verifier also requires every deliberately provenance-assigned schema definition to appear in the ledger with a matching source requirement and representation pointer. This prevents deletion of an existing ledger entry from silently weakening object-level traceability.

## Boundaries

MIDI Association normative semantics remain distinct from Fountain Coach, FCIS, and MIDI backplane support structures. Extensions may be represented in the repository, but they cannot satisfy a MIDI Association requirement unless the relationship is explicitly justified in the ledger. Semantic accounting, runtime completeness, and physical hardware interoperability are separate claims.
