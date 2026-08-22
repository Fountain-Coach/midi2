#!/usr/bin/env python3
"""Verify the runtime boundary is explicit and hardware claims stay impossible."""
from __future__ import annotations

import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/runtime-completeness.json"
GENERATOR = ROOT / "Scripts/generate_runtime_completeness.py"


def main() -> int:
    data = json.loads(SOURCE.read_text(encoding="utf-8"))
    errors: list[str] = []
    entries = data.get("entries", [])
    ids = [entry.get("id") for entry in entries]
    if len(ids) != len(set(ids)):
        errors.append("duplicate runtime entry id")
    required = {"ump-core", "midi-ci-core", "stream-core", "midi-clip-lifecycle", "jitter-reduction", "negative-validation", "modeled-frontier-runtime"}
    missing = required - set(ids)
    if missing:
        errors.append(f"missing core entries: {', '.join(sorted(missing))}")
    hardware = next((entry for entry in entries if entry.get("id") == "hardware-interoperability"), None)
    if not hardware or hardware.get("status") != "excluded":
        errors.append("hardware-interoperability must remain excluded")
    for entry in entries:
        if entry.get("status") == "verified" and entry.get("id") == "hardware-interoperability":
            errors.append("hardware interoperability cannot be verified by this repository")
        for path in entry.get("evidence", []):
            if not (ROOT / path).exists():
                errors.append(f"{entry.get('id')}: missing evidence path {path}")
    result = subprocess.run(["python3", str(GENERATOR), "--check"], cwd=ROOT, text=True, capture_output=True)
    if result.returncode:
        errors.append(result.stdout.strip() or result.stderr.strip())
    if errors:
        print("RUNTIME COMPLETENESS: FAIL")
        print("\n".join(f"- {error}" for error in errors))
        return 1
    print("RUNTIME COMPLETENESS: PASS (core software boundary explicit; hardware excluded)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
