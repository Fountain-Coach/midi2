#!/usr/bin/env python3
"""Generate the human-readable inverse normative coverage report."""
from __future__ import annotations

import argparse
import hashlib
import json
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "docs/normative-requirements.json"
CATALOG = ROOT / "docs/spec-provenance.json"
OUT = ROOT / "docs/generated/normative-coverage.md"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def generate() -> str:
    ledger = json.loads(LEDGER.read_text(encoding="utf-8"))
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    entries = ledger["requirements"]
    by_doc = defaultdict(Counter)
    overall = Counter()
    for item in entries:
        by_doc[item["document"]][item["status"]] += 1
        overall[item["status"]] += 1
    order = [
        "represented-structurally", "represented-operationally", "represented-by-constraint",
        "represented-by-runtime", "intentionally-out-of-scope", "not-applicable-to-semantic-object",
        "ambiguous-source", "unresolved",
    ]
    lines = [
        "<!-- generated: Scripts/generate_normative_coverage.py -->",
        f"<!-- ledger-sha256: {digest(LEDGER)} -->",
        f"<!-- corpus-sha256: {digest(CATALOG)} -->",
        "# Normative MIDI 2.0 Coverage",
        "",
        "This report is generated from `docs/normative-requirements.json` and the declared corpus in `docs/spec-provenance.json`. It reports explicit accounting, not a conformance percentage.",
        "",
        "## Overall disposition",
        "",
        "| Disposition | Count |",
        "|---|---:|",
    ]
    lines += [f"| `{status}` | {overall[status]} |" for status in order]
    unresolved = overall["unresolved"]
    lines += [
        "",
        f"**Ledger entries:** {len(entries)}. **Unresolved:** {unresolved}. Intentionally excluded entries are accounted for but are not counted as semantic-object representation.",
        "",
        "## By declared specification",
        "",
        "| Specification | Version | Inventoried | Structural | Operational | Constraint | Runtime | Out of scope | Not applicable | Ambiguous | Unresolved |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for document, record in catalog["specifications"].items():
        counts = by_doc[document]
        lines.append("| {} | {} | {} | {} | {} | {} | {} | {} | {} | {} | {} |".format(
            document, record["version"], sum(counts.values()), counts["represented-structurally"],
            counts["represented-operationally"], counts["represented-by-constraint"],
            counts["represented-by-runtime"], counts["intentionally-out-of-scope"],
            counts["not-applicable-to-semantic-object"], counts["ambiguous-source"], counts["unresolved"],
        ))
    lines += [
        "",
        "## What this does and does not establish",
        "",
        "- **Semantic accounting:** every ledger entry has a controlled disposition and machine-resolvable representation or explicit explanation.",
        "- **Runtime completeness:** not implied by structural representation; operational and runtime entries require their own artifacts and tests.",
        "- **Hardware interoperability:** not implied and not claimed by this report.",
        "- **MIDI authority:** the MIDI Association remains normative. Fountain Coach / FCIS / backplane extensions are outside the MIDI requirement denominator.",
        "",
        ("The ledger has no unresolved or ambiguous entries. It supports the claim that every identified normative requirement in the declared corpus has an explicit disposition; this does not imply runtime completeness or hardware interoperability."
         if unresolved == 0 and overall["ambiguous-source"] == 0 else
         "The ledger contains unresolved or ambiguous entries. Therefore the shorter claim that the entire specification set is represented is not supported by this report."),
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = generate()
    if args.check:
        if not OUT.is_file() or OUT.read_text(encoding="utf-8") != expected:
            print("normative coverage report is stale")
            return 1
        print("normative coverage report is current")
        return 0
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(expected, encoding="utf-8")
    print(f"generated normative coverage report for {len(json.loads(LEDGER.read_text())['requirements'])} ledger entries")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
