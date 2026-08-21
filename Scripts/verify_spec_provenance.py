#!/usr/bin/env python3
"""Verify canonical MIDI2 schema provenance and generated traceability artifacts."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCHEMA = ROOT / "midi2.full.closed.schema.json"
OPENAPI = ROOT / "midi2.full.openapi.json"
CATALOG = ROOT / "docs/spec-provenance.json"
GENERATED = [
    ROOT / "docs/generated/spec-traceability.md",
    ROOT / "docs/spec-audit.md",
    ROOT / "docs/spec-traceability-matrix.md",
    ROOT / "docs/spec-compliance-dashboard.md",
]


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def rule_for(name: str, catalog: dict) -> dict | None:
    for rule in catalog["rules"]:
        if name in rule["names"]:
            return rule
    return None


def is_constraint(value) -> bool:
    return isinstance(value, dict) and any(k in value for k in (
        "type", "enum", "const", "minimum", "maximum", "minLength", "maxLength",
        "minItems", "maxItems", "required", "pattern", "properties", "items",
        "allOf", "anyOf", "oneOf", "not", "if", "then", "else", "additionalProperties",
    ))


def verify_schema(schema: dict, catalog: dict) -> list[str]:
    errors: list[str] = []
    specs = catalog["specifications"]
    defs = schema.get("$defs", {})
    if not defs:
        return ["schema has no $defs"]
    for name, node in defs.items():
        if not is_constraint(node):
            continue
        deliberate_rule = rule_for(name, catalog)
        if deliberate_rule is None:
            errors.append(f"$defs.{name}: no deliberate provenance rule (fallback is forbidden)")
        source = node.get("x-midi-spec")
        verification = node.get("x-verification")
        if not isinstance(source, list) or not source:
            errors.append(f"$defs.{name}: missing x-midi-spec")
            continue
        if not isinstance(verification, list) or not verification:
            errors.append(f"$defs.{name}: missing x-verification")
        for ref in source:
            if not isinstance(ref, dict):
                errors.append(f"$defs.{name}: malformed provenance entry")
                continue
            doc = ref.get("document")
            if doc not in specs:
                errors.append(f"$defs.{name}: unknown specification {doc!r}")
            elif ref.get("version") != specs[doc].get("version"):
                errors.append(f"$defs.{name}: specification version drift for {doc}: {ref.get('version')!r} != {specs[doc].get('version')!r}")
            if not isinstance(ref.get("version"), str) or not ref["version"]:
                errors.append(f"$defs.{name}: missing specification version")
            if not isinstance(ref.get("page"), int) or ref["page"] <= 0:
                errors.append(f"$defs.{name}: invalid page")
            if not isinstance(ref.get("section"), str) or not ref["section"].strip():
                errors.append(f"$defs.{name}: missing section")
            if not isinstance(ref.get("requirement"), str) or not re.fullmatch(r"[a-z0-9][a-z0-9-]+", ref["requirement"]):
                errors.append(f"$defs.{name}: malformed requirement identifier")
            pdf = ROOT / specs.get(doc, {}).get("file", "")
            if not pdf.is_file():
                errors.append(f"$defs.{name}: source PDF missing: {pdf.name}")
            elif specs.get(doc, {}).get("sha256"):
                actual = hashlib.sha256(pdf.read_bytes()).hexdigest()
                if actual != specs[doc]["sha256"]:
                    errors.append(f"$defs.{name}: source hash drift for {doc}: {actual} != {specs[doc]['sha256']}")
        for check in verification or []:
            if not isinstance(check, dict) or not check.get("kind") or not check.get("id"):
                errors.append(f"$defs.{name}: malformed verification entry")
                continue
            ident = check["id"]
            if ident.startswith("Scripts/"):
                if not (ROOT / ident.split("::", 1)[0]).is_file():
                    errors.append(f"$defs.{name}: verification file missing: {ident}")
            elif not (ROOT / ident).is_file():
                errors.append(f"$defs.{name}: test file missing: {ident}")
    requirements = [ref["requirement"] for node in defs.values() for ref in node.get("x-midi-spec", [])]
    duplicates = sorted({x for x in requirements if requirements.count(x) > 1})
    if duplicates:
        errors.append("ambiguous duplicate requirements: " + ", ".join(duplicates))
    return errors


def verify_openapi_parity(schema: dict, openapi: dict) -> list[str]:
    errors = []
    schema_names = set(schema.get("$defs", {}))
    api_names = set(openapi.get("components", {}).get("schemas", {}))
    missing = sorted(schema_names - api_names)
    if missing:
        errors.append("OpenAPI missing schema definitions: " + ", ".join(missing))
    for name in sorted(schema_names & api_names):
        left = schema["$defs"][name].get("x-midi-spec")
        right = openapi["components"]["schemas"][name].get("x-midi-spec")
        if left != right:
            errors.append(f"OpenAPI provenance drift at {name}")
    return errors


def verify_generated() -> list[str]:
    expected = hashlib.sha256(SCHEMA.read_bytes()).hexdigest()
    errors = []
    for path in GENERATED:
        if not path.is_file():
            errors.append(f"generated artifact missing: {path.relative_to(ROOT)}")
            continue
        marker = path.read_text(encoding="utf-8")
        if "<!-- generated: Scripts/generate_spec_traceability.py -->" not in marker:
            errors.append(f"generated artifact marker missing: {path.relative_to(ROOT)}")
            continue
        match = re.search(r"<!-- source-sha256: ([0-9a-f]{64}) -->", marker)
        if not match or match.group(1) != expected:
            errors.append(f"generated traceability artifact is stale: {path.relative_to(ROOT)}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--schema", type=Path, default=SCHEMA)
    parser.add_argument("--openapi", type=Path, default=OPENAPI)
    args = parser.parse_args()
    schema = load(args.schema)
    catalog = load(CATALOG)
    errors = verify_schema(schema, catalog)
    errors += verify_openapi_parity(schema, load(args.openapi))
    errors += verify_generated()
    if errors:
        print("SPEC PROVENANCE: FAIL")
        print("\n".join(f"- {e}" for e in errors))
        return 1
    print(f"SPEC PROVENANCE: PASS ({len(schema.get('$defs', {}))} definitions)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
