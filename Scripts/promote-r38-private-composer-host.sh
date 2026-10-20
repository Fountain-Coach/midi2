#!/usr/bin/env bash
# R38 verified, reversible source-built CodexKit promotion.
# This script never rewrites the systemd unit or the Codex login home.
set -euo pipefail
[[ "$EUID" -eq 0 ]] || { echo "owner root console required" >&2; exit 13; }
MODE="dry-run"
[[ $# -eq 0 ]] || [[ $# -eq 1 && "$1" == "--apply" ]] || exit 2
[[ $# -eq 0 ]] || MODE="apply"
ROOT=/opt/fountaincoach/midi2
EXEC="$ROOT/codexkitumpd"
SRC=/home/benedikt/r38-codexkit-admission-build-20261020
NEW="$SRC/.build/release/codexkitumpd"
UNIT=/etc/systemd/system/fountaincoach-codexkit.service
BEFORE=2f799e5032847109d2e6b1f59be4e7e92aa8d8492b116a347f139ec724fcba60
REV=ab8b81f14b3caa5e493d28aa5b2f4ac6bd1057a0
NAME=r38-${REV:0:7}
TARGET="$ROOT/releases/$NAME"
BACKUP="$ROOT/releases/before-r38-$BEFORE"
SAVED_LINK="$ROOT/.codexkitumpd-next"
[[ "$(git -C "$SRC" rev-parse HEAD)" == "$REV" ]] || exit 12
[[ -z "$(git -C "$SRC" status --porcelain)" ]] || exit 12
[[ -x "$NEW" && -f "$UNIT" ]] || exit 12
[[ "$(sha256sum "$EXEC" | cut -d' ' -f1)" == "$BEFORE" ]] || exit 12
grep -Fxq 'ExecStart=/opt/fountaincoach/midi2/codexkitumpd --rtp-port 65386 --codex-executable /opt/fountaincoach/codex-runtime/current/vendor/x86_64-unknown-linux-musl/bin/codex --codex-home /var/lib/fountaincoach/codex' "$UNIT" || exit 12
[[ "$(systemctl is-active fountaincoach-codexkit.service)" == active ]] || exit 12
[[ ! -e "$TARGET" && ! -e "$BACKUP" && ! -e "$SAVED_LINK" ]] || exit 12
echo "SOURCE_REV=$REV"
echo "NEW_BINARY_SHA=$(sha256sum "$NEW" | cut -d' ' -f1)"
echo "PREDECESSOR_SHA=$BEFORE"
echo "MODE=$MODE"
[[ "$MODE" == apply ]] || exit 0
install -d -m 755 "$ROOT/releases"
install -d -m 755 "$TARGET" "$BACKUP"
cp -p "$EXEC" "$BACKUP/codexkitumpd"
install -m 755 "$NEW" "$TARGET/codexkitumpd"
EXPECTED_NEW="$(sha256sum "$NEW" | cut -d' ' -f1)"
[[ "$(sha256sum "$TARGET/codexkitumpd" | cut -d' ' -f1)" == "$EXPECTED_NEW" ]] || exit 12
UNIT_SHA="$(sha256sum "$UNIT" | cut -d' ' -f1)"
rollback() {
  echo "R38_HOST_ACTIVATION_ROLLBACK" >&2
  rm -f "$SAVED_LINK"
  ln -s "releases/before-r38-$BEFORE/codexkitumpd" "$SAVED_LINK"
  mv -Tf "$SAVED_LINK" "$EXEC"
  systemctl restart fountaincoach-codexkit.service || true
}
trap rollback ERR
ln -s "releases/$NAME/codexkitumpd" "$SAVED_LINK"
mv -Tf "$SAVED_LINK" "$EXEC"
systemctl restart fountaincoach-codexkit.service
sleep 2
[[ "$(systemctl is-active fountaincoach-codexkit.service)" == active ]]
[[ "$(sha256sum "$UNIT" | cut -d' ' -f1)" == "$UNIT_SHA" ]]
[[ "$(readlink "$EXEC")" == "releases/$NAME/codexkitumpd" ]]
[[ "$(sha256sum "$EXEC" | cut -d' ' -f1)" == "$EXPECTED_NEW" ]]
pgrep -x codexkitumpd >/dev/null
ss -ulnp | grep -q ':65386 '
env CODEX_HOME=/var/lib/fountaincoach/codex /opt/fountaincoach/codex-runtime/current/vendor/x86_64-unknown-linux-musl/bin/codex login status | grep -Fq 'Logged in using ChatGPT'
trap - ERR
echo "R38_HOST_ACTIVATED_SOURCE=$REV"
echo "R38_ROLLBACK_BINARY=$BACKUP/codexkitumpd"
echo "R38_UNIT_UNCHANGED_SHA=$UNIT_SHA"
