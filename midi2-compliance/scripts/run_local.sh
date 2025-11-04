#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKBENCH_DIR="${WORKBENCH_DIR:-.workbench}"
EXPORT_PATH="${EXPORT_PATH:-$REPO_ROOT/out/report.json}"

echo "[midi2-compliance] Running local headless test..."
mkdir -p "$(dirname "$EXPORT_PATH")"

# Start your midi2 device/service if needed (customize here)
# Example:
# nohup "$REPO_ROOT/bin/midi2-ump-device" >/dev/null 2>&1 &
# DEVICE_PID=$!
# trap "kill $DEVICE_PID || true" EXIT

pushd "$WORKBENCH_DIR" >/dev/null || { echo "[midi2-compliance] Workbench dir not found: $WORKBENCH_DIR"; exit 1; }

# On Linux, if no X server -> use xvfb-run
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  XVFB="xvfb-run -a"
else
  XVFB=""
fi

$XVFB node "$REPO_ROOT/midi2-compliance/ci/run-workbench-tests.js" --export "$EXPORT_PATH"

popd >/dev/null

echo "[midi2-compliance] Report written to: $EXPORT_PATH"
