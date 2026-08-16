#!/usr/bin/env python3
"""Mutation tests for the issue #129 provenance gate."""
from __future__ import annotations

import json
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERIFY = ROOT / "Scripts/verify_spec_provenance.py"
SCHEMA = ROOT / "midi2.full.closed.schema.json"
OPENAPI = ROOT / "midi2.full.openapi.json"


class SpecProvenanceMutationTests(unittest.TestCase):
    def run_gate(self, schema: Path, openapi: Path) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["python3", str(VERIFY), "--schema", str(schema), "--openapi", str(openapi)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def copies(self):
        temp = Path(tempfile.mkdtemp(prefix="midi2-provenance-"))
        self.addCleanup(lambda: shutil.rmtree(temp, ignore_errors=True))
        schema = temp / "schema.json"
        openapi = temp / "openapi.json"
        shutil.copy2(SCHEMA, schema)
        shutil.copy2(OPENAPI, openapi)
        return schema, openapi

    def test_missing_source_reference_fails(self):
        schema, openapi = self.copies()
        data = json.loads(schema.read_text())
        del data["$defs"]["Uint4"]["x-midi-spec"]
        schema.write_text(json.dumps(data))
        result = self.run_gate(schema, openapi)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing x-midi-spec", result.stdout)

    def test_invalid_page_fails(self):
        schema, openapi = self.copies()
        data = json.loads(schema.read_text())
        data["$defs"]["Uint4"]["x-midi-spec"][0]["page"] = 0
        schema.write_text(json.dumps(data))
        result = self.run_gate(schema, openapi)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("invalid page", result.stdout)

    def test_missing_verification_fails(self):
        schema, openapi = self.copies()
        data = json.loads(schema.read_text())
        del data["$defs"]["Uint4"]["x-verification"]
        schema.write_text(json.dumps(data))
        result = self.run_gate(schema, openapi)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing x-verification", result.stdout)

    def test_openapi_provenance_drift_fails(self):
        schema, openapi = self.copies()
        data = json.loads(openapi.read_text())
        data["components"]["schemas"]["Uint4"]["x-midi-spec"][0]["page"] = 999
        openapi.write_text(json.dumps(data))
        result = self.run_gate(schema, openapi)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("OpenAPI provenance drift", result.stdout)

    def test_deleted_test_reference_fails(self):
        schema, openapi = self.copies()
        data = json.loads(schema.read_text())
        data["$defs"]["Uint4"]["x-verification"][0]["id"] = "Tests/does-not-exist.swift"
        schema.write_text(json.dumps(data))
        result = self.run_gate(schema, openapi)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("test file missing", result.stdout)

    def test_new_normative_definition_without_provenance_fails(self):
        schema, openapi = self.copies()
        data = json.loads(schema.read_text())
        data["$defs"]["MutationDefinition"] = {"type": "integer", "minimum": 0}
        schema.write_text(json.dumps(data))
        result = self.run_gate(schema, openapi)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing x-midi-spec", result.stdout)


if __name__ == "__main__":
    unittest.main()
