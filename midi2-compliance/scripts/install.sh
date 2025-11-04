#!/usr/bin/env bash
set -euo pipefail

# ---------- Config ----------
WORKBENCH_FORK_URL="${WORKBENCH_FORK_URL:-https://github.com/Fountain-Coach/MIDI2.0Workbench}"
WORKBENCH_DIR="${WORKBENCH_DIR:-.workbench}"
# Repo root is two levels up from this script (../../)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "[midi2-compliance] Repo root: $REPO_ROOT"
echo "[midi2-compliance] Workbench fork: $WORKBENCH_FORK_URL"
echo "[midi2-compliance] Workbench dir: $WORKBENCH_DIR"

cd "$REPO_ROOT"

# ---------- Node/Playwright deps (local user install) ----------
if ! command -v node >/dev/null 2>&1; then
  echo "[midi2-compliance] Node.js not found. Please install Node >= 18 before proceeding."
  exit 1
fi

# Initialize a local package.json if none
if [ ! -f package.json ]; then
  echo "{}" > package.json
fi

# Add Playwright + Electron runner deps
npm pkg set name="midi2-compliance-runner" >/dev/null
npm pkg set private=true >/dev/null
# Use CommonJS so our controller can `require()`
npm pkg set type="commonjs" >/dev/null
npm pkg set scripts.test="echo 'No tests' && exit 0" >/dev/null

npm install --no-fund --no-audit playwright @playwright/test --save-dev

# ---------- Clone Workbench fork ----------
if [ ! -d "$WORKBENCH_DIR" ]; then
  echo "[midi2-compliance] Cloning Workbench fork..."
  git clone "$WORKBENCH_FORK_URL" "$WORKBENCH_DIR"
else
  echo "[midi2-compliance] Workbench directory exists. Pulling latest..."
  git -C "$WORKBENCH_DIR" pull --ff-only || true
fi

# ---------- Build Workbench (if it uses yarn; fallback to npm) ----------
pushd "$WORKBENCH_DIR" >/dev/null
if command -v yarn >/dev/null 2>&1; then
  yarn install
  yarn build || true
else
  npm install
  npm run build || true
fi
popd >/dev/null

echo "[midi2-compliance] Installation complete."
echo "You can run: bash midi2-compliance/scripts/run_local.sh"

# ---------- Ensure GitHub Actions workflow is installed ----------
mkdir -p .github/workflows
cp -f midi2-compliance/.github/workflows/midi2-compliance.yml .github/workflows/midi2-compliance.yml
echo "[midi2-compliance] Installed workflow: .github/workflows/midi2-compliance.yml"
