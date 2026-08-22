#!/usr/bin/env python3
"""Generate a hash-bound inventory of source pages containing normative-language candidates."""
from __future__ import annotations

import hashlib
import json
import re
import shutil
import subprocess
import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "docs/spec-provenance.json"
OUT = ROOT / "docs/normative-source-inventory.json"
KEYWORDS = re.compile(r"\b(shall not|must not|should not|may not|shall|must|required|should|may)\b", re.I)


def candidate_role(document: str, line: str) -> str:
    """Classify extraction artifacts without reproducing third-party source text."""
    if line.startswith(f"{document} ") and "v" in line:
        return "page-header"
    if "ALL RIGHTS RESERVED" in line or line.startswith("Draft Date") or line.startswith("Published") or line.startswith("©"):
        return "publication-metadata"
    if re.search(r"[‘'](?:shall|may)[’'] above", line, re.I):
        return "normative-vocabulary-reference"
    return "substantive-candidate"


def page_text(path: Path, page: int) -> str:
    result = subprocess.run(
        ["gs", "-q", "-sDEVICE=txtwrite", "-o", "-", f"-dFirstPage={page}", f"-dLastPage={page}", str(path)],
        check=True, capture_output=True, text=True,
    )
    return result.stdout


def generate() -> dict:
    if shutil.which("gs") is None or shutil.which("pdfinfo") is None:
        raise RuntimeError("ghostscript and pdfinfo are required")
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    documents = []
    for document, record in catalog["specifications"].items():
        source = ROOT / record["file"]
        actual = hashlib.sha256(source.read_bytes()).hexdigest()
        if actual != record["sha256"]:
            raise RuntimeError(f"source hash drift for {document}: {actual}")
        info = subprocess.check_output(["pdfinfo", str(source)], text=True)
        pages = int(re.search(r"^Pages:\s+(\d+)", info, re.M).group(1))
        candidates = []
        for page in range(1, pages + 1):
            raw_lines = page_text(source, page).splitlines()
            lines = [(index, line.strip()) for index, line in enumerate(raw_lines, 1) if KEYWORDS.search(line)]
            if lines:
                candidate_lines = []
                for line_number, line in lines:
                    normalized = " ".join(line.split())
                    candidate_lines.append({
                        "line": line_number,
                        "fingerprint": hashlib.sha256(normalized.encode("utf-8")).hexdigest(),
                        "keyword_terms": sorted({match.group(1).lower() for match in KEYWORDS.finditer(normalized)}),
                        "role": candidate_role(document, normalized),
                    })
                candidates.append({
                    "id": f"{document}-v{record['version'].replace('.', '-')}-page-{page}",
                    "page": page,
                    "candidate_count": len(lines),
                    "keywords": sorted({match.group(1).lower() for _, line in lines for match in KEYWORDS.finditer(line)}),
                    "candidates": candidate_lines,
                    "disposition": "candidate-page-requires-ledger-classification",
                    "notes": "Location inventory only; source text is not reproduced. Candidates must be classified in the requirement ledger.",
                })
        documents.append({"document": document, "version": record["version"], "source_file": record["file"], "source_sha256": actual, "candidate_pages": len(candidates), "candidate_occurrences": sum(x["candidate_count"] for x in candidates), "pages_with_candidates": candidates})
    return {"$schema": "https://json-schema.org/draft/2020-12/schema", "version": 1, "purpose": "Reproducible source-page inventory for normative requirement extraction.", "methodology": "docs/normative-coverage-methodology.md", "keyword_policy": ["shall", "shall not", "must", "must not", "should", "should not", "may", "may not", "required"], "important_boundary": "A keyword occurrence is not automatically a normative requirement; the ledger remains authoritative for classification and disposition.", "specifications": documents}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = json.dumps(generate(), indent=2) + "\n"
    if args.check:
        if not OUT.is_file() or OUT.read_text(encoding="utf-8") != expected:
            raise SystemExit("normative source inventory is stale")
        print("normative source inventory is current")
    else:
        OUT.write_text(expected, encoding="utf-8")
        print(f"generated {OUT}")
