#!/usr/bin/env python3
"""Generate the human-readable runtime boundary from its machine-readable ledger."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/runtime-completeness.json"
OUTPUT = ROOT / "docs/runtime-completeness.md"


def render(data: dict) -> str:
    lines = [
        "<!-- generated: Scripts/generate_runtime_completeness.py -->",
        "# Runtime Completeness Boundary",
        "",
        f"> {data['policy']}",
        "",
        f"Boundary: `{data['boundary']}`",
        "",
    ]
    for entry in data["entries"]:
        lines += [f"## `{entry['id']}` — {entry['status']}", "", entry["surface"], "", "**Evidence:**"]
        lines += [f"- `{path}`" for path in entry["evidence"]]
        lines += [""]
    lines += [
        "## Claim rule",
        "",
        "The named core software surfaces may be claimed runtime-complete only when every required entry is `verified` and the Swift and TypeScript validation gates pass. `out-of-scope` is not evidence of implementation. Hardware remains `excluded` and cannot be claimed from these results.",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = render(json.loads(SOURCE.read_text(encoding="utf-8")))
    if args.check:
        actual = OUTPUT.read_text(encoding="utf-8") if OUTPUT.exists() else ""
        if actual != expected:
            print("runtime completeness report is stale")
            return 1
        print("runtime completeness report is current")
        return 0
    OUTPUT.write_text(expected, encoding="utf-8")
    print(f"generated {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
