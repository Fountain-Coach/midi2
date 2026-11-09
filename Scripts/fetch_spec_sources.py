#!/usr/bin/env python3
"""Fetch only explicitly declared, hash-pinned normative sources into local/CI cache.

No source PDF is added to Git, uploaded, published or returned as output.
If a source is not obtainable with the declared checksum, fail closed.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
from urllib.parse import urlparse
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "docs/spec-provenance.json"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--document", default="M2-101-UM")
    args = parser.parse_args()
    catalog = json.loads(CATALOG.read_text())
    spec = catalog["specifications"].get(args.document)
    if not spec:
        parser.error(f"unknown document: {args.document}")
    target = ROOT / spec["file"]
    checksum = spec["sha256"]
    if not isinstance(checksum, str) or len(checksum) != 64:
        raise SystemExit("no valid pinned checksum")
    if target.exists():
        found = hashlib.sha256(target.read_bytes()).hexdigest()
        if found != checksum:
            raise SystemExit(f"unverified local spec source: {args.document} checksum mismatch")
        print(f"SPEC SOURCE: VERIFIED LOCAL {args.document} v{spec['version']} sha256={checksum}")
        return 0
    url = spec.get("retrieval_url")
    if not url or urlparse(url).scheme != "https" or urlparse(url).hostname != "drive.google.com":
        raise SystemExit(f"source unavailable or untrusted retrieval: {args.document}")
    request = Request(url, headers={"User-Agent": "MIDI2 source-verifier/1.0"})
    with urlopen(request, timeout=60) as response:
        data = response.read(12 * 1024 * 1024 + 1)
    if len(data) > 12 * 1024 * 1024 or not data.startswith(b"%PDF-"):
        raise SystemExit(f"not a bounded PDF: {args.document}")
    found = hashlib.sha256(data).hexdigest()
    if found != checksum:
        raise SystemExit(f"source hash mismatch: {args.document} expected={checksum} found={found}")
    temp = target.with_name("." + target.name + ".download")
    try:
        temp.write_bytes(data)
        os.replace(temp, target)
    finally:
        temp.unlink(missing_ok=True)
    print(f"SPEC SOURCE: FETCHED VERIFIED {args.document} v{spec['version']} sha256={checksum} (untracked)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
