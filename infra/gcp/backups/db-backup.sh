#!/usr/bin/env bash
# DB → R2 escrow backup — runs INSIDE the db-backup Cloud Run Job (Backend
# Production Readiness, Sprint 2). Dumps one or both Postgres databases with a
# PINNED pg_dump 17 (the image base is postgres:17-alpine) and uploads each dump
# to a Cloudflare R2 bucket via rclone (S3-compatible). R2 + the plain pg_dump
# custom format = off-platform, vendor-neutral, restorable-anywhere escrow.
#
# A backup whose result nobody checks can silently die (see Roadmap/LEARNINGS.md),
# so every step's exit code is checked, the uploaded object's existence+size are
# re-read back, and ANY failure exits non-zero (→ the Cloud Run Job fails → the
# S4 alert policy fires) and best-effort pings Telegram.
#
# All credentials arrive as ENV (mapped from Secret Manager by the Job) and are
# NEVER echoed.
#
#   Env (required):
#     BACKUP_TARGETS            comma list: "supabase,medusa" (or a subset)
#     SUPABASE_BACKUP_DSN       read-only Postgres DSN  (needed iff target supabase)
#     MEDUSA_BACKUP_DSN         the commerce DB DSN     (needed iff target medusa)
#     R2_BACKUP_BUCKET          destination bucket name
#     R2_BACKUP_ACCESS_KEY_ID / R2_BACKUP_SECRET_ACCESS_KEY
#                               R2 token scoped to ONLY this bucket, "Object Read & Write"
#                               (R2 offers no write-only level; the read half is what lets the
#                               size verification below work — immutability comes from bucket
#                               VERSIONING + lifecycle, not the token)
#     R2_BACKUP_ENDPOINT        https://<accountid>.r2.cloudflarestorage.com
#   Env (optional):
#     RETENTION_DAYS            informational only — real expiry is the R2 lifecycle rule (default 30)
#     TELEGRAM_BOT_TOKEN / TELEGRAM_CICD_CHAT_ID   best-effort failure alert

set -euo pipefail

TARGETS="${BACKUP_TARGETS:?set BACKUP_TARGETS (e.g. supabase,medusa)}"
BUCKET="${R2_BACKUP_BUCKET:?set R2_BACKUP_BUCKET}"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
DAY="$(date -u +%Y/%m/%d)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# rclone reads an S3 remote called "r2" entirely from env (no config file).
export RCLONE_CONFIG_R2_TYPE=s3
export RCLONE_CONFIG_R2_PROVIDER=Cloudflare
export RCLONE_CONFIG_R2_ACCESS_KEY_ID="${R2_BACKUP_ACCESS_KEY_ID:?set R2_BACKUP_ACCESS_KEY_ID}"
export RCLONE_CONFIG_R2_SECRET_ACCESS_KEY="${R2_BACKUP_SECRET_ACCESS_KEY:?set R2_BACKUP_SECRET_ACCESS_KEY}"
export RCLONE_CONFIG_R2_ENDPOINT="${R2_BACKUP_ENDPOINT:?set R2_BACKUP_ENDPOINT}"
export RCLONE_CONFIG_R2_NO_CHECK_BUCKET=true   # bucket-scoped token can't create buckets; skip the probe

log()  { printf '%s %s\n' "$(date -u +%H:%M:%S)" "$*"; }
alert() {
  log "ALERT: $*"
  if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CICD_CHAT_ID:-}" ]; then
    curl -s -m 10 -o /dev/null \
      --data-urlencode "chat_id=${TELEGRAM_CICD_CHAT_ID}" \
      --data-urlencode "text=🛑 db-backup FAILED: $*" \
      "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" || true
  fi
}

# back_up TARGET DSN — pg_dump (custom format) | gzip → R2, then verify the object.
back_up() {
  local target="$1" dsn="$2"
  # An explicit check, not `${DSN:?}` at the call site: under bash 3.2 the EXIT trap above overrides
  # that expansion's failure status and the script exits 0 (seen 2026-10-15 — a run that dumped NOTHING
  # reported success); under bash 5 (the image) it kills the whole run, skipping every later target. Here
  # a missing DSN fails this target, alerts, and the other targets still get their dump.
  if [ -z "$dsn" ]; then
    alert "$target DSN is not set"; return 1
  fi
  local file="${target}-${STAMP}.dump.gz"
  local local_path="${WORK}/${file}"
  local key="${target}/${DAY}/${file}"

  log "[$target] pg_dump (custom format) → gzip …"
  # --format=custom is selectively restorable (pg_restore -t/--data-only) and compresses;
  # we gzip on top for transfer/storage. set -o pipefail makes a pg_dump failure fatal.
  if ! pg_dump --format=custom --no-owner --no-privileges --dbname="$dsn" | gzip -c > "$local_path"; then
    alert "$target pg_dump failed"; return 1
  fi
  local bytes; bytes=$(wc -c < "$local_path" | tr -d " ")   # BSD wc pads; the size compare is a string compare
  if [ "$bytes" -lt 1000 ]; then
    alert "$target dump suspiciously small (${bytes} bytes)"; return 1
  fi
  log "[$target] dump ${bytes} bytes → r2:${BUCKET}/${key}"

  if ! rclone copyto "$local_path" "r2:${BUCKET}/${key}"; then
    alert "$target upload to R2 failed"; return 1
  fi
  # Read the object back: prove the write landed (don't trust a clean exit alone).
  local remote_bytes; remote_bytes=$(rclone size "r2:${BUCKET}/${key}" --json 2>/dev/null | sed -n 's/.*"bytes":\([0-9]*\).*/\1/p')
  if [ "${remote_bytes:-0}" != "$bytes" ]; then
    alert "$target R2 object size mismatch (local ${bytes} vs remote ${remote_bytes:-missing})"; return 1
  fi
  log "[$target] ✅ verified ${remote_bytes} bytes at ${key}"
}

RC=0
IFS=',' read -ra LIST <<< "$TARGETS"
for t in "${LIST[@]}"; do
  case "$t" in
    supabase) back_up supabase "${SUPABASE_BACKUP_DSN:-}" || RC=1 ;;
    # `medusa` = the live commerce DB (miyagi-to-oracle-vm S1.1). Until 2026-10-15 this job still
    # dumped `neon` — the abandoned pre-Cloud-SQL copy — so the REAL commerce DB had no copy outside
    # GCP at all; Cloud SQL's own backups live inside the same project they protect. The DB is about
    # to leave Cloud SQL for a single VM, where this offsite dump becomes the backup-of-record.
    # `neon` was removed rather than kept as dead code: an unknown target now fails loud (below),
    # which is the right outcome for a stale BACKUP_TARGETS that still names it.
    medusa)   back_up medusa   "${MEDUSA_BACKUP_DSN:-}"   || RC=1 ;;
    *) alert "unknown BACKUP_TARGET '$t'"; RC=1 ;;
  esac
done

if [ "$RC" -ne 0 ]; then
  log "✗ one or more backups FAILED"; exit 1
fi
log "✅ all backups complete (retention=${RETENTION_DAYS:-30}d via R2 lifecycle)"
