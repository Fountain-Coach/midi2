#!/usr/bin/env bash
set -euo pipefail

echo "[move] Docker Desktop must be closed. Quitting…"
osascript -e 'quit app "Docker"' || true
sleep 3

SRC_DIR="$HOME/Library/Containers/com.docker.docker/Data/vms/0"
SRC_DATA="$SRC_DIR/data"
SRC_IMG="$SRC_DATA/Docker.raw"

DEST_ROOT="${1:-/Volumes/NINJA2/DockerData}"
DEST_DIR="$DEST_ROOT/vms/0"
DEST_DATA="$DEST_DIR/data"

echo "[move] Source: $SRC_IMG"
echo "[move] Destination root: $DEST_ROOT"

if [ ! -f "$SRC_IMG" ]; then
  echo "[move] ERROR: Docker.raw not found at $SRC_IMG"
  exit 2
fi

mkdir -p "$DEST_DIR"

if [ -L "$SRC_DATA" ]; then
  echo "[move] Already a symlink: $(readlink "$SRC_DATA")"
else
  echo "[move] Moving $SRC_DATA -> $DEST_DATA (rsync progress)"
  rsync -a --info=progress2 "$SRC_DATA" "$DEST_DIR/"
  echo "[move] Creating symlink $SRC_DATA -> $DEST_DATA"
  rm -rf "$SRC_DATA"
  ln -s "$DEST_DATA" "$SRC_DATA"
fi

echo "[move] Starting Docker Desktop…"
open -ga Docker || true

echo "[move] Waiting for Docker daemon…"
for i in {1..60}; do
  if docker info >/dev/null 2>&1; then echo "[move] Docker is up"; break; fi
  sleep 2
done

echo "[move] Verifying disk usage"
docker system df || true

echo "[move] Done. Disk image now at: $DEST_DATA"

