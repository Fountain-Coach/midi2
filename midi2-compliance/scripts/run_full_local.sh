#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_DIR="$REPO_ROOT/out"
mkdir -p "$LOG_DIR"

echo "[full-run] Starting midi2device (background)"
pkill -f midi2device || true
swift run -c debug midi2device >"$LOG_DIR/midi2device.log" 2>&1 &
DEV_PID=$!
echo "[full-run] midi2device PID=$DEV_PID"

trap 'echo "[full-run] Stopping midi2device"; kill $DEV_PID || true' EXIT

echo "[full-run] Running Workbench headless"
WORKBENCH_DIR="${WORKBENCH_DIR:-.workbench}" MIDI2_LOG_CONSOLE=1 \
  bash "$REPO_ROOT/midi2-compliance/scripts/run_local.sh"

echo "[full-run] Done. See out/report.json and out/workbench.log"

