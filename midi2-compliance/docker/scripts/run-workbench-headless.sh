#!/usr/bin/env bash
set -euo pipefail

WORKDIR=${WORKDIR:-/work}
cd "$WORKDIR"

echo "[workbench] Cloning Workbench fork: ${WORKBENCH_FORK_URL}"
if [ ! -d "/work/.workbench" ]; then
  git clone "${WORKBENCH_FORK_URL}" .workbench
else
  git -C .workbench fetch --all && git -C .workbench reset --hard origin/main || true
fi

cd .workbench
echo "[workbench] Installing deps"
if [ -f yarn.lock ]; then
  corepack enable || true
  yarn install || yarn install --network-timeout 600000
else
  npm ci || npm install --no-fund --no-audit
fi

echo "[workbench] Ensuring Electron installed"
VER=$(node -e "try{let p=require('./package.json');console.log(p.devDependencies?.electron||p.dependencies?.electron||'latest')}catch(e){console.log('latest')}")
npm install -D electron@"$VER" --no-fund --no-audit || true

echo "[workbench] Running headless via Xvfb"
mkdir -p /work/out
XVFB_RUN="xvfb-run -a -s '-screen 0 1024x768x24'"
${XVFB_RUN} node /usr/local/bin/run-workbench-tests.js --export /work/out/report.json || true

echo "[workbench] Done. See /work/out"

