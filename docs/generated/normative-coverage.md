<!-- generated: Scripts/generate_normative_coverage.py -->
<!-- ledger-sha256: 449a2a8c5ffb52490d31ae467cb5ae50173b8c50b91deeeda05ee9bc6948b8b7 -->
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
| `intentionally-out-of-scope` | 0 |
| `not-applicable-to-semantic-object` | 0 |
| `ambiguous-source` | 0 |
| `unresolved` | 6 |

**Ledger entries:** 19. **Unresolved:** 6. An unresolved entry is not counted as covered.

## By declared specification

| Specification | Version | Inventoried | Structural | Operational | Constraint | Runtime | Out of scope | Not applicable | Ambiguous | Unresolved |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| M2-100-U | 1.1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| M2-101-UM | 1.2 | 3 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| M2-102-U | 1.1 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| M2-103-UM | 1.2 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| M2-104-UM | 1.1.2 | 9 | 8 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| M2-116-U | 1.0 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |

## What this does and does not establish

- **Semantic accounting:** every ledger entry has a controlled disposition and machine-resolvable representation or explicit explanation.
- **Runtime completeness:** not implied by structural representation; operational and runtime entries require their own artifacts and tests.
- **Hardware interoperability:** not implied and not claimed by this report.
- **MIDI authority:** the MIDI Association remains normative. Fountain Coach / FCIS / backplane extensions are outside the MIDI requirement denominator.

The current ledger contains explicit audit-frontier entries for normative prose that has not yet been decomposed into page-level requirements. Therefore the shorter claim that the entire specification set is represented is not supported by this report.
