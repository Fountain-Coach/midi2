# Codex Agent: Semantic Browser & Dissector (Swift-only)
**Goal:** Implement the OpenAPI 3.1 “Semantic Browser & Dissector API” as a Swift 6.1, concurrency-safe service on FountainAI infrastructure — no Python, no Docker, no Vapor. The agent builds a CLI-first tool with an optional HTTP kernel generated from the OpenAPI.

---

## 0) Operating Principles
- **Swift-only:** Swift 6.1, async/await, `Sendable` types, `actor` isolation.  
- **CLI-first:** Deterministic command(s) Codex can run locally/CI.  
- **HTTP is optional:** If needed, use our Swift OpenAPI kernel to expose the same core.  
- **JS-capable:** Headless browser via **Chrome DevTools Protocol (CDP)**; JS executes, SPA data captured.  
- **Typesense used only as an index** (derived, rebuildable).  
- **No new persistence:** Artifacts to `--out` folder; Snapshots/Analyses can be re-indexed anytime.

---

## 1) Repository Plan (SPM Workspace)
Create a new top-level directory `semantic-browser` (or `sb`) in the FountainAI mono-repo.

```
sb/
├── Package.swift
├── Sources/
│   ├── SBCLI/                           # CLI entrypoints (browse/analyze/index)
│   │   ├── main.swift
│   │   └── Commands/
│   │       ├── BrowseCommand.swift
│   │       ├── AnalyzeCommand.swift
│   │       └── IndexCommand.swift
│   ├── SBCore/                          # Domain core, actors, models
│   │   ├── SB.swift                     # façade for end-to-end run
│   │   ├── Models/                      # OpenAPI-aligned data models
│   │   │   ├── Snapshot.swift
│   │   │   ├── Analysis.swift
│   │   │   ├── Blocks.swift
│   │   │   ├── Entities.swift
│   │   │   ├── Claims.swift
│   │   │   ├── IndexDocs.swift
│   │   │   └── WaitPolicy.swift
│   │   ├── Ports/                       # Hexagonal ports (protocols)
│   │   │   ├── Navigating.swift
│   │   │   ├── Dissecting.swift
│   │   │   ├── Indexing.swift
│   │   │   └── ArtifactStore.swift
│   │   └── Pipeline/
│   │       └── Orchestrator.swift       # browse → snapshot → analyze → ind
```

**Third-party Swift deps (SPM):**
- CDP WebSocket JSON-RPC (tiny internal implementation; no Chrome embedding)
- `Yams` (YAML) only if you choose YAML config; not required for core
- No HTML parsing dependency is required for snapshot (we rely on rendered HTML from CDP). If you want DOM utilities, add a lightweight HTML parser; keep it optional.

---

## 2) OpenAPI → Swift Bindings (HTTP Kernel is Optional)
- Keep the OpenAPI spec at `sb/openapi/semantic-browser.openapi.yaml` (the version produced in the previous step).
- Generate Swift server stubs using your **Swift OpenAPI kernel** (already used in other services).
- Route implementations in `SBHTTPKernel/Kernel.swift` should delegate to `SBCore.SB` façade.

> If you choose to run CLI-only, Codex interacts with `SBCLI` and skips the HTTP kernel.

---

## 3) Domain Interfaces (Ports)
Define the hexagonal ports in `SBCore/Ports/`:

```swift
public protocol Navigating: Sendable {
    func snapshot(url: URL, wait: WaitPolicy, store: ArtifactStore?) async throws -> Snapshot
}

public protocol Dissecting: Sendable {
    func analyze(from snapshot: Snapshot, mode: DissectionMode, store: ArtifactStore?) async throws -> Analysis
}

public protocol Indexing: Sendable {
    func upsert(analysis: Analysis, options: IndexOptions) async throws -> IndexResult
}

public protocol ArtifactStore: Sendable {
    func writeSnapshot(_ snap: Snapshot) async throws
    func writeAnalysis(_ analysis: Analysis) async throws
    func readSnapshot(id: String) async throws -> Snapshot?
}
```

Coordinator / façade:

```swift
public actor SB {
    let navigator: any Navigating
    let dissector: any Dissecting
    let indexer: any Indexing
    let store: ArtifactStore?

    public init(navigator: any Navigating, dissector: any Dissecting,
                indexer: any Indexing, store: ArtifactStore?) {
        self.navigator = navigator; self.dissector = dissector
        self.indexer = indexer; self.store = store
    }

    public func browseAndDissect(url: URL, wait: WaitPolicy, mode: DissectionMode,
                                 index: IndexOptions?) async throws -> (Snapshot, Analysis?, IndexResult?) {
        let snap = try await navigator.snapshot(url: url, wait: wait, store: store)
        let analysis = try await dissector.analyze(from: snap, mode: mode, store: store)
        let res = (index?.enabled ?? false) ? try await indexer.upsert(analysis: analysis, options: index!) : nil
        return (snap, analysis, res)
    }
}
```

---

## 4) Browser Capability (CDP)
Implement SBBrowser:
- **BrowserPool (actor):** manages Chromium processes with `--headless=new --remote-debugging-port=0`.
- **HostGate (actor):** per-host throttling, random jitter, and backoff on 429.
- **CDPClient:** JSON-RPC over WebSocket. Use domains: Target, Page, Network, DOM, Runtime.

Snapshot steps (per URL):
1. Target.createTarget and attach.
2. Network.enable, Page.enable, DOM.enable.
3. Page.navigate.
4. Wait by policy:
   - domContentLoaded OR
   - networkIdle with quiescence window OR
   - selector using Runtime.evaluate("document.querySelector('...')").
5. Collect:
   - DOM.getDocument + DOM.getOuterHTML → rendered.html
   - Runtime.evaluate("document.documentElement.innerText") → rendered.text
   - Network.responseReceived + Network.getResponseBody for XHR/Fetch payloads (truncated with size cap)
   - meta tags (Runtime.evaluate)
6. Build Snapshot (OpenAPI schema compliant) and optionally persist via ArtifactStore.

Civility & Policy:
- Honor robots.txt.
- Constrain per-host concurrency (e.g., 2) and apply minimum delay between navigations per host.
- User-agent and optional session cookies are configurable via env/CLI.

---

## 5) Dissector (Semantics)
Implement SBDissector aligned to OpenAPI schemas:
- Segmentation: compute blocks[] from rendered.html + rendered.text.  
  Use simple rules:
  - Headings (<h1..h6>) → kind=heading, level
  - Paragraphs → kind=paragraph
  - Code blocks (pre/code) → kind=code
  - Captions near images/figures → kind=caption
  - Tables (<table>) → kind=table with normalized rows and optional columns
- All blocks carry [start,end) spans into rendered.text (span-level citations rule)
- Entities: start with rule-based NER (proper noun heuristics + dictionaries), then upgrade to model calls via your Swift SDK when ready.
- Claims (deep mode): shallow declarative sentence splitting + pattern heuristics for “X is Y / achieves / reports …” with evidence pointing to one or more block spans. Mark unknown/uncertain with hedge: MEDIUM/HIGH.
- Summaries: multi-granularity (abstract, keyPoints, tl;dr); always cite evidence spans in internal notes (not required in the field itself, but ensure derivability).

---

## 6) Typesense Indexer
Implement SBTypesense:
- Collections (create on first use if absent):
  - pages (page doc)
  - segments (block doc)
  - entities (canonical entity doc)
  - tables (optional)
- Client: small HTTP wrapper with API key header, timeouts, retry with jitter.
- IDs: stable, content-based (e.g., sha1(finalUrl|fetchedAt) for pages; sha1(pageId|blockId) for segments).
- Upsert: batch in groups of 50–200 to respect rate limits.

---

## 7) CLI Commands
SBCLI/main.swift wires subcommands; all flags mirror OpenAPI requests.

### 7.1 sb browse
```
sps browse   --url "https://example.com"   --wait "networkIdle:500,maxWait:15000"   --mode standard   --out ./out   [--index true] [--typesense-url ...] [--typesense-key ...]
```

- Produces snapshot.json, rendered.html, text.txt, analysis.json under --out.
- If --index → upserts to Typesense and prints a compact summary.

### 7.2 sb snapshot
```
sps snapshot --url ... --wait ... --out ./out
```

### 7.3 sb analyze
```
sps analyze --snapshot ./out/snapshot.json --mode deep --out ./out
```

### 7.4 sb index
```
sps index --analysis ./out/analysis.json           --typesense-url http://localhost:8108           --typesense-key ${TYPESENSE_API_KEY}
```
Exit codes: 0 success; 2 bad args; 3 upstream (Typesense) unavailable; 4 navigation failed; 5 analysis error.

---

## 8) Configuration & Env
- SPS_HEADLESS (default true)
- SPS_MAX_HOST_CONCURRENCY (default 2)
- SPS_USER_AGENT (default generic)
- SPS_TYPESENSE_URL, SPS_TYPESENSE_API_KEY (optional)
- SPS_MAX_BODY_BYTES (e.g., 2_000_000 for XHR body capture)
- SPS_SNAPSHOT_TEXT_TRUNCATE (safety cap for innerText)

---

## 9) Concurrency, Safety, and Backpressure
- All public models struct + Codable + Sendable.
- Shared components (BrowserPool, HostGate, TSClient) are actors.
- Use TaskGroup for URL batches; per-host gates to avoid burst traffic.
- Timeouts & cancellation at every awaited boundary (withTimeout wrappers).

---

## 10) Testing Strategy
Golden fixtures under Tests/SBCoreTests/Golden/:
- sample.html (headings/paras/code/table)
- sample.md
- sample.pdf (text-selectable)
- sample.json (array/object tables)
- sample.feed.xml (RSS/Atom)

Test suites:
- SnapshotTests: DOM/text/meta populated; wait policies honored.
- AnalysisTests: blocks count; spans valid; tables normalized; entities present.
- IndexingTests: Typesense upsert payload shape; batch sizing; retry on 429.
- ConcurrencyTests: multiple URLs; host gating respected; no data races.

Static checks:
- Compile with -warnings-as-errors.
- Verify all public types are Sendable or @unchecked Sendable with justification.

---

## 11) Security & Civility
- Honor robots.txt; optional allowlist.
- Cap network capture sizes; redact cookies/headers in stored artifacts.
- User-provided session cookies stored in memory only (no disk), unless explicitly allowed by an option.
- Respect Retry-After and exponential backoff on 429/abuse responses.

---

## 12) Telemetry (Optional)
- Print concise JSON logs to stdout: phase timings, bytes, host, status, backoff events.
- No PII by default; redact query strings if configured.

---

## 13) Delivery Steps (Codex runbook)
1. Scaffold SPM targets as per tree above; add Package.swift with strict tools version // swift-tools-version: 6.1.
2. Add Models in SBCore/Models/ directly mirroring OpenAPI schemas.
3. Implement Ports and empty stubs for adapters; unit-compile.
4. Implement BrowserPool + CDPClient (connect, navigate, wait policies, capture).
5. Implement SnapshotBuilder (DOM/innerText/meta/XHR bodies → Snapshot).
6. Implement Dissector (Segmenter, Entities, Tables, Summarizer) for quick → standard → deep.
7. Implement Typesense client (collections + upsert).
8. Wire CLI commands; print JSON on stdout and write artifacts to --out.
9. (Optional) Generate HTTP kernel from OpenAPI; bind handlers to SBCore.SB.
10. Add tests + golden fixtures; ensure swift test passes locally and in CI.
11. Docs: add README.md and this agent.md; document CLI usage and OpenAPI URL.

Commit/PR conventions:
- PR title: feat(sps): semantic browser & dissector (swift-only, cli-first)
- Labels: swift, cli, cdp, typesense, semantics
- Changelist order: scaffolding → browser → snapshot → dissector → indexer → CLI → tests.

---

## 14) Acceptance Criteria
- sps browse --url https://example.com --mode quick --out ./out
- Produces snapshot.json, rendered.html, text.txt, analysis.json.
- analysis.json always contains blocks with valid [start,end) spans into rendered.text.
- --index upserts at least a page and per-block segment docs to Typesense.
- Concurrency limits & backoff enforced (no more than configured parallel tabs per host).
- Tests pass; no data races with TSAN; all public types Sendable.

---

## 15) Future Hooks (non-blocking)
- Pre-render hook for sites that need auth or special selectors.
- OCR fallback for image-only PDFs (behind a feature flag).
- Cross-page contradiction detection via entity-linked claims.

---

End of agent brief.
Codex: follow the runbook, keep commits focused, and ensure all models match the OpenAPI schemas exactly.
