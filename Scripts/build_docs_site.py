#!/usr/bin/env python3
"""Build the MIDI2 documentation projection with the Fountain Coach estate shell."""

from __future__ import annotations

import argparse
import html
import re
import shutil
import subprocess
from pathlib import Path

PAGES = [
    ("docs/README.md", "Documentation index"), ("README.md", "Repository overview"),
    ("docs/spec-compliance-dashboard.md", "Specification compliance"), ("docs/claim-register.md", "Claim register"),
    ("docs/runtime-completeness.md", "Runtime completeness"), ("docs/conformance-checklist.md", "Conformance checklist"),
    ("docs/normative-coverage-methodology.md", "Normative coverage methodology"),
    ("docs/midi-vs-fountain-extensions.md", "MIDI versus project extensions"),
    ("docs/third-party-specification-sources.md", "Third-party source policy"),
    ("docs/negative-test-matrix.md", "Negative test matrix"),
    ("docs/generated/normative-coverage.md", "Generated normative coverage"),
    ("docs/generated/spec-traceability.md", "Generated specification traceability"),
    ("docs/comprehensive-spec-audit-report.md", "Comprehensive specification audit"),
    ("docs/gap-closure-tracker.md", "Gap closure tracker"),
    ("docs/spec-traceability-matrix.md", "Specification traceability matrix"),
    ("docs/spec-audit.md", "Specification audit log"), ("docs/traceability.md", "Definition of done traceability"),
]
MACHINE_FILES = [
    "docs/claims.json", "docs/normative-requirements.json", "docs/normative-behavior.json",
    "docs/normative-source-inventory.json", "docs/normative-source-dispositions.json", "docs/runtime-completeness.json",
    "docs/spec-provenance.json", "docs/generated/normative-coverage.md", "docs/generated/spec-traceability.md",
    "docs/quiet-frame-gap-closure.yaml",
]
HOST = "midi2.fountain.coach"
LOGO = "https://fountain.coach/assets/fountain-coach-logo.png"


def slug(source: str) -> str:
    if source == "README.md":
        return "index.html"
    return Path(source).with_suffix(".html").as_posix()


def title_for(source: str, fallback: str) -> str:
    for line in Path(source).read_text(encoding="utf-8").splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return fallback


def markdown_html(root: Path, source: str) -> str:
    rendered = subprocess.run(["pandoc", "--from=gfm", "--to=html", "--wrap=none", str(root / source)], check=True, capture_output=True, text=True).stdout
    rendered = rendered.replace('.codex/skills/midi2-domain-maintenance/SKILL.md', 'https://github.com/Fountain-Coach/midi2/blob/main/.codex/skills/midi2-domain-maintenance/SKILL.md')
    rendered = rendered.replace('../Scripts/build_docs_site.py', 'https://github.com/Fountain-Coach/midi2/blob/main/Scripts/build_docs_site.py')
    rendered = rendered.replace('../Scripts/publish_docs_site.sh', 'https://github.com/Fountain-Coach/midi2/blob/main/Scripts/publish_docs_site.sh')
    rendered = rendered.replace('midi2.full.object.json', 'https://github.com/Fountain-Coach/midi2/blob/main/midi2.full.object.json')
    rendered = rendered.replace('../https://', 'https://')
    return re.sub(r'href="(?!https?://)([^\"]+)\.md(#[^\"]+)?"', r'href="\1.html\2"', rendered)


def estate_nav() -> str:
    return ''.join(f'<a href="{href}"{current}>{label}</a>{separator}' for label, href, current, separator in [
        ("Estate", "https://fountain.coach/", "", '<span aria-hidden="true">·</span>'),
        ("Book", "https://book.fountain.coach/", "", '<span aria-hidden="true">·</span>'),
        ("Governance", "https://governance.fountain.coach/", "", '<span aria-hidden="true">·</span>'),
        ("MIDI2", f"https://{HOST}/", ' aria-current="page"', '<span aria-hidden="true">·</span>'),
        ("Status", "https://status.fountain.coach/", "", ""),
    ])


def shell(page_title: str, canonical: str, content: str, revision: str, active: str = "") -> str:
    links = []
    for source, fallback in PAGES:
        href = "/" if source == "README.md" else "/" + slug(source)
        current = ' aria-current="page"' if href == active else ''
        number = "·" if source == "README.md" else Path(source).stem[:2]
        links.append(f'<a class="rail-link{" active" if current else ""}" href="{href}"{current}><span>{number}</span><span>{html.escape(title_for(source, fallback))}</span></a>')
    canonical_url = f"https://{HOST}{canonical}"
    structured = '{"@context":"https://schema.org","@type":"TechArticle","name":' + repr(page_title).replace("'", '"') + ',"url":' + repr(canonical_url).replace("'", '"') + ',"publisher":{"@type":"Organization","name":"Fountain Coach","url":"https://fountain.coach/"}}'
    machine_links = ''.join(f'<a class="rail-link machine-link" href="/{html.escape(p)}">{html.escape(p)}</a>' for p in MACHINE_FILES)
    return f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="color-scheme" content="light dark"><meta name="fountain:publication-role" content="MIDI2 machine-readable specification and implementation documentation"><meta name="fountain:publication-state" content="Published documentation projection"><title>{html.escape(page_title)} — MIDI2 · Fountain Coach</title><meta name="description" content="{html.escape(page_title)}: published MIDI2 documentation, contracts, implementation boundaries, and evidence."><link rel="canonical" href="{canonical_url}"><link rel="icon" href="{LOGO}"><meta property="og:type" content="article"><meta property="og:site_name" content="Fountain Coach MIDI2"><meta property="og:title" content="{html.escape(page_title)} — MIDI2"><meta property="og:description" content="Published MIDI2 documentation and evidence."><meta property="og:url" content="{canonical_url}"><meta property="og:image" content="{LOGO}"><meta property="og:image:alt" content="Fountain Coach logo"><meta property="og:image:width" content="460"><meta property="og:image:height" content="460"><meta name="twitter:card" content="summary_large_image"><meta name="twitter:title" content="{html.escape(page_title)} — MIDI2"><meta name="twitter:image" content="{LOGO}"><script type="application/ld+json">{structured}</script><link rel="stylesheet" href="/assets/site.css"></head><body><a class="skip-link" href="#main">Skip to content</a><header class="topbar"><a class="wordmark" href="https://fountain.coach/" aria-label="Fountain Coach home"><img src="{LOGO}" alt="Fountain Coach logo"><span>FOUNTAIN COACH<small>MIDI2 · MACHINE-READABLE SPECIFICATION</small></span></a><nav class="estate-nav" aria-label="Fountain Coach publications">{estate_nav()}</nav><div class="topbar-actions"><button class="theme-button" type="button" data-theme-toggle aria-pressed="false">Theme: system</button><button class="menu-button" type="button" data-menu-button aria-controls="reading-index" aria-expanded="false">Index</button></div></header><div class="workspace"><nav class="chapter-rail" id="reading-index" aria-label="MIDI2 documentation index"><div class="rail-label">READING INDEX</div><a class="rail-home" href="/">MIDI2 overview</a>{''.join(links)}<div class="rail-label machine-label">MACHINE ARTIFACTS</div>{machine_links}</nav><main id="main" class="canvas"><nav class="breadcrumbs" aria-label="Breadcrumb"><a href="https://fountain.coach/">Fountain Coach</a><span aria-hidden="true"> › </span><a href="https://{HOST}/">MIDI2</a><span aria-hidden="true"> › </span><span aria-current="page">{html.escape(page_title)}</span></nav><div class="canvas-kicker">FCIS · MIDI2 · <span class="publication-state">PUBLISHED PROJECTION</span></div><article>{content}</article><footer class="footer"><div class="footer-estate"><strong>Fountain Coach publication estate</strong><a href="https://fountain.coach/">Identity</a><a href="https://book.fountain.coach/">Book · human reference</a><a href="https://governance.fountain.coach/">Governance · rules and authority</a><a href="https://instruments.fountain.coach/">Instruments · MIDI2 catalog</a><a href="https://status.fountain.coach/">Status · company and legal context</a></div><div class="footer-legal"><a href="https://governance.fountain.coach/legal/">Legal notices</a><a href="https://governance.fountain.coach/privacy/">Privacy</a><a href="https://governance.fountain.coach/accessibility/">Accessibility</a><a href="https://governance.fountain.coach/copyright/">Copyright</a><a href="https://governance.fountain.coach/compliance/">EU compliance</a><a href="https://github.com/Fountain-Coach/midi2">Source and provenance</a></div><span>Public documentation projection · MIDI Association documents remain normative · hardware interoperability is not claimed.</span><small>Generated from commit {html.escape(revision)}</small></footer></main></div><script src="/assets/site.js" defer></script></body></html>'''


def build_index(output: Path, revision: str) -> None:
    cards = ''.join(f'<a class="index-card" href="/{slug(source)}"><span class="eyebrow">DOCUMENTATION</span><h2>{html.escape(title_for(source, fallback))}</h2><p>{html.escape(source)}</p></a>' for source, fallback in PAGES)
    machine = ''.join(f'<a class="machine" href="/{html.escape(source)}">{html.escape(source)}</a>' for source in MACHINE_FILES)
    content = f'''<div class="eyebrow">PUBLIC MIDI2 PROJECTION · SOURCE-TRACEABLE DOCUMENTATION</div><h1>MIDI2 documentation</h1><p class="lead">The machine-readable MIDI 2.0 object, its normative coverage, implementation boundaries, and engineering evidence—published as a human-readable projection of <a href="https://github.com/Fountain-Coach/midi2">Fountain-Coach/midi2</a>.</p><section class="index-section"><div class="section-heading"><div><div class="eyebrow">READING INDEX</div><h2>Read the contract from source to evidence.</h2></div><p>Governance supplies the publication rules. This subdomain supplies the MIDI2 specification, object, implementation, and verification record.</p></div><div class="index-grid">{cards}</div></section><section class="index-section"><div class="section-heading"><div><div class="eyebrow">MACHINE ARTIFACTS</div><h2>Inspect the canonical projections.</h2></div><p>These files are published for agents and engineers; their source commit and paths remain explicit.</p></div><div class="machine-list">{machine}</div></section><section class="boundary"><div class="eyebrow">CLAIM BOUNDARY</div><p>The repository maintains a versioned, source-traceable machine-readable MIDI2 representation. MIDI Association documents remain normative. Runtime completeness and physical hardware interoperability are separate claims.</p></section>'''
    (output / "index.html").write_text(shell("MIDI2 documentation", "/", content, revision, "/"), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(); parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1]); parser.add_argument("--output", type=Path, required=True); args = parser.parse_args()
    root, output = args.root.resolve(), args.output.resolve()
    if output.exists(): shutil.rmtree(output)
    output.mkdir(parents=True); revision = subprocess.check_output(["git", "-C", str(root), "rev-parse", "HEAD"], text=True).strip()
    (output / "assets").mkdir(); shutil.copy2(root / "Scripts/docs-site.css", output / "assets/site.css"); shutil.copy2(root / "Scripts/docs-site.js", output / "assets/site.js")
    build_index(output, revision)
    for source, fallback in PAGES:
        if source == "README.md": continue
        route = "/" + slug(source); target = output / Path(source).with_suffix(".html"); target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(shell(title_for(source, fallback), route, markdown_html(root, source), revision, route), encoding="utf-8")
    for source in MACHINE_FILES:
        target = output / source; target.parent.mkdir(parents=True, exist_ok=True); shutil.copy2(root / source, target)
    shutil.copy2(root / "midi2.full.object.json", output / "midi2.full.object.json")
    return 0


if __name__ == "__main__": raise SystemExit(main())
