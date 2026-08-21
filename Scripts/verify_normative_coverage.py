#!/usr/bin/env python3
"""Verify authoritative-corpus -> normative-ledger -> representation coverage."""
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
LEDGER = ROOT / "docs/normative-requirements.json"
REPORT = ROOT / "docs/generated/normative-coverage.md"
STATUSES = {
    "represented-structurally", "represented-operationally", "represented-by-constraint",
    "represented-by-runtime", "not-applicable-to-semantic-object", "intentionally-out-of-scope",
    "unresolved", "ambiguous-source",
}
REPRESENTED = STATUSES - {"not-applicable-to-semantic-object", "intentionally-out-of-scope", "unresolved", "ambiguous-source"}


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def resolve_pointer(document: dict, pointer: str):
    if not isinstance(pointer, str) or not pointer.startswith("#/"):
        raise ValueError("pointer must start with #/")
    value = document
    for part in pointer[2:].split("/"):
        value = value[part.replace("~1", "/").replace("~0", "~")]
    return value


def rule_for(name: str, catalog: dict):
    for rule in catalog["rules"]:
        if name in rule["names"]:
            return rule
    return None


def verify_hashes(catalog: dict, root: Path) -> list[str]:
    errors = []
    for document, record in catalog.get("specifications", {}).items():
        path = root / record.get("file", "")
        if not path.is_file():
            errors.append(f"{document}: source file missing: {record.get('file')}")
            continue
        expected = record.get("sha256")
        if not re.fullmatch(r"[0-9a-f]{64}", str(expected or "")):
            errors.append(f"{document}: missing or malformed source sha256")
            continue
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual != expected:
            errors.append(f"{document}: source hash drift: {actual} != {expected}")
    return errors


def verify_representation(entry: dict, schema: dict, openapi: dict, root: Path) -> list[str]:
    errors = []
    status = entry["status"]
    representations = entry.get("representation", [])
    if status in REPRESENTED and not representations:
        return [f"{entry['id']}: represented status has no representation target"]
    if status in {"intentionally-out-of-scope", "not-applicable-to-semantic-object"} and not entry.get("notes", "").strip():
        errors.append(f"{entry['id']}: excluded item has no reason")
    if status == "ambiguous-source" and not entry.get("notes", "").strip():
        errors.append(f"{entry['id']}: ambiguous-source item has no explanation")
    for target in representations:
        kind, rel = target.get("kind"), target.get("path")
        if not kind or not rel:
            errors.append(f"{entry['id']}: malformed representation target")
            continue
        path = root / rel
        if not path.is_file():
            errors.append(f"{entry['id']}: representation file missing: {rel}")
            continue
        if kind.startswith("json-schema"):
            pointers = target.get("pointers", [target.get("pointer")])
            for pointer in pointers:
                try:
                    resolve_pointer(schema, pointer)
                except (KeyError, TypeError, ValueError):
                    errors.append(f"{entry['id']}: invalid schema pointer {rel} {pointer}")
        elif kind.startswith("openapi-schema"):
            pointers = target.get("pointers", [target.get("pointer")])
            for pointer in pointers:
                try:
                    resolve_pointer(openapi, pointer)
                except (KeyError, TypeError, ValueError):
                    errors.append(f"{entry['id']}: invalid OpenAPI pointer {rel} {pointer}")
        elif kind in {"swift-source", "typescript-source", "test", "validation-rule", "state-machine", "explicit-exclusion"}:
            pass
    for verification in entry.get("verification", []):
        ref = str(verification).split("::", 1)[0]
        if not (root / ref).is_file():
            errors.append(f"{entry['id']}: verification file missing: {verification}")
    return errors


def verify(ledger: dict, catalog: dict, schema: dict, openapi: dict, root: Path) -> list[str]:
    errors: list[str] = []
    requirements = ledger.get("requirements")
    if not isinstance(requirements, list) or not requirements:
        return ["normative ledger has no requirements"]
    seen = set()
    by_source = {}
    for entry in requirements:
        ident = entry.get("id")
        if not isinstance(ident, str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9.-]+", ident):
            errors.append(f"malformed or missing requirement id: {ident!r}")
        elif ident in seen:
            errors.append(f"duplicate requirement id: {ident}")
        seen.add(ident)
        status = entry.get("status")
        if status not in STATUSES:
            errors.append(f"{ident}: missing or invalid status {status!r}")
        document = entry.get("document")
        source = catalog.get("specifications", {}).get(document)
        if source is None:
            errors.append(f"{ident}: unknown specification {document!r}")
        else:
            if entry.get("version") != source.get("version"):
                errors.append(f"{ident}: wrong specification version")
            by_source[(document, entry.get("source_requirement"))] = entry
        if not isinstance(entry.get("page"), int) or entry["page"] <= 0:
            errors.append(f"{ident}: invalid page")
        for field in ("section", "source_kind", "normative_level", "summary"):
            if not isinstance(entry.get(field), str) or not entry[field].strip():
                errors.append(f"{ident}: missing {field}")
        errors += verify_representation(entry, schema, openapi, root)

    errors += verify_hashes(catalog, root)
    # Every deliberately assigned schema requirement must be present in the inverse ledger.
    for name, node in schema.get("$defs", {}).items():
        rule = rule_for(name, catalog)
        if rule is None:
            errors.append(f"$defs.{name}: no deliberate provenance rule")
            continue
        key = (rule["document"], rule["requirement"])
        entry = by_source.get(key)
        if entry is None:
            errors.append(f"$defs.{name}: source requirement missing from normative ledger: {key[1]}")
            continue
        source_refs = node.get("x-midi-spec", [])
        matching_refs = [ref for ref in source_refs if ref.get("document") == rule["document"] and ref.get("version") == entry["version"] and str(ref.get("requirement", "")).startswith(rule["requirement"] + "-")]
        if not matching_refs:
            errors.append(f"$defs.{name}: schema provenance does not match deliberate catalogue rule {rule['requirement']}")
        pointer = f"#/$defs/{name}"
        pointers = [p for target in entry.get("representation", []) for p in target.get("pointers", [target.get("pointer")])]
        if pointer not in pointers:
            errors.append(f"{entry['id']}: missing representation pointer {pointer}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ledger", type=Path, default=LEDGER)
    parser.add_argument("--catalog", type=Path, default=CATALOG)
    parser.add_argument("--schema", type=Path, default=SCHEMA)
    parser.add_argument("--openapi", type=Path, default=OPENAPI)
    args = parser.parse_args()
    root = ROOT
    errors = verify(load(args.ledger), load(args.catalog), load(args.schema), load(args.openapi), root)
    if REPORT.is_file():
        marker = REPORT.read_text(encoding="utf-8")
        if "generated: Scripts/generate_normative_coverage.py" not in marker:
            errors.append("generated normative coverage report marker missing")
    else:
        errors.append("generated normative coverage report missing")
    if errors:
        print("NORMATIVE COVERAGE: FAIL")
        print("\n".join(f"- {error}" for error in errors))
        return 1
    requirements = load(args.ledger)["requirements"]
    unresolved = sum(item["status"] == "unresolved" for item in requirements)
    print(f"NORMATIVE COVERAGE: PASS ({len(requirements)} ledger entries; {unresolved} unresolved explicit dispositions)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
