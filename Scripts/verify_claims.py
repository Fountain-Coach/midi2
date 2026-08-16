#!/usr/bin/env python3
"""Verify that every public claim is scoped, evidenced, and bounded."""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/claims.json"
GENERATOR = ROOT / "Scripts/generate_claim_register.py"


def main() -> int:
    data = json.loads(SOURCE.read_text(encoding="utf-8"))
    errors: list[str] = []
    ids = set()
    required = {"id", "status", "claim", "reason", "evidence", "exclusions"}
    for item in data.get("claims", []):
        missing = required - item.keys()
        if missing:
            errors.append(f"{item.get('id', '<unknown>')}: missing {', '.join(sorted(missing))}")
        ident = item.get("id")
        if ident in ids:
            errors.append(f"duplicate claim id: {ident}")
        ids.add(ident)
        if item.get("status") not in {"established", "partial", "not-claimed"}:
            errors.append(f"{ident}: invalid status")
        if not item.get("reason") or not item.get("exclusions"):
            errors.append(f"{ident}: reason and exclusions are mandatory")
        for evidence in item.get("evidence", []):
            path = evidence.get("path", "")
            if not path or not (ROOT / path).exists():
                errors.append(f"{ident}: evidence path missing: {path}")
        text = item.get("claim", "").lower()
        if item.get("status") == "established" and re.search(r"hardware interoperability|runtime completeness|complete midi.?2 runtime", text):
            errors.append(f"{ident}: unsupported global claim in established status")
    if "hardware-interoperability" not in ids:
        errors.append("hardware-interoperability boundary claim missing")
    if errors:
        print("CLAIM REGISTER: FAIL")
        print("\n".join(f"- {e}" for e in errors))
        return 1
    result = subprocess.run(["python3", str(GENERATOR), "--check"], cwd=ROOT, text=True, capture_output=True)
    if result.returncode:
        print("CLAIM REGISTER: FAIL")
        print(result.stdout.strip() or result.stderr.strip())
        return 1
    print(f"CLAIM REGISTER: PASS ({len(ids)} claims)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
