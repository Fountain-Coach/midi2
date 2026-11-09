<!-- generated: Scripts/generate_normative_coverage.py -->
<!-- ledger-sha256: 7ac9dfe7c9913bf5144f9e4b86ef0e3a18dde46d09caaaaceaa8dc9a5746e90c -->
<!-- corpus-sha256: 79a3e5c17c09525095da96e55b7b20d48710e20c62da1991e434ad0e036ad7db -->
# Normative MIDI 2.0 Coverage

This report is generated from `docs/normative-requirements.json` and the declared corpus in `docs/spec-provenance.json`. It reports explicit accounting, not a conformance percentage.
It is paired with the machine-readable [normative behavior model](../normative-behavior.json), which currently contains 11 modeled protocol slices and 0 recorded source frontiers. The [source inventory](../normative-source-inventory.json) records 1247 normative-language candidates across the six hash-verified PDFs; [source dispositions](../normative-source-dispositions.json) account for all 1247 candidates with explicit source-level status.

## Overall disposition

| Disposition | Count |
|---|---:|
| `represented-structurally` | 14 |
| `represented-operationally` | 12 |
| `represented-by-constraint` | 8 |
| `represented-by-runtime` | 0 |
| `represented-by-source-record` | 0 |

**Normalized ledger entries:** 34. **Source records represented:** 1247. **Source record statuses:** {'represented-by-source-record': 1247}. **Unrepresented requirements:** 0.

## By declared specification

| Specification | Version | Ledger | Structural | Operational | Constraint | Runtime | Source records |
|---|---:|---:|---:|---:|---:|---:|---:|
| M2-100-U | 1.1 | 2 | 0 | 1 | 1 | 0 | 50 |
| M2-101-UM | 1.2.1 | 6 | 3 | 2 | 1 | 0 | 280 |
| M2-102-U | 1.1 | 4 | 1 | 2 | 1 | 0 | 176 |
| M2-103-UM | 1.2 | 4 | 1 | 2 | 1 | 0 | 291 |
| M2-104-UM | 1.1.2 | 12 | 8 | 3 | 1 | 0 | 336 |
| M2-116-U | 1.0 | 6 | 1 | 2 | 3 | 0 | 114 |

## What this does and does not establish

- **Machine-readable coverage:** every ledger entry and every extracted source record has a machine-resolvable representation.
- **Runtime completeness:** not implied by structural representation; operational and runtime entries require their own artifacts and tests.
- **Hardware interoperability:** not implied and not claimed by this report.
- **MIDI authority:** the MIDI Association remains normative. Fountain Coach / FCIS / backplane extensions are outside the MIDI requirement denominator.

Every declared source record and every normalized requirement is represented in the full machine-readable object. Record class distinguishes normative-language records from non-normative publication or vocabulary material; this does not imply runtime completeness or hardware interoperability.
