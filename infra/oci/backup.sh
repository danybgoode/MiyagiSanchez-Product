#!/usr/bin/env bash
# Nightly Medusa dump on `panfleto-prod` → Cloudflare R2 (offsite, WORM) AND the OCI bucket (in-region,
# fast restore). Epic miyagi-to-oracle-vm, decision D1. Run by miyagi-backup.timer.
#
# Two copies on two vendors on purpose: a backup that lives only in the same cloud account as the DB is
# lost with it (an Oracle account suspension would take both). R2 is the same WORM escrow bucket the GCP
# `db-backup` job writes (infra/gcp/backups/BACKUPS.md), under the same `medusa/YYYY/MM/DD/` keys.
#
# The dump connects as `backup_ro` (pg_read_all_data), never as the app's role — the answered review
# finding on PR #206. Credentials: infra/oci/backup.env (0600, deploy user, written by bootstrap.sh); OCI uses the
# instance principal, so no OCI key is on this host.
#
# Any failure exits non-zero (→ the unit fails) and pings Telegram; each upload is read back and its size
# compared, because a clean exit alone is not evidence the object landed.
set -euo pipefail

DEPLOY=/opt/miyagi/infra/oci
# shellcheck disable=SC1091
set -a; . "$DEPLOY/backup.env"; set +a
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
DAY="$(date -u +%Y/%m/%d)"
FILE="medusa-${STAMP}.dump.gz"
LOCAL="/data/miyagi/backups/${FILE}"
# `medusa-oci/` until the cutover: the dark copy's dumps must never sit, indistinguishable, beside the real
# prod dumps the GCP job writes to `medusa/` in the same write-once bucket (PR #209 review). The cutover sets
# BACKUP_PREFIX=medusa in backup.env, when this VM becomes prod and the GCP job is deleted.
KEY="${BACKUP_PREFIX:-medusa-oci}/${DAY}/${FILE}"

alert() {
  trap - ERR
  echo "ALERT: $*" >&2
  if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CICD_CHAT_ID:-}" ]; then
    printf 'url = "https://api.telegram.org/bot%s/sendMessage"\n' "$TELEGRAM_BOT_TOKEN" \
      | curl -s -m 10 -o /dev/null -K - --data-urlencode "chat_id=${TELEGRAM_CICD_CHAT_ID}" \
      --data-urlencode "text=🛑 miyagi VM backup FAILED: $*" || true
  fi
  exit 1
}

# Any command that dies under `set -e` without calling alert() — a failed substitution, stat — still pages:
# the header's "any failure pings Telegram" has to be true of every path (PR #209 review).
trap 'alert "unexpected failure at line $LINENO"' ERR

cd "$DEPLOY"
# `-e PGPASSWORD` with NO value: docker copies it from this process's environment, so the password never
# appears in argv (readable by every user via /proc/<pid>/cmdline) — PR #209 security review.
PGPASSWORD="$BACKUP_RO_PASSWORD" docker compose exec -T -e PGPASSWORD postgres \
  pg_dump --format=custom --no-owner --no-privileges -h 127.0.0.1 -U backup_ro medusa \
  | gzip -c > "$LOCAL" || alert "pg_dump failed"

BYTES="$(stat -c%s "$LOCAL")"
[ "$BYTES" -ge 100000 ] || alert "dump suspiciously small (${BYTES} bytes)"   # prod's is ~338 KB

# R2 — rclone reads the remote entirely from env, same as db-backup.sh.
export RCLONE_CONFIG_R2_TYPE=s3 RCLONE_CONFIG_R2_PROVIDER=Cloudflare RCLONE_CONFIG_R2_NO_CHECK_BUCKET=true
export RCLONE_CONFIG_R2_ACCESS_KEY_ID="$R2_BACKUP_ACCESS_KEY_ID" RCLONE_CONFIG_R2_SECRET_ACCESS_KEY="$R2_BACKUP_SECRET_ACCESS_KEY"
export RCLONE_CONFIG_R2_ENDPOINT="$R2_BACKUP_ENDPOINT"
rclone copyto "$LOCAL" "r2:${R2_BACKUP_BUCKET}/${KEY}" || alert "R2 upload failed"
REMOTE="$(rclone size "r2:${R2_BACKUP_BUCKET}/${KEY}" --json | sed -n 's/.*"bytes":\([0-9]*\).*/\1/p')"
[ "${REMOTE:-0}" = "$BYTES" ] || alert "R2 size mismatch (local ${BYTES} vs remote ${REMOTE:-missing})"

NS="$(oci os ns get --auth instance_principal --query data --raw-output)" || alert "OCI namespace lookup failed"
oci os object put --auth instance_principal --namespace "$NS" --bucket-name "${OCI_BUCKET:-miyagi-backups}" \
  --name "$KEY" --file "$LOCAL" --force >/dev/null || alert "OCI upload failed"
OREMOTE="$(oci os object head --auth instance_principal --namespace "$NS" --bucket-name "${OCI_BUCKET:-miyagi-backups}" \
  --name "$KEY" --query '"content-length"' --raw-output)" || alert "OCI read-back failed"
[ "$OREMOTE" = "$BYTES" ] || alert "OCI size mismatch (local ${BYTES} vs remote ${OREMOTE})"

# Keep the last 7 locally for the restore drill; the buckets are the archive.
ls -1t /data/miyagi/backups/medusa-*.dump.gz | tail -n +8 | xargs -r rm -f
echo "✓ ${KEY} (${BYTES} bytes) verified in R2 and OCI"
