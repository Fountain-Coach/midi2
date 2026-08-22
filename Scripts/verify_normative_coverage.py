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
BEHAVIOR = ROOT / "docs/normative-behavior.json"
FULL_OBJECT = ROOT / "midi2.full.object.json"
SOURCE_INVENTORY = ROOT / "docs/normative-source-inventory.json"
SOURCE_DISPOSITIONS = ROOT / "docs/normative-source-dispositions.json"
STATUSES = {
    "represented-structurally", "represented-operationally", "represented-by-constraint",
    "represented-by-runtime", "represented-by-source-record",
}
REPRESENTED = STATUSES


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def verify_behavior_model(model: dict, root: Path) -> list[str]:
    errors: list[str] = []
    machines = model.get("state_machines")
    if not isinstance(machines, list) or not machines:
        return ["behavior model has no state machines"]
    seen: set[str] = set()
    for machine in machines:
        ident = machine.get("id")
        if not isinstance(ident, str) or not ident:
            errors.append("behavior model contains a state machine without an id")
            continue
        if ident in seen:
            errors.append(f"duplicate behavior state machine id: {ident}")
        seen.add(ident)
        catalog = load(CATALOG)
        source = catalog.get("specifications", {}).get(machine.get("document"))
        if source is None:
            errors.append(f"{ident}: unknown source document: {machine.get('document')}")
        elif machine.get("version") != source.get("version"):
            errors.append(f"{ident}: wrong source specification version")
        states = machine.get("states", [])
        state_set = set(states)
        if not states or machine.get("initial") not in state_set:
            errors.append(f"{ident}: invalid or missing initial state")
        for terminal in machine.get("terminal", []):
            if terminal not in state_set:
                errors.append(f"{ident}: terminal state is not declared: {terminal}")
        for transition in machine.get("transitions", []):
            if transition.get("from") not in state_set:
                errors.append(f"{ident}: transition source is not declared: {transition.get('from')}")
            if transition.get("to") not in state_set:
                errors.append(f"{ident}: transition target is not declared: {transition.get('to')}")
            if not isinstance(transition.get("event"), str) or not transition["event"]:
                errors.append(f"{ident}: transition has no event")
        for artifact in machine.get("implementation", []) + [
            {"kind": "verification", "path": ref.split("::", 1)[0]}
            for ref in machine.get("verification", [])
        ]:
            rel = artifact.get("path")
            if not isinstance(rel, str) or not (root / rel).is_file():
                errors.append(f"{ident}: artifact file missing: {rel}")
    return errors


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


def verify_source_inventory(inventory: dict, catalog: dict, root: Path) -> list[str]:
    errors: list[str] = []
    seen = set()
    for item in inventory.get("specifications", []):
        document = item.get("document")
        if document in seen:
            errors.append(f"duplicate source inventory document: {document}")
        seen.add(document)
        source = catalog.get("specifications", {}).get(document)
        if source is None:
            errors.append(f"source inventory references unknown document: {document}")
            continue
        if item.get("version") != source.get("version") or item.get("source_file") != source.get("file"):
            errors.append(f"source inventory metadata mismatch: {document}")
        if item.get("source_sha256") != source.get("sha256"):
            errors.append(f"source inventory hash mismatch: {document}")
        pages = item.get("pages_with_candidates", [])
        page_ids = set()
        for page in pages:
            ident = page.get("id")
            if ident in page_ids:
                errors.append(f"duplicate source inventory page: {ident}")
            page_ids.add(ident)
            if not isinstance(page.get("page"), int) or page["page"] <= 0:
                errors.append(f"invalid source inventory page: {ident}")
            if page.get("disposition") != "candidate-page-requires-ledger-classification":
                errors.append(f"unclassified source inventory page: {ident}")
        if item.get("candidate_pages") != len(pages):
            errors.append(f"source inventory page count mismatch: {document}")
        if item.get("candidate_occurrences") != sum(p.get("candidate_count", 0) for p in pages):
            errors.append(f"source inventory occurrence count mismatch: {document}")
    if set(catalog.get("specifications", {})) != seen:
        errors.append("source inventory does not cover exactly the declared corpus")
    return errors


def verify_source_dispositions(dispositions: dict, inventory: dict, root: Path) -> list[str]:
    errors: list[str] = []
    expected = {}
    for spec in inventory.get("specifications", []):
        for page in spec.get("pages_with_candidates", []):
            for candidate in page.get("candidates", []):
                expected[f"{page['id']}-line-{candidate['line']}"] = (spec, page, candidate)
    actual = {}
    for entry in dispositions.get("requirements", []):
        ident = entry.get("id")
        if ident in actual:
            errors.append(f"duplicate source disposition: {ident}")
        actual[ident] = entry
        if ident not in expected:
            errors.append(f"source disposition has no inventory candidate: {ident}")
            continue
        spec, page, candidate = expected[ident]
        if entry.get("document") != spec["document"] or entry.get("version") != spec["version"] or entry.get("page") != page["page"] or entry.get("source_line") != candidate["line"]:
            errors.append(f"source disposition locator mismatch: {ident}")
        if entry.get("source_fingerprint") != candidate["fingerprint"]:
            errors.append(f"source disposition fingerprint mismatch: {ident}")
        role = candidate.get("role")
        if role not in {"page-header", "publication-metadata", "normative-vocabulary-reference", "substantive-candidate"}:
            errors.append(f"source inventory candidate has invalid role: {ident}")
        if entry.get("status") != "represented-by-source-record":
            errors.append(f"source record is not represented: {ident}")
        if entry.get("record_class") not in {"normative-language-record", "non-normative-source-record"}:
            errors.append(f"source record has invalid class: {ident}")
        expected_class = "normative-language-record" if role == "substantive-candidate" else "non-normative-source-record"
        if entry.get("record_class") != expected_class:
            errors.append(f"source record class mismatch: {ident}")
        if entry.get("status") not in STATUSES:
            errors.append(f"source disposition has invalid status: {ident}")
        if not entry.get("notes", "").strip():
            errors.append(f"source disposition has no explanation: {ident}")
        for verification in entry.get("verification", []):
            if not (root / str(verification).split("::", 1)[0]).is_file():
                errors.append(f"source disposition verification file missing: {ident} {verification}")
    if set(actual) != set(expected):
        errors.append(f"source disposition count mismatch: expected {len(expected)}, got {len(actual)}")
    return errors


def verify_representation(entry: dict, schema: dict, openapi: dict, behavior: dict, root: Path) -> list[str]:
    errors = []
    status = entry["status"]
    representations = entry.get("representation", [])
    if status in REPRESENTED and not representations:
        return [f"{entry['id']}: represented status has no representation target"]
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
        elif kind == "state-machine":
            state_ids = {machine.get("id") for machine in behavior.get("state_machines", [])}
            if target.get("id") not in state_ids:
                errors.append(f"{entry['id']}: unknown behavior state machine id: {target.get('id')}")
        elif kind == "source-record" and target.get("id") != entry["id"]:
            errors.append(f"{entry['id']}: source-record target id does not match entry")
        elif kind in {"swift-source", "typescript-source", "test", "validation-rule", "explicit-exclusion"}:
            pass
    for verification in entry.get("verification", []):
        ref = str(verification).split("::", 1)[0]
        if not (root / ref).is_file():
            errors.append(f"{entry['id']}: verification file missing: {verification}")
    return errors


def verify(ledger: dict, catalog: dict, schema: dict, openapi: dict, behavior: dict, root: Path) -> list[str]:
    errors: list[str] = []
    if ledger.get("source_candidate_ledger") != "docs/normative-source-dispositions.json":
        errors.append("normative ledger source candidate ledger pointer is missing or incorrect")
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
        errors += verify_representation(entry, schema, openapi, behavior, root)

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
    parser.add_argument("--behavior", type=Path, default=BEHAVIOR)
    parser.add_argument("--source-inventory", type=Path, default=SOURCE_INVENTORY)
    parser.add_argument("--source-dispositions", type=Path, default=SOURCE_DISPOSITIONS)
    parser.add_argument("--full-object", type=Path, default=FULL_OBJECT)
    args = parser.parse_args()
    root = ROOT
    errors: list[str] = []
    behavior = load(args.behavior)
    inventory = load(args.source_inventory)
    catalog = load(args.catalog)
    full_object = load(args.full_object)
    for key in ("structural", "behavioral", "source_records"):
        if key not in full_object.get("projections", {}):
            errors.append(f"full object missing {key} projection")
    for rel in [
        full_object.get("corpus", {}).get("path"),
        full_object.get("corpus", {}).get("source_inventory"),
        full_object.get("corpus", {}).get("source_dispositions"),
        full_object.get("projections", {}).get("structural", {}).get("schema"),
        full_object.get("projections", {}).get("structural", {}).get("openapi"),
        full_object.get("projections", {}).get("behavioral", {}).get("model"),
        full_object.get("projections", {}).get("behavioral", {}).get("ledger"),
        full_object.get("projections", {}).get("source_records"),
    ]:
        if not isinstance(rel, str) or not (root / rel).is_file():
            errors.append(f"full object artifact missing: {rel}")
    errors += verify_behavior_model(behavior, root)
    errors += verify_source_inventory(inventory, catalog, root)
    source_dispositions = load(args.source_dispositions)
    errors += verify_source_dispositions(source_dispositions, inventory, root)
    errors += verify(load(args.ledger), catalog, load(args.schema), load(args.openapi), behavior, root)
    completion = full_object.get("completion", {})
    if completion.get("modeled_behavioral_slices") != len(behavior.get("state_machines", [])):
        errors.append("full object behavioral model count is stale")
    if completion.get("remaining_source_frontiers") != len(behavior.get("unmodeled_frontiers", [])):
        errors.append("full object source frontier count is stale")
    candidate_count = sum(item.get("candidate_occurrences", 0) for item in inventory.get("specifications", []))
    if completion.get("normative_keyword_candidates") != candidate_count:
        errors.append("full object source candidate count is stale")
    if completion.get("candidate_dispositions") != len(source_dispositions.get("requirements", [])):
        errors.append("full object source disposition count is stale")
    source_has_ambiguity = any(item.get("status") not in REPRESENTED for item in source_dispositions.get("requirements", []))
    if completion.get("full_corpus_claim_supported") is True and source_has_ambiguity:
        errors.append("full object claims complete corpus coverage while a source record is not represented")
    if completion.get("full_corpus_accounting_claim_supported") is True:
        ledger_data = load(args.ledger)
        if any(item.get("status") == "unresolved" for item in ledger_data.get("requirements", [])):
            errors.append("full object claims accounting completeness while normalized ledger has unresolved requirements")
        if completion.get("remaining_source_frontiers") != 0:
            errors.append("full object claims accounting completeness while source frontiers remain open")
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
