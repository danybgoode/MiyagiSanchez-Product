#!/usr/bin/env bash
# Weekly restore drill: restore the newest local Medusa dump into a THROWAWAY Postgres container and report
# row counts to Telegram. A backup that has never been restored is a hope, not a backup — and on this
# single VM the dump is the backup-of-record (Cloud SQL's PITR is gone). Run by miyagi-restore-drill.timer.
#
# The throwaway container has no volume and no network, and is removed on exit; production is never
# touched. The counts are compared with the live DB so a "successful" restore of an empty or truncated
# dump fails the drill instead of passing it.
set -euo pipefail

DEPLOY=/opt/miyagi/infra/oci
# shellcheck disable=SC1091
set -a; . "$DEPLOY/backup.env"; set +a
DUMP="$(ls -1t /data/miyagi/backups/medusa-*.dump.gz 2>/dev/null | head -1)"
NAME="miyagi-restore-drill-$$"
TABLES="product product_variant customer cart \"order\" payment_collection"

say() {
  if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CICD_CHAT_ID:-}" ]; then
    curl -s -m 10 -o /dev/null --data-urlencode "chat_id=${TELEGRAM_CICD_CHAT_ID}" --data-urlencode "text=$*" \
      "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" || true
  fi
  echo "$*"
}
fail() { say "🛑 miyagi restore drill FAILED: $*"; exit 1; }
trap 'docker rm -f "$NAME" >/dev/null 2>&1 || true' EXIT

[ -n "$DUMP" ] || fail "no local dump in /data/miyagi/backups"
docker run -d --name "$NAME" --network none -e POSTGRES_PASSWORD=drill -e POSTGRES_DB=drill \
  --memory 768m --cpus 0.5 postgres:17-alpine >/dev/null
for _ in $(seq 1 30); do docker exec "$NAME" pg_isready -U postgres >/dev/null 2>&1 && break; sleep 2; done
gunzip -c "$DUMP" | docker exec -i "$NAME" pg_restore --no-owner --no-privileges -U postgres -d drill \
  || fail "pg_restore of $(basename "$DUMP") failed"

count() { # container db role table
  docker exec "$1" psql -U "$3" -d "$2" -tAc "select count(*) from $4" 2>/dev/null || echo "?"
}
cd "$DEPLOY"
LIVE="$(docker compose ps -q postgres)"
[ -n "$LIVE" ] || fail "the live postgres container is not running — nothing to compare against"
REPORT=""; BAD=0
for t in $TABLES; do
  r="$(count "$NAME" drill postgres "$t")"; l="$(count "$LIVE" medusa medusa "$t")"
  REPORT="${REPORT}${t//\"/}: ${r} (live ${l})
"
  # Either side unreadable is a FAILED drill — a stopped production container must not read as a pass.
  # The dump is up to a day old, so the restored count may trail live — but never be empty when live isn't.
  { [ "$r" = "?" ] || [ "$l" = "?" ] || { [ "$r" = 0 ] && [ "$l" != 0 ]; }; } && BAD=1
done
[ "$BAD" -eq 0 ] || fail "restored counts look wrong:
${REPORT}"
say "✅ miyagi restore drill: $(basename "$DUMP") restored cleanly
${REPORT}"
