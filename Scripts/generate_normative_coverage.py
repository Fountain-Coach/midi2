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
BEHAVIOR = ROOT / "docs/normative-behavior.json"
INVENTORY = ROOT / "docs/normative-source-inventory.json"
DISPOSITIONS = ROOT / "docs/normative-source-dispositions.json"
OUT = ROOT / "docs/generated/normative-coverage.md"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def generate() -> str:
    ledger = json.loads(LEDGER.read_text(encoding="utf-8"))
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    behavior = json.loads(BEHAVIOR.read_text(encoding="utf-8"))
    inventory = json.loads(INVENTORY.read_text(encoding="utf-8"))
    source_dispositions = json.loads(DISPOSITIONS.read_text(encoding="utf-8"))
    entries = ledger["requirements"]
    by_doc = defaultdict(Counter)
    overall = Counter()
    for item in entries:
        by_doc[item["document"]][item["status"]] += 1
        overall[item["status"]] += 1
    source_by_doc = defaultdict(Counter)
    source_overall = Counter()
    for item in source_dispositions["requirements"]:
        source_by_doc[item["document"]][item["status"]] += 1
        source_overall[item["status"]] += 1
    order = [
        "represented-structurally", "represented-operationally", "represented-by-constraint",
        "represented-by-runtime", "represented-by-source-record",
    ]
    lines = [
        "<!-- generated: Scripts/generate_normative_coverage.py -->",
        f"<!-- ledger-sha256: {digest(LEDGER)} -->",
        f"<!-- corpus-sha256: {digest(CATALOG)} -->",
        "# Normative MIDI 2.0 Coverage",
        "",
        "This report is generated from `docs/normative-requirements.json` and the declared corpus in `docs/spec-provenance.json`. It reports explicit accounting, not a conformance percentage.",
        f"It is paired with the machine-readable [normative behavior model](../normative-behavior.json), which currently contains {len(behavior['state_machines'])} modeled protocol slices and {len(behavior.get('unmodeled_frontiers', []))} recorded source frontiers. The [source inventory](../normative-source-inventory.json) records {sum(item['candidate_occurrences'] for item in inventory['specifications'])} normative-language candidates across the six hash-verified PDFs; [source dispositions](../normative-source-dispositions.json) account for all {len(source_dispositions['requirements'])} candidates with explicit source-level status.",
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
        f"**Normalized ledger entries:** {len(entries)}. **Source records represented:** {len(source_dispositions['requirements'])}. **Source record statuses:** {dict(sorted(source_overall.items()))}. **Unrepresented requirements:** {unresolved}.",
        "",
        "## By declared specification",
        "",
        "| Specification | Version | Ledger | Structural | Operational | Constraint | Runtime | Source records |",
        "|---|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for document, record in catalog["specifications"].items():
        counts = by_doc[document]
        lines.append("| {} | {} | {} | {} | {} | {} | {} | {} |".format(
            document, record["version"], sum(counts.values()), counts["represented-structurally"],
            counts["represented-operationally"], counts["represented-by-constraint"],
            counts["represented-by-runtime"],
            sum(source_by_doc[document].values()),
        ))
    lines += [
        "",
        "## What this does and does not establish",
        "",
        "- **Machine-readable coverage:** every ledger entry and every extracted source record has a machine-resolvable representation.",
        "- **Runtime completeness:** not implied by structural representation; operational and runtime entries require their own artifacts and tests.",
        "- **Hardware interoperability:** not implied and not claimed by this report.",
        "- **MIDI authority:** the MIDI Association remains normative. Fountain Coach / FCIS / backplane extensions are outside the MIDI requirement denominator.",
        "",
        ("Every declared source record and every normalized requirement is represented in the full machine-readable object. Record class distinguishes normative-language records from non-normative publication or vocabulary material; this does not imply runtime completeness or hardware interoperability."
         if unresolved == 0 and all(status.startswith("represented-") for status in source_overall) else
         "The full machine-readable coverage claim is not supported because at least one record lacks a represented status."),
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
