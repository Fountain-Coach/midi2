#!/usr/bin/env bash
set -euo pipefail

echo "[ump-responder] Bringing up ALSA sequencer (if needed)"
modprobe snd-seq || true
modprobe snd-aloop enable=1,1 index=0,1 || true

echo "[ump-responder] Starting UMP responder (Swift)"
/work/.build/release/midi2umpd
