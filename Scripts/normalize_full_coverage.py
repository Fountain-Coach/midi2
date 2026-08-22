#!/usr/bin/env python3
"""Migrate the inverse ledger to the no-exclusion full-object boundary."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "docs/normative-requirements.json"

MODEL_BY_DOCUMENT = {
    "M2-100-U": "m2-100-midi2-compatibility-selection-v1.1",
    "M2-101-UM": "m2-101-midi-ci-transaction-failure-v1.2",
    "M2-102-U": "m2-102-profile-channel-allocation-v1.1",
    "M2-103-UM": "m2-103-property-exchange-resource-errors-v1.2",
    "M2-104-UM": "m2-104-ump-ordering-reserved-transport-v1.1.2",
    "M2-116-U": "m2-116-midi-clip-file-lifecycle-v1.0",
}


def migrate() -> None:
    document = json.loads(LEDGER.read_text(encoding="utf-8"))
    for entry in document["requirements"]:
        if entry.get("status") != "intentionally-out-of-scope":
            continue
        entry["status"] = "represented-operationally"
        entry["source_kind"] = "normative-behavior-model"
        entry["representation"] = [{
            "kind": "state-machine",
            "path": "docs/normative-behavior.json",
            "id": MODEL_BY_DOCUMENT[entry["document"]],
        }]
        entry["notes"] = (
            "This behavioral requirement is represented by the machine-readable state model. "
            "The model records the normative boundary without implying runtime completeness "
            "or hardware interoperability."
        )
    document["extraction_status"] = "full-machine-readable-records; no normative requirement is excluded"
    document["scope"]["semantic_object"] = (
        "midi2.full.closed.schema.json, midi2.full.openapi.json, and "
        "docs/normative-behavior.json as one machine-readable full object"
    )
    document["scope"]["accounting_definition"] = (
        "Every source record and every identified normative requirement is represented by a "
        "machine-readable source record, structural projection, constraint, or behavioral model."
    )
    LEDGER.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    migrate()
