import copy
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VERIFY = ROOT / "Scripts/verify_normative_coverage.py"


def run(ledger=None, catalog=None, schema=None, behavior=None, source_inventory=None, source_dispositions=None, full_object=None):
    command = [sys.executable, str(VERIFY)]
    if ledger:
        command += ["--ledger", str(ledger)]
    if catalog:
        command += ["--catalog", str(catalog)]
    if schema:
        command += ["--schema", str(schema)]
    if behavior:
        command += ["--behavior", str(behavior)]
    if source_inventory:
        command += ["--source-inventory", str(source_inventory)]
    if source_dispositions:
        command += ["--source-dispositions", str(source_dispositions)]
    if full_object:
        command += ["--full-object", str(full_object)]
    return subprocess.run(command, cwd=ROOT, capture_output=True, text=True)


class NormativeCoverageMutationTests(unittest.TestCase):
    def write_json(self, directory, name, value):
        path = Path(directory) / name
        path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")
        return path

    def test_removing_inventoried_requirement_fails_reverse_traceability(self):
        with tempfile.TemporaryDirectory() as directory:
            ledger = json.loads((ROOT / "docs/normative-requirements.json").read_text())
            ledger["requirements"] = ledger["requirements"][1:]
            result = run(ledger=self.write_json(directory, "ledger.json", ledger))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("source requirement missing", result.stdout)

    def test_broken_representation_pointer_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            ledger = json.loads((ROOT / "docs/normative-requirements.json").read_text())
            ledger["requirements"][0]["representation"][0]["pointers"][0] = "#/$defs/Missing"
            result = run(ledger=self.write_json(directory, "ledger.json", ledger))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("invalid schema pointer", result.stdout)

    def test_wrong_source_version_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            ledger = json.loads((ROOT / "docs/normative-requirements.json").read_text())
            ledger["requirements"][0]["version"] = "9.9"
            result = run(ledger=self.write_json(directory, "ledger.json", ledger))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("wrong specification version", result.stdout)

    def test_source_hash_drift_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            catalog = json.loads((ROOT / "docs/spec-provenance.json").read_text())
            catalog["specifications"]["M2-100-U"]["sha256"] = "0" * 64
            result = run(catalog=self.write_json(directory, "catalog.json", catalog))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("source hash drift", result.stdout)

    def test_removed_schema_provenance_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            schema = json.loads((ROOT / "midi2.full.closed.schema.json").read_text())
            del schema["$defs"]["Uint4"]["x-midi-spec"]
            result = run(schema=self.write_json(directory, "schema.json", schema))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("schema provenance does not match", result.stdout)

    def test_unknown_behavior_state_machine_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            behavior = json.loads((ROOT / "docs/normative-behavior.json").read_text())
            behavior["state_machines"][0]["id"] = "deleted-state-machine"
            result = run(behavior=self.write_json(directory, "behavior.json", behavior))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("unknown behavior state machine id", result.stdout)

    def test_removed_source_candidate_disposition_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            dispositions = json.loads((ROOT / "docs/normative-source-dispositions.json").read_text())
            dispositions["requirements"] = dispositions["requirements"][1:]
            result = run(source_dispositions=self.write_json(directory, "dispositions.json", dispositions))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("source disposition count mismatch", result.stdout)

    def test_source_fingerprint_drift_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            dispositions = json.loads((ROOT / "docs/normative-source-dispositions.json").read_text())
            dispositions["requirements"][0]["source_fingerprint"] = "0" * 64
            result = run(source_dispositions=self.write_json(directory, "dispositions.json", dispositions))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("source disposition fingerprint mismatch", result.stdout)


if __name__ == "__main__":
    unittest.main()
