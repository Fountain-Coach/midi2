#!/usr/bin/env bash
# Publish the repository documentation projection to its dedicated host.
# DNS is managed separately by the reviewed Fountain Coach DNS helper.
set -euo pipefail

HOST="midi2.fountain.coach"
TARGET_IP="65.109.14.71"
REMOTE_ROOT="/var/www/midi2"
REMOTE_OWNER="root"

source_root="${1:-}"
apply=0
confirm=0
if [[ -z "$source_root" ]]; then
  echo "usage: $0 /path/to/generated-site [--apply --confirm-deploy]" >&2
  exit 2
fi
shift
while (($#)); do
  case "$1" in
    --apply) apply=1 ;;
    --confirm-deploy) confirm=1 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

source_root="$(cd "$source_root" && pwd)"
[[ -f "$source_root/index.html" ]] || { echo "missing generated index.html" >&2; exit 2; }

ssh_user="${PUBLISHING_SSH_USER:-root}"
ssh_key="${PUBLISHING_SSH_KEY:-$HOME/.ssh/id_rsa}"
ssh_opts=(-o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o HostKeyAlias="$TARGET_IP" -o ConnectTimeout=15 -i "$ssh_key")
dns_server="${PUBLISHING_DNS_SERVER:-}"
if [[ -n "$dns_server" ]]; then
  resolved="$(dig +short "@$dns_server" "$HOST" A 2>/dev/null | head -1)"
else
  resolved="$(dig +short "$HOST" A 2>/dev/null | head -1)"
fi
[[ "$resolved" == "$TARGET_IP" ]] || { echo "refusing: $HOST resolves to '${resolved:-nothing}', expected $TARGET_IP" >&2; exit 3; }

release="release-$(date -u +%Y%m%dT%H%M%SZ)"
echo "host: $HOST"
echo "source: $source_root"
echo "target: $ssh_user@$TARGET_IP:$REMOTE_ROOT"
echo "release: $release"
echo "mode: $([[ $apply -eq 1 && $confirm -eq 1 ]] && echo APPLY || echo 'DRY RUN')"

ssh "${ssh_opts[@]}" "$ssh_user@$TARGET_IP" "mkdir -p '$REMOTE_ROOT/.releases' '$REMOTE_ROOT/.rollback'"
rsync_args=(-rlptD --checksum --delete --exclude '.DS_Store' --exclude '._*' -e "ssh ${ssh_opts[*]}")
if [[ $apply -eq 1 && $confirm -eq 1 ]]; then
  rsync "${rsync_args[@]}" "$source_root/" "$ssh_user@$TARGET_IP:$REMOTE_ROOT/.releases/$release/"
  ssh "${ssh_opts[@]}" "$ssh_user@$TARGET_IP" "set -eu; chmod -R a+rX '$REMOTE_ROOT/.releases/$release'; if test -d '$REMOTE_ROOT/current'; then mv '$REMOTE_ROOT/current' '$REMOTE_ROOT/.rollback/previous-$release'; fi; mv '$REMOTE_ROOT/.releases/$release' '$REMOTE_ROOT/current'; test -f '$REMOTE_ROOT/current/index.html'"
  ssh "${ssh_opts[@]}" "$ssh_user@$TARGET_IP" "set -eu; caddyfile=/etc/caddy/Caddyfile; backup=/etc/caddy/Caddyfile.midi2-$release; cp \"\$caddyfile\" \"\$backup\"; if ! grep -q '^$HOST {' \"\$caddyfile\"; then cat >> \"\$caddyfile\" <<'BLOCK'

$HOST {
    root * $REMOTE_ROOT/current
    encode gzip
    file_server
}
BLOCK
fi; if ! caddy validate --config \"\$caddyfile\"; then cp \"\$backup\" \"\$caddyfile\"; exit 1; fi; systemctl reload caddy"
  echo "== live verification =="
  curl --fail --silent --show-error --location --max-time 30 --head "https://$HOST/" | sed -n -E '/^(HTTP\/|content-type:|server:|location:)/Ip'
  curl --fail --silent --show-error --max-time 30 "https://$HOST/" | grep -q 'MIDI2 documentation'
  echo "verified: https://$HOST/"
else
  rsync --dry-run "${rsync_args[@]}" "$source_root/" "$ssh_user@$TARGET_IP:$REMOTE_ROOT/.releases/$release/"
  echo "dry run only — no publication or Caddy configuration was written"
fi
