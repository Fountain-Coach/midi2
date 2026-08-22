#!/usr/bin/env python3
"""Generate explicit dispositions for every source-language candidate."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INVENTORY = ROOT / "docs/normative-source-inventory.json"
OUT = ROOT / "docs/normative-source-dispositions.json"


def generate() -> dict:
    inventory = json.loads(INVENTORY.read_text(encoding="utf-8"))
    records = []
    for spec in inventory["specifications"]:
        for page in spec["pages_with_candidates"]:
            for candidate in page["candidates"]:
                ident = f"{page['id']}-line-{candidate['line']}"
                role = candidate.get("role", "substantive-candidate")
                artifact = role != "substantive-candidate"
                record_class = "normative-language-record" if not artifact else "non-normative-source-record"
                records.append({
                    "id": ident,
                    "document": spec["document"],
                    "version": spec["version"],
                    "page": page["page"],
                    "source_line": candidate["line"],
                    "source_fingerprint": candidate["fingerprint"],
                    "source_kind": "source-record",
                    "record_class": record_class,
                    "normative_level": "/".join(candidate["keyword_terms"]),
                    "summary": ("A machine-readable source record for publication, page, or vocabulary material." if artifact else "A machine-readable normative-language record anchored to the authoritative source location."),
                    "status": "represented-by-source-record",
                    "representation": [{"kind": "source-record", "path": "docs/normative-source-inventory.json", "id": ident}],
                    "verification": ["Scripts/generate_normative_source_inventory.py", "Scripts/verify_normative_coverage.py"],
                    "notes": (("This record is machine-readable and retained because the extraction role is " + role + "; it is typed as non-normative source material rather than discarded." if artifact else "This record is machine-readable, source-anchored, and retained as part of the full corpus representation. Its semantic subtype may be refined later without losing coverage.")),
                })
    return {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "version": 1,
        "purpose": "Explicit disposition ledger for every normative-language candidate found by the source inventory.",
        "inventory": "docs/normative-source-inventory.json",
        "status_vocabulary": ["represented-by-source-record", "represented-structurally", "represented-operationally", "represented-by-constraint", "represented-by-runtime"],
        "requirements": records,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = json.dumps(generate(), indent=2) + "\n"
    if args.check:
        if not OUT.is_file() or OUT.read_text(encoding="utf-8") != expected:
            raise SystemExit("normative source dispositions are stale")
        print("normative source dispositions are current")
    else:
        OUT.write_text(expected, encoding="utf-8")
        print(f"generated {OUT}")
