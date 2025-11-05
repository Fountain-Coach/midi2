#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKBENCH_DIR="${WORKBENCH_DIR:-.workbench}"
EXPORT_PATH="${EXPORT_PATH:-$REPO_ROOT/out/report.json}"

echo "[midi2-compliance] Running local headless test..."
mkdir -p "$(dirname "$EXPORT_PATH")"

# When ALSA sequencer devices are unavailable (common in CI containers),
# fall back to lightweight JS shims that stub the native MIDI bindings so the
# Workbench can boot headlessly. The shims are injected via NODE_OPTIONS and
# guarded by MIDI2_HEADLESS_STUB to avoid interfering with real hardware runs.
HEADLESS_SHIM="$REPO_ROOT/midi2-compliance/ci/headless-shims.js"
if [ ! -e /dev/snd/seq ] && [ -f "$HEADLESS_SHIM" ]; then
  export MIDI2_HEADLESS_STUB=${MIDI2_HEADLESS_STUB:-1}
  export MIDI2_SIMULATE_WORKBENCH=${MIDI2_SIMULATE_WORKBENCH:-1}
  if [ -z "${NODE_OPTIONS:-}" ]; then
    export NODE_OPTIONS="--require $HEADLESS_SHIM"
  else
    export NODE_OPTIONS="--require $HEADLESS_SHIM $NODE_OPTIONS"
  fi
  echo "[midi2-compliance] Injecting stub MIDI backends (NODE_OPTIONS=$NODE_OPTIONS)"
fi

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
