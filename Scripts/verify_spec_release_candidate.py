#!/usr/bin/env python3
"""Fail when the current-spec release-candidate metadata drifts from its corpus.

This date-bound check cannot discover future standards revisions. The source
catalogue must be independently reviewed before a new version is promoted.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def verify() -> list[str]:
    errors: list[str] = []
    baseline = read("docs/release-spec-baseline.json")
    catalog = read("docs/spec-provenance.json")
    npm = read("midi2.js/package.json")
    lock = read("midi2.js/package-lock.json")
    schema = read("midi2.full.closed.schema.json")
    openapi = read("midi2.full.openapi.json")
    inventory = read("docs/normative-source-inventory.json")
    ledger = read("docs/normative-requirements.json")
    behavior = read("docs/normative-behavior.json")

    candidate = baseline["release_candidate"]
    swift = (ROOT / "Package.swift").read_text()
    match = re.search(r'let packageVersion\s*=\s*"([^"]+)"', swift)
    if not match or match.group(1) != candidate:
        errors.append("Swift package version does not match date-bound candidate")
    if npm.get("version") != candidate or lock.get("version") != candidate:
        errors.append("npm package/lock version differs from Swift candidate")
    if lock.get("packages", {}).get("", {}).get("version") != candidate:
        errors.append("npm lock root package version differs")
    changelog = (ROOT / "CHANGELOG.md").read_text()
    if f"## [{candidate}]" not in changelog:
        errors.append("release candidate missing changelog entry")

    specs = catalog["specifications"]
    if len(specs) != len(baseline["declared_core_versions"]):
        errors.append("core corpus cardinality drift")
    for document, version in baseline["declared_core_versions"].items():
        if specs.get(document, {}).get("version") != version:
            errors.append(f"catalog spec version mismatch for {document}")
    ci = baseline["midi_ci"]
    spec = specs.get(ci["document"], {})
    if spec.get("sha256") != ci["verified_pdf_sha256"]:
        errors.append("MIDI-CI verified PDF SHA-256 drift")
    if spec.get("redistribution_status") != "not-authorized-for-public-git; retrieve into ephemeral verified workspace":
        errors.append("copyright boundary missing")
    versions = [x for x in catalog.get("versioned_updates", []) if x.get("document") == ci["document"]]
    if not versions or versions[-1].get("from_version") != ci["previous_version"] or versions[-1].get("to_version") != spec.get("version"):
        errors.append("MIDI-CI versioned source replacement not traceable")
    if baseline["midi_ci"].get("required_ack_status") != 0x11 or baseline["midi_ci"].get("required_nak_status") != 0x12:
        errors.append("MIDI-CI ACK/NAK baseline codes unexpected")

    for name, definitions in [
        ("JSON Schema", schema.get("$defs", {})),
        ("OpenAPI", openapi.get("components", {}).get("schemas", {})),
    ]:
        node = definitions.get("MidiCiPEFlowControl", {})
        if not node:
            errors.append(f"{name} lacks current PE flow-control type")
            continue
        props = node.get("properties", {})
        for field, allowed in [("statusCode", [17, 18]), ("subId2", [125, 127])]:
            if sorted(props.get(field, {}).get("enum", [])) != allowed:
                errors.append(f"{name} {field} codes drifted")
        if not any(x.get("document") == ci["document"] and x.get("version") == spec.get("version") for x in node.get("x-midi-spec", [])):
            errors.append(f"{name} PE flow-control source is stale")

    for name, entries in [
        ("schema", [ref for node in schema.get("$defs", {}).values() for ref in node.get("x-midi-spec", [])]),
        ("ledger", ledger.get("requirements", [])),
        ("behavior", behavior.get("state_machines", [])),
    ]:
        if any(x.get("document") == ci["document"] and x.get("version") != spec.get("version") for x in entries):
            errors.append(f"{name} retains previous MIDI-CI source version")
    if not any(
        e.get("document") == ci["document"] and e.get("version") == spec.get("version")
        for e in inventory.get("specifications", [])
    ):
        errors.append("inverse source inventory missing current MIDI-CI PDF version")
    if not (ROOT / "Scripts/fetch_spec_sources.py").is_file():
        errors.append("non-redistributing source fetch verifier missing")
    return errors


if __name__ == "__main__":
    errors = verify()
    if errors:
        print("CURRENT-SPEC RELEASE: FAIL")
        for error in errors:
            print("-", error)
        raise SystemExit(1)
    print("CURRENT-SPEC RELEASE: PASS (dated 2026-11-09; candidate only, not a publication or future-currency guarantee)")
