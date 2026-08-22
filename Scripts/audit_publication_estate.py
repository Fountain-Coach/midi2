#!/usr/bin/env python3
"""Crawl the published Fountain Coach estate and write a reproducible audit."""

from __future__ import annotations

import argparse
import json
import subprocess
from concurrent.futures import ThreadPoolExecutor
import urllib.parse
import urllib.request
from collections import Counter, deque
from datetime import date
from html.parser import HTMLParser
from pathlib import Path

SITES = {
    "estate": "https://fountain.coach/",
    "book": "https://book.fountain.coach/",
    "governance": "https://governance.fountain.coach/",
    "instruments": "https://instruments.fountain.coach/",
    "status": "https://status.fountain.coach/",
    "midi2": "https://midi2.fountain.coach/",
}
CORE_META = ("description", "og:title", "og:description", "og:url", "og:image", "twitter:card")


class PageParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.links: list[str] = []
        self.meta: set[str] = set()
        self.title = ""
        self._in_title = False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        if tag == "a" and values.get("href"):
            self.links.append(values["href"] or "")
        if tag == "meta":
            key = values.get("name") or values.get("property")
            if key:
                self.meta.add(key)
        if tag == "title":
            self._in_title = True

    def handle_endtag(self, tag: str) -> None:
        if tag == "title":
            self._in_title = False

    def handle_data(self, data: str) -> None:
        if self._in_title:
            self.title += data


def fetch(url: str) -> tuple[int, str, str]:
    request = urllib.request.Request(url, headers={"User-Agent": "FountainCoachPublicationAudit/1.0"})
    try:
        with urllib.request.urlopen(request, timeout=1.5) as response:
            return response.status, response.headers.get_content_type(), response.read().decode("utf-8", "replace")
    except Exception as exc:  # noqa: BLE001 - retain bounded crawl failures in the report
        return 0, type(exc).__name__, str(exc)


def normalise(base: str, href: str) -> str | None:
    if not href or href.startswith(("#", "mailto:", "javascript:", "tel:")):
        return None
    absolute = urllib.parse.urljoin(base, href)
    parsed = urllib.parse.urlparse(absolute)
    hosts = {urllib.parse.urlparse(value).netloc for value in SITES.values()}
    if parsed.scheme not in {"http", "https"} or parsed.netloc not in hosts:
        return None
    return urllib.parse.urlunparse((parsed.scheme, parsed.netloc, parsed.path or "/", "", "", ""))


def git_snapshot(path: str) -> dict[str, str]:
    if not (Path(path) / ".git").exists():
        return {"path": path, "status": "no-git-source"}
    try:
        revision = subprocess.check_output(["git", "-C", path, "rev-parse", "HEAD"], text=True).strip()
        subject = subprocess.check_output(["git", "-C", path, "log", "-1", "--format=%s"], text=True).strip()
        return {"path": path, "revision": revision, "subject": subject}
    except (OSError, subprocess.CalledProcessError) as exc:
        return {"path": path, "status": f"git-error:{type(exc).__name__}"}


def crawl(root: str, limit: int) -> dict:
    queue: deque[str] = deque([root])
    seen: set[str] = set()
    pages: list[dict] = []
    while queue and len(seen) < limit:
        batch: list[str] = []
        while queue and len(batch) < 16 and len(seen) + len(batch) < limit:
            url = queue.popleft()
            if url not in seen:
                seen.add(url)
                batch.append(url)
        with ThreadPoolExecutor(max_workers=8) as pool:
            responses = list(pool.map(fetch, batch))
        for url, (status, content_type, payload) in zip(batch, responses):
            page = {"url": url, "status": status, "content_type": content_type}
            if status != 200 or "html" not in content_type:
                page["error"] = payload[:240]
                pages.append(page)
                continue
            parser = PageParser()
            parser.feed(payload)
            page.update({"title": parser.title.strip(), "missing_meta": [key for key in CORE_META if key not in parser.meta]})
            pages.append(page)
            for href in parser.links:
                target = normalise(url, href)
                if target and target not in seen:
                    queue.append(target)
    counts = Counter("html" if p.get("status") == 200 and "html" in p.get("content_type", "") else "error" for p in pages)
    return {"root": root, "crawled": len(pages), "html": counts["html"], "errors": counts["error"], "pages": pages}


def render_report(result: dict, snapshots: list[dict]) -> str:
    lines = ["# Fountain Coach publication estate crawl", "", f"Observed: {result['observed']}", "", "This report records public HTTPS observations. Source repositories and their validators remain authoritative for implementation status.", "", "## Surface summary", "", "| Surface | Pages crawled | HTML | Errors | Pages missing core metadata |", "|---|---:|---:|---:|---:|"]
    for name, item in result["sites"].items():
        missing = sum(bool(page.get("missing_meta")) for page in item["pages"])
        lines.append(f"| `{name}` | {item['crawled']} | {item['html']} | {item['errors']} | {missing} |")
    lines += ["", "## Source history used for the audit", "", "| Source | Revision | Latest subject |", "|---|---|---|"]
    for snapshot in snapshots:
        lines.append(f"| `{snapshot['path']}` | `{snapshot.get('revision', '—')}` | {snapshot.get('subject', snapshot.get('status', '—'))} |")
    lines += ["", "## Interpretation", "", "- A crawl error is a publication defect or a bounded external availability issue until resolved.", "- Missing metadata is reported per route so generated shells can be repaired without hiding legal or machine-facing pages.", "- This report does not turn a publication page into evidence of runtime or hardware readiness.", "- The estate’s normative and implementation claims remain subordinate to declared source repositories, versioned artifacts, and tests.", "", "## Core links", "", "- `https://fountain.coach/` — identity and publication parent.", "- `https://book.fountain.coach/` — human development story and evidence interpretation.", "- `https://governance.fountain.coach/` — rules, boundaries, and publication authority.", "- `https://instruments.fountain.coach/` — MIDI2 instrument catalogue and FCIS-KIT projections.", "- `https://status.fountain.coach/` — German-facing company and official context.", "- `https://midi2.fountain.coach/` — machine-readable MIDI2 documentation and implementation evidence."]
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--markdown", type=Path, required=True)
    parser.add_argument("--limit", type=int, default=500)
    args = parser.parse_args()
    sites = {name: crawl(root, args.limit) for name, root in SITES.items()}
    snapshots = [git_snapshot(path) for path in ("/Volumes/NINJA2/Github-Desktop/midi2", "/Volumes/NINJA2/Github-Desktop/book-of-reframe", "/Volumes/NINJA2/Github-Desktop/Reframe-Refactoring", "/Volumes/NINJA2/Github-Desktop/midi2-gpu-fabric", "/Volumes/NINJA2/Github-Desktop/status-fountain-coach")]
    result = {"observed": str(date.today()), "sites": sites, "source_snapshots": snapshots}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.markdown.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    args.markdown.write_text(render_report(result, snapshots), encoding="utf-8")
    print(json.dumps({name: {key: item[key] for key in ("crawled", "html", "errors")} for name, item in sites.items()}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
