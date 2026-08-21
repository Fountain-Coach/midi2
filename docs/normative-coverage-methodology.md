# Normative coverage methodology

## Purpose

The inverse coverage ledger answers a narrower question than conformance: for every normative requirement identified in the declared MIDI Association corpus, where is its disposition recorded? The ledger is authoritative for that accounting; the schema and runtime are representation targets, not substitutes for the ledger.

## Corpus and extraction

The corpus is the six exact document/version pairs declared in `docs/spec-provenance.json`. Each PDF is identified by filename and SHA-256. A source update is a versioned event in the corpus manifest; replacing a PDF without updating the manifest is a failure.

Extraction starts with normative tables, figures, field constraints, and prose. RFC-style `MUST`, `MUST NOT`, `SHALL`, and `SHALL NOT` are normative. `SHOULD`, `SHOULD NOT`, and `MAY` are recorded when the source uses them normatively, with the term preserved in `normative_level`. Examples, explanatory notes, historical commentary, and informative appendices are not requirements unless the source gives them normative force.

Duplicated requirements are normalized to one stable ledger ID and retain all relevant page/section references in the record. Requirements spanning pages cite the first page and explain the span in `notes`. Tables and figures are requirements when they constrain message structure, values, ordering, or interpretation; a JSON Schema pointer is only an honest target for the structural portion.

The ledger contains one explicit scope-boundary entry per declared document for normative prose that belongs to protocol, runtime, transport, file-format, or conformance behavior rather than the static semantic object. These entries are `intentionally-out-of-scope`, carry a source page and reason, and are not counted as structural coverage. They prevent behavioral standards from being silently treated as JSON Schema facts.

## Dispositions

The controlled status vocabulary is:

- `represented-structurally`: represented in the closed JSON Schema/OpenAPI object.
- `represented-operationally`: represented by an operational artifact such as a state machine or protocol invariant.
- `represented-by-constraint`: represented by a validation rule that is not naturally a schema definition.
- `represented-by-runtime`: represented by runtime behavior and its verification.
- `not-applicable-to-semantic-object`: normative material belongs to another authority boundary and is explicitly excluded with a reason.
- `intentionally-out-of-scope`: outside the declared semantic-object scope with a documented reason.
- `unresolved`: identified but not yet assigned a defensible representation or exclusion.
- `ambiguous-source`: the source statement needs interpretation or adjudication and includes an explanation.

Behavioral, temporal, sequencing, negotiation, acknowledgement, timeout, reserved-value, and invalid-message rules must not be forced into `$defs`. They belong in operational, constraint, runtime, state-machine, or test targets where appropriate. Runtime tests do not establish hardware interoperability.

## Meaning of 100% accounted for

“100% accounted for” means every identified normative requirement in the declared source corpus has an explicit machine-readable disposition. It does not mean every requirement is implemented, supported by hardware evidence, or representable as JSON Schema. An intentionally excluded item is accounted for but is not represented by the semantic object. An unresolved or ambiguous item would be a known gap and would prevent the stronger claim until dispositioned.

The inverse verifier also requires every deliberately provenance-assigned schema definition to appear in the ledger with a matching source requirement and representation pointer. This prevents deletion of an existing ledger entry from silently weakening object-level traceability.

## Boundaries

MIDI Association normative semantics remain distinct from Fountain Coach, FCIS, and MIDI backplane support structures. Extensions may be represented in the repository, but they cannot satisfy a MIDI Association requirement unless the relationship is explicitly justified in the ledger. Semantic accounting, runtime completeness, and physical hardware interoperability are separate claims.
