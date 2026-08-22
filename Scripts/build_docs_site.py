#!/usr/bin/env python3
"""Build a small static documentation projection from this repository."""

from __future__ import annotations

import argparse
import html
import re
import shutil
import subprocess
from pathlib import Path


PAGES = [
    ("docs/README.md", "Documentation index"),
    ("README.md", "Repository overview"),
    ("docs/spec-compliance-dashboard.md", "Specification compliance"),
    ("docs/claim-register.md", "Claim register"),
    ("docs/runtime-completeness.md", "Runtime completeness"),
    ("docs/conformance-checklist.md", "Conformance checklist"),
    ("docs/normative-coverage-methodology.md", "Normative coverage methodology"),
    ("docs/midi-vs-fountain-extensions.md", "MIDI versus project extensions"),
    ("docs/third-party-specification-sources.md", "Third-party source policy"),
    ("docs/negative-test-matrix.md", "Negative test matrix"),
    ("docs/generated/normative-coverage.md", "Generated normative coverage"),
    ("docs/generated/spec-traceability.md", "Generated specification traceability"),
    ("docs/comprehensive-spec-audit-report.md", "Comprehensive specification audit"),
    ("docs/gap-closure-tracker.md", "Gap closure tracker"),
    ("docs/spec-traceability-matrix.md", "Specification traceability matrix"),
    ("docs/spec-audit.md", "Specification audit log"),
    ("docs/traceability.md", "Definition of done traceability"),
]

MACHINE_FILES = [
    "docs/claims.json",
    "docs/normative-requirements.json",
    "docs/normative-behavior.json",
    "docs/normative-source-inventory.json",
    "docs/normative-source-dispositions.json",
    "docs/runtime-completeness.json",
    "docs/spec-provenance.json",
    "docs/generated/normative-coverage.md",
    "docs/generated/spec-traceability.md",
    "docs/quiet-frame-gap-closure.yaml",
]


def page_slug(source: str) -> str:
    path = Path(source)
    if source == "README.md":
        return "index"
    return path.with_suffix("").as_posix().replace("/", "-")


def run_pandoc(root: Path, source: str, output: Path, title: str) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            "pandoc",
            str(root / source),
            "--from=gfm",
            "--to=html5",
            "--standalone",
            "--metadata",
            f"title={title} · MIDI2",
            "--css=/assets/site.css",
            "--output",
            str(output),
        ],
        check=True,
    )
    rendered = output.read_text(encoding="utf-8")
    rendered = rendered.replace('.codex/skills/midi2-domain-maintenance/SKILL.md', 'https://github.com/Fountain-Coach/midi2/blob/main/.codex/skills/midi2-domain-maintenance/SKILL.md')
    rendered = rendered.replace('../Scripts/build_docs_site.py', 'https://github.com/Fountain-Coach/midi2/blob/main/Scripts/build_docs_site.py')
    rendered = rendered.replace('../Scripts/publish_docs_site.sh', 'https://github.com/Fountain-Coach/midi2/blob/main/Scripts/publish_docs_site.sh')
    rendered = rendered.replace('midi2.full.object.json', 'https://github.com/Fountain-Coach/midi2/blob/main/midi2.full.object.json')
    rendered = rendered.replace('../https://', 'https://')
    rendered = re.sub(r'href="(?!https?://)([^"]+)\.md"', r'href="\1.html"', rendered)
    output.write_text(rendered, encoding="utf-8")


def build_index(root: Path, output: Path, revision: str) -> None:
    cards = []
    for source, title in PAGES:
        href = "index.html" if source == "README.md" else Path(source).with_suffix(".html").as_posix()
        cards.append(
            f'<a class="card" href="{html.escape(href)}">'
            f"<span class=\"eyebrow\">DOCUMENTATION</span>"
            f"<h2>{html.escape(title)}</h2>"
            f"<p>{html.escape(source)}</p></a>"
        )
    machine = []
    for source in MACHINE_FILES:
        target = output / Path(source)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(root / source, target)
        machine.append(
            f'<a class="machine" href="{html.escape(source)}">'
            f"{html.escape(source)}</a>"
        )
    index = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>MIDI2 documentation</title><link rel="stylesheet" href="assets/site.css"></head>
<body><header class="masthead"><div><span class="eyebrow">MIDI 2.0 · PUBLIC DOCUMENTATION</span>
<h1>Machine-readable MIDI2, explained and evidenced.</h1>
<p class="lede">Human documentation, canonical contracts, implementation boundaries, and evidence from the versioned repository.</p></div>
<div class="meta"><strong>Source</strong><br><a href="https://github.com/Fountain-Coach/midi2">Fountain-Coach/midi2</a><br><code>{html.escape(revision)}</code></div></header>
<main><section><div class="section-heading"><span class="eyebrow">READ</span><h2>Human documentation</h2></div><div class="grid">{''.join(cards)}</div></section>
<section><div class="section-heading"><span class="eyebrow">INSPECT</span><h2>Machine-readable artifacts</h2></div><div class="machine-list">{''.join(machine)}</div></section>
<section class="boundary"><span class="eyebrow">CLAIM BOUNDARY</span><p>The repository documents a bounded Swift and TypeScript core runtime and a source-traceable machine-readable MIDI 2.0 representation. MIDI Association documents remain normative. Physical hardware interoperability is not claimed.</p></section></main>
<footer><a href="https://github.com/Fountain-Coach/midi2">Source repository</a><span>Generated from commit {html.escape(revision)}</span></footer></body></html>"""
    (output / "index.html").write_text(index, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    output = args.output.resolve()
    if output.exists():
        shutil.rmtree(output)
    output.mkdir(parents=True)
    revision = subprocess.check_output(["git", "-C", str(root), "rev-parse", "HEAD"], text=True).strip()
    (output / "assets").mkdir()
    shutil.copy2(root / "Scripts/docs-site.css", output / "assets/site.css")
    build_index(root, output, revision)
    for source, title in PAGES:
        if source == "README.md":
            continue
        page_output = output / Path(source).with_suffix(".html")
        run_pandoc(root, source, page_output, title)
    shutil.copy2(root / "midi2.full.object.json", output / "midi2.full.object.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
