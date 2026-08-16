#!/usr/bin/env python3
"""Generate the public claim register from docs/claims.json."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs/claims.json"
OUTPUT = ROOT / "docs/claim-register.md"


def render(data: dict) -> str:
    lines = [
        "<!-- generated: Scripts/generate_claim_register.py -->",
        "# Evidence-backed Claim Register",
        "",
        f"> {data['policy']}",
        "",
        "This register distinguishes semantic evidence, runtime evidence, measured tests, and hardware evidence.",
        "",
    ]
    for item in data["claims"]:
        lines += [f"## `{item['id']}` — {item['status']}", "", item["claim"], "", f"**Reason:** {item['reason']}", "", "**Evidence:**"]
        lines += [f"- `{e['path']}` — {e['why']}" for e in item["evidence"]]
        lines += ["", "**Exclusions:**"]
        lines += [f"- {x}" for x in item["exclusions"]]
        lines += [""]
    lines += ["## Claim boundary", "", "The repository may claim semantic traceability and the specifically measured validations listed here. It may not claim global runtime completeness or physical MIDI2 hardware interoperability.", ""]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = render(json.loads(SOURCE.read_text(encoding="utf-8")))
    if args.check:
        actual = OUTPUT.read_text(encoding="utf-8") if OUTPUT.exists() else ""
        if actual != expected:
            print("claim register is stale")
            return 1
        print("claim register is current")
        return 0
    OUTPUT.write_text(expected, encoding="utf-8")
    print(f"generated {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
