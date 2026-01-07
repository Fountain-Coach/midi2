#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
COMPOSE="$ROOT_DIR/midi2-compliance/docker/docker-compose.yml"

progress() { printf "[vm] %s\n" "$1"; }

progress "Docker info (checking daemon)…"
if ! docker info >/dev/null 2>&1; then
  progress "Docker not ready. Please start Docker Desktop and retry."; exit 2;
fi

progress "Pruning old images/containers/cache to free space (this can take minutes)…"
docker system prune -af || true
docker builder prune -af || true
docker volume prune -f || true

progress "Building ump-responder (Swift) with plain progress logs…"
docker compose -f "$COMPOSE" build --progress=plain ump-responder

progress "Building remaining services (alsa-ump, workbench)…"
docker compose -f "$COMPOSE" build --progress=plain alsa-ump workbench

progress "Starting full stack (detached)…"
docker compose -f "$COMPOSE" up --build -d

progress "Following logs (press Ctrl-C to stop tail; services keep running)…"
docker compose -f "$COMPOSE" logs -f --no-log-prefix alsa-ump ump-responder workbench &
TAIL_PID=$!

progress "Waiting for Workbench to export PDF (watching ./out)…"
OUT_DIR="$ROOT_DIR/out"
mkdir -p "$OUT_DIR"
for i in {1..300}; do
  if [ -f "$OUT_DIR/workbench.pdf" ]; then
    SIZE=$(du -h "$OUT_DIR/workbench.pdf" | awk '{print $1}')
    progress "Export complete: out/workbench.pdf ($SIZE)"
    break
  fi
  if (( i % 10 == 0 )); then progress "…still working (heartbeat)"; fi
  sleep 2
done

kill "$TAIL_PID" >/dev/null 2>&1 || true
progress "Done. Artifacts in out/:"
ls -lah "$OUT_DIR" || true

