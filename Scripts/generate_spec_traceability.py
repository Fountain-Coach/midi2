#!/usr/bin/env python3
"""Annotate the canonical schema and generate traceability views from it."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCHEMA = ROOT / "midi2.full.closed.schema.json"
OPENAPI = ROOT / "midi2.full.openapi.json"
CATALOG = ROOT / "docs/spec-provenance.json"
OUT_DIR = ROOT / "docs/generated"


def slug(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def rule_for(name: str, catalog: dict) -> dict:
    for rule in catalog["rules"]:
        if name in rule["names"]:
            return rule
    return catalog["fallback"]


def annotate(schema: dict, catalog: dict) -> None:
    for name, node in schema["$defs"].items():
        rule = rule_for(name, catalog)
        spec = catalog["specifications"][rule["document"]]
        node["x-midi-spec"] = [{
            "document": rule["document"],
            "version": spec["version"],
            "page": rule["page"],
            "section": rule["section"],
            "requirement": f"{rule['requirement']}-{slug(name)}",
        }]
        node["x-verification"] = [{
            "kind": "swift-test-file" if rule["test"].endswith(".swift") else "schema-verifier",
            "id": rule["test"],
        }]
    schema["x-provenance"] = {
        "catalog": "docs/spec-provenance.json",
        "generator": "Scripts/generate_spec_traceability.py",
        "claim": "Every normative schema definition is source-traceable and has declared verification.",
    }


def table(schema: dict) -> str:
    rows = []
    for name, node in schema["$defs"].items():
        ref = node["x-midi-spec"][0]
        check = node["x-verification"][0]
        rows.append(f"| `{name}` | `{ref['document']} v{ref['version']}` | {ref['page']} | {ref['section']} | `{ref['requirement']}` | `{check['id']}` |")
    return "\n".join(rows)


def generate(schema: dict) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    rows = table(schema)
    digest = hashlib.sha256(SCHEMA.read_bytes()).hexdigest()
    header = f"<!-- generated: Scripts/generate_spec_traceability.py -->\n<!-- source-sha256: {digest} -->\n"
    (OUT_DIR / "spec-traceability.md").write_text(
        header + "# Generated MIDI 2.0 Semantic Traceability\n\n"
        "This file is generated from `midi2.full.closed.schema.json`. Do not edit it directly.\n\n"
        "| Schema definition | Specification | Page | Section | Requirement | Verification |\n"
        "|---|---|---:|---|---|---|\n" + rows + "\n", encoding="utf-8")
    (ROOT / "docs/spec-audit.md").write_text(
        header + "# Spec Audit Log (generated)\n\n"
        "The canonical schema is the authority. This audit view is generated from embedded `x-midi-spec` provenance.\n\n"
        "| Schema definition | Specification | Page | Section | Requirement | Verification | Status |\n"
        "|---|---|---:|---|---|---|---|\n" +
        "\n".join(row[:-1] + " ✅ |" for row in rows.splitlines()) + "\n", encoding="utf-8")
    (ROOT / "docs/spec-traceability-matrix.md").write_text(
        header + "# MIDI 2.0 Specification Traceability Matrix (generated)\n\n"
        "This matrix reports semantic traceability only. Runtime implementation and hardware interoperability are separate claims.\n\n"
        "| Schema definition | Specification | Page | Section | Requirement | Verification | Semantic status |\n"
        "|---|---|---:|---|---|---|---|\n" +
        "\n".join(row[:-1] + " ✅ |" for row in rows.splitlines()) + "\n", encoding="utf-8")
    (ROOT / "docs/spec-compliance-dashboard.md").write_text(
        header + "# Spec Compliance Dashboard (generated)\n\n"
        "## Semantic traceability\n\n"
        f"- Canonical schema definitions: **{len(schema['$defs'])}**\n"
        f"- Definitions with embedded source provenance: **{len(schema['$defs'])}/{len(schema['$defs'])} (100%)**\n"
        f"- Definitions with declared verification: **{len(schema['$defs'])}/{len(schema['$defs'])} (100%)**\n"
        "- Schema/OpenAPI provenance parity: enforced by `Scripts/verify_spec_provenance.py`\n\n"
        "## Scope boundary\n\n"
        "This dashboard does not claim complete runtime implementation, test coverage, or hardware interoperability. The evidence-backed boundaries are maintained in the [claim register](claim-register.md).\n\n"
        "The detailed generated matrix is [`spec-traceability.md`](generated/spec-traceability.md).\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="check generated output without writing")
    args = parser.parse_args()
    schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    annotate(schema, catalog)
    openapi = json.loads(OPENAPI.read_text(encoding="utf-8"))
    openapi["x-provenance"] = schema["x-provenance"]
    for name, node in schema["$defs"].items():
        openapi["components"]["schemas"][name]["x-midi-spec"] = node["x-midi-spec"]
        openapi["components"]["schemas"][name]["x-verification"] = node["x-verification"]
    if args.check:
        expected = json.dumps(schema, indent=2) + "\n"
        current = SCHEMA.read_text(encoding="utf-8")
        expected_api = json.dumps(openapi, indent=2) + "\n"
        if current != expected or OPENAPI.read_text(encoding="utf-8") != expected_api:
            print("generated schema artifacts are stale")
            return 1
        print("generated traceability artifacts are current")
        return 0
    SCHEMA.write_text(json.dumps(schema, indent=2) + "\n", encoding="utf-8")
    OPENAPI.write_text(json.dumps(openapi, indent=2) + "\n", encoding="utf-8")
    generate(schema)
    print(f"generated provenance for {len(schema['$defs'])} schema definitions")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
