#!/usr/bin/env bash
# Called only from an independently authenticated owner SSH console on the
# Linux CodexKit machine. Not a network issuer, not an iPad API, no Store grant.
set -euo pipefail
[[ "$EUID" -eq 0 ]] || { echo 'refused: trusted local root console required' >&2; exit 13; }
[[ $# -eq 2 ]] || { echo 'usage: approve-r38-private-composer.sh <session-uuid> <8-digit-code-shown-on-iPad>' >&2; exit 2; }
SESSION="$1"
CODE="$2"
[[ "$SESSION" =~ ^[a-fA-F0-9-]{36}$ ]] || { echo 'refused: invalid session identity' >&2; exit 12; }
[[ "$CODE" =~ ^[0-9]{8}$ ]] || { echo 'refused: invalid confirmation code' >&2; exit 12; }
BASE=/run/fountaincoach/r38-codexkit-pairing
PENDING="$BASE/pending/$SESSION"
APPROVED="$BASE/approved/$SESSION"
[[ -d "$BASE" && ! -L "$BASE" && -f "$PENDING" && ! -L "$PENDING" && ! -e "$APPROVED" ]] ||
  { echo 'refused: no unapproved pending host challenge' >&2; exit 12; }
[[ "$(stat -c %u "$PENDING")" = 0 && "$(stat -c %a "$PENDING")" = 600 ]] ||
  { echo 'refused: pending code is not root-private' >&2; exit 12; }
HOSTCODE="$(tr -d '\n' < "$PENDING")"
[[ "$CODE" == "$HOSTCODE" ]] || { echo 'refused: pairing comparison failed' >&2; exit 12; }
umask 077
( set -C; printf '%s\n' "$CODE" > "$APPROVED" ) || {
  echo 'refused: concurrent approval already in progress' >&2; exit 12;
}
chmod 600 "$APPROVED"
echo "OWNER_APPROVED_ONE_PENDING_R38_COMPOSER_SESSION $SESSION"
