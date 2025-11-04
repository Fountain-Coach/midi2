#!/usr/bin/env bash
set -euo pipefail

echo "[alsa-ump] Loading ALSA sequencer and loopback (if available)"
modprobe snd-seq || true
modprobe snd-aloop enable=1,1 index=0,1 || true

echo "[alsa-ump] ALSA cards:"
cat /proc/asound/cards || true

echo "[alsa-ump] ALSA devices:"
aplay -l || true

echo "[alsa-ump] Starting idle loop (container ready)"
tail -f /dev/null

