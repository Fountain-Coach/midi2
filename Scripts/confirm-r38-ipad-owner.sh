#!/usr/bin/env bash
# Local owner interaction for one Reframe R38 physical-iPad proof.
# Invoke from a *trusted terminal* over SSH to the owning Ubuntu host.
# It only approves a fresh pending pairing after the human compares both codes.
set -euo pipefail
[[ "${EUID}" -eq 0 && -t 0 && -t 1 ]] || {
  echo "Open this as root in an interactive, trusted owner terminal." >&2
  exit 13
}
BASE=/run/fountaincoach-r38-codexkit-pairing
[[ -d "$BASE/pending" && ! -L "$BASE/pending" ]] || {
  echo "No active R38 host pairing. Pair on the iPad first." >&2
  exit 12
}
MARKER="$(mktemp "$BASE/.operator-start.XXXXXXXX")"
trap 'rm -f "$MARKER"' EXIT
echo "Open Reframe R38 on the physical iPad: Bookshelf -> Empty -> Pair iPad with CodexKit."
echo "Watching only for a new pairing created AFTER this trusted terminal was opened."
FRESH=()
SECONDS=0
while (( SECONDS < 80 )); do
  mapfile -t FRESH < <(find "$BASE/pending" -maxdepth 1 -type f -newer "$MARKER" -mmin -2 -printf '%f\n' | sort)
  [[ "${#FRESH[@]}" -eq 0 ]] || break
  sleep 1
done
[[ "${#FRESH[@]}" -eq 1 ]] || {
  echo "Expected one fresh pairing; found ${#FRESH[@]}. No approval." >&2
  exit 12
}
SESSION="${FRESH[0]}"
[[ "$SESSION" =~ ^[A-Fa-f0-9-]{36}$ ]] || exit 12
PENDING="$BASE/pending/$SESSION"
[[ "$(stat -c %u "$PENDING")" == 0 && "$(stat -c %a "$PENDING")" == 600 ]] || exit 12
CODE="$(tr -d '\n' < "$PENDING")"
[[ "$CODE" =~ ^[0-9]{8}$ ]] || exit 12
echo "R38 iPad pairing request: $SESSION"
echo "Ubuntu host confirmation code: $CODE"
echo "Look at Reframe R38 on the physical iPad. Both eight-digit codes must match."
printf 'Type the eight-digit code shown on the iPad (anything else refuses): '
IFS= read -r TYPED
[[ "$TYPED" == "$CODE" ]] || {
  echo "Codes differ; no approval was issued." >&2
  exit 12
}
printf 'Type APPROVE to admit this one conversation-only session: '
IFS= read -r DECISION
[[ "$DECISION" == "APPROVE" ]] || {
  echo "No approval issued." >&2
  exit 12
}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/approve-r38-private-composer.sh" "$SESSION" "$TYPED"
