#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="$REPO_ROOT/out"
EXPORT_PATH="${EXPORT_PATH:-$OUT_DIR/report.json}"

mkdir -p "$OUT_DIR"
swift run midi2compliance --export "$EXPORT_PATH"
python3 "$REPO_ROOT/midi2-compliance/tools/badge_from_report.py" "$EXPORT_PATH" "$OUT_DIR/badge.svg" || true
echo "[midi2-compliance] Local Swift runner done. Report: $EXPORT_PATH"

