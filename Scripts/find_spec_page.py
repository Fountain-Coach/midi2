#!/usr/bin/env python3
"""
Find pages in a PDF that contain a given phrase.

Relies on Ghostscript's `txtwrite` device (already present in this repo's workflow).
Example:
    python3 Scripts/find_spec_page.py M2-104-UM_v1-1-2_UMP_and_MIDI_2-0_Protocol_Specification.pdf "Process Inquiry" --max-pages 150
"""
from __future__ import annotations

import argparse
import shutil
import subprocess
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pdf", type=Path, help="Path to PDF to search")
    parser.add_argument("phrase", type=str, help="Phrase to find (case-insensitive)")
    parser.add_argument(
        "--max-pages",
        type=int,
        default=200,
        help="Maximum pages to scan (upper bound to avoid runaway loops)",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if shutil.which("gs") is None:
        print("ghostscript (gs) not found; install it to use this tool", flush=True)
        return 1

    pdf_path = args.pdf
    if not pdf_path.exists():
        print(f"PDF not found: {pdf_path}", flush=True)
        return 1

    phrase = args.phrase.lower()
    hits: list[int] = []

    for page in range(1, args.max_pages + 1):
        # Extract one page at a time as text; stop early if gs errors.
        res = subprocess.run(
            [
                "gs",
                "-sDEVICE=txtwrite",
                "-o",
                "-",
                f"-dFirstPage={page}",
                f"-dLastPage={page}",
                str(pdf_path),
            ],
            capture_output=True,
            text=True,
        )
        if res.returncode != 0:
            break
        if phrase in res.stdout.lower():
            hits.append(page)

    if hits:
        print(f"Phrase '{args.phrase}' found on pages: {', '.join(map(str, hits))}")
        return 0

    print(f"Phrase '{args.phrase}' not found in first {args.max_pages} pages")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
