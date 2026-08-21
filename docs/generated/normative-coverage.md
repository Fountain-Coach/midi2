<!-- generated: Scripts/generate_normative_coverage.py -->
<!-- ledger-sha256: ccae032a3e10c38002a1747d44095a705c6738eb565029ec74d35ef9f6ba5f17 -->
<!-- corpus-sha256: 4deec604d3adf4a543547d4e8445568028708b9e17d63de7e0451a6d7aee1e81 -->
# Normative MIDI 2.0 Coverage

This report is generated from `docs/normative-requirements.json` and the declared corpus in `docs/spec-provenance.json`. It reports explicit accounting, not a conformance percentage.

## Overall disposition

| Disposition | Count |
|---|---:|
| `represented-structurally` | 13 |
| `represented-operationally` | 0 |
| `represented-by-constraint` | 0 |
| `represented-by-runtime` | 0 |
| `intentionally-out-of-scope` | 6 |
| `not-applicable-to-semantic-object` | 0 |
| `ambiguous-source` | 0 |
| `unresolved` | 0 |

**Ledger entries:** 19. **Unresolved:** 0. Intentionally excluded entries are accounted for but are not counted as semantic-object representation.

## By declared specification

| Specification | Version | Inventoried | Structural | Operational | Constraint | Runtime | Out of scope | Not applicable | Ambiguous | Unresolved |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| M2-100-U | 1.1 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| M2-101-UM | 1.2 | 3 | 2 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| M2-102-U | 1.1 | 2 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| M2-103-UM | 1.2 | 2 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| M2-104-UM | 1.1.2 | 9 | 8 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| M2-116-U | 1.0 | 2 | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |

## What this does and does not establish

- **Semantic accounting:** every ledger entry has a controlled disposition and machine-resolvable representation or explicit explanation.
- **Runtime completeness:** not implied by structural representation; operational and runtime entries require their own artifacts and tests.
- **Hardware interoperability:** not implied and not claimed by this report.
- **MIDI authority:** the MIDI Association remains normative. Fountain Coach / FCIS / backplane extensions are outside the MIDI requirement denominator.

The ledger has no unresolved or ambiguous entries. It supports the claim that every identified normative requirement in the declared corpus has an explicit disposition; this does not imply runtime completeness or hardware interoperability.
