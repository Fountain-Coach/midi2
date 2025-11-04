# 🎛️ MIDI 2.0 Compliance Validation Rig (Local + Headless)

This folder provides two complementary ways to generate a compliance-style report for your MIDI 2.0 implementation:

1) A fast, deterministic Swift runner (`midi2compliance`) that exercises key conformance flows without GUI.
2) A headless Electron + Playwright rig that automates your fork of the MIDI 2.0 Workbench to produce an exported JSON report.

Install with:

```bash
bash midi2-compliance/scripts/install.sh
```

It will:
- Provide a Swift local runner executable: `swift run midi2compliance --export out/report.json`.
- Install Node/Playwright dependencies (without sudo) for Workbench automation.
- Clone your **fork** of the MIDI 2.0 Workbench into `.workbench/` (configurable).
- Provide a **headless controller** (`ci/run-workbench-tests.js`) to run the **MIDI 2.0 Compliance** suite and export a JSON report.
- Set up **GitHub Actions** to run on every push/PR and upload the compliance report.
- Generate an **SVG badge** from the JSON report (optional).
- Provide a minimal **dashboard page** (`pages/index.html`) to visualize the latest report.

> **Note:** This uses a headless Electron automation approach. If your Workbench fork exposes a native CLI like `--headless --export`, adjust `scripts/run_local.sh` and workflow steps accordingly for a simpler setup.

## Quick Start (Swift local runner)

Run a fast, hermetic test suite against the library:

```bash
swift run midi2compliance --export out/report.json
python3 midi2-compliance/tools/badge_from_report.py out/report.json out/badge.svg
open out/report.json
```

## Quick Start (Workbench headless)

1. Drop `midi2-compliance/` into your repo root (`Fountain-Coach/midi2`).  
2. Edit **config** in `scripts/install.sh` if needed:
   - `WORKBENCH_FORK_URL` (your fork URL)
   - `WORKBENCH_DIR` (default `.workbench` in repo root)
3. Run installation:
   ```bash
   bash midi2-compliance/scripts/install.sh
   ```
4. (Optional) Run Workbench locally (headless):
   ```bash
   bash midi2-compliance/scripts/run_local.sh
   ```
5. Commit and push; the GitHub Action **midi2-compliance** will run.

## Files

- `.github/workflows/midi2-compliance.yml` – CI pipeline (Linux+macOS)
- `ci/run-workbench-tests.js` – Playwright Electron controller
- `scripts/install.sh` – Installer (dependency setup + clone fork)
- `scripts/run_local.sh` – Local headless run helper
- `tools/badge_from_report.py` – Simple PASS/FAIL badge generator (SVG)
- `pages/index.html` – Minimal dashboard (reads `out/report.json` if present)

## Reporting

- The controller expects the Workbench to expose a UI element with IDs used below (`#start-tests`, `#export-json`).
  Update selectors if your fork differs.
- The JSON report is written to `out/report.json` by default (configurable via `--export`).

## Security & CI Notes

- This setup does not use elevated privileges.
- For USB MIDI 2.0 device testing on Linux, ensure the runner has appropriate permissions and kernel/ALSA versions.
- macOS run uses CoreMIDI virtual endpoints (you may need to add a tiny helper to create endpoints if your stack requires it).

## License
This drop-in package is provided as-is. You may adapt freely for your repo.
