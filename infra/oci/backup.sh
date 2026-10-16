#!/usr/bin/env bash
# Nightly dumps on `panfleto-prod` → Cloudflare R2 (offsite, WORM) AND the OCI bucket (in-region, fast
# restore): Medusa (the local Postgres) and, since 2026-10-16, Supabase (remote) — which the GCP `db-backup`
# job did until then; one backup system, one alert path. Epic miyagi-to-oracle-vm, decision D1. Run by
# miyagi-backup.timer.
#
# Two copies on two vendors on purpose: a backup that lives only in the same cloud account as the DB is
# lost with it (an Oracle account suspension would take both). R2 is the same WORM escrow bucket the GCP
# `db-backup` job writes (infra/gcp/backups/BACKUPS.md), under the same `medusa/YYYY/MM/DD/` keys.
#
# Medusa is dumped as `backup_ro` (pg_read_all_data), never as the app's role — the answered review
# finding on PR #206. Supabase is dumped with SUPABASE_BACKUP_DSN, its own read-only role. Credentials: infra/oci/backup.env (0600, deploy user, written by bootstrap.sh); OCI uses the
# instance principal, so no OCI key is on this host.
#
# Any failure exits non-zero (→ the unit fails) and pings Telegram; each upload is read back and its size
# compared, because a clean exit alone is not evidence the object landed.
# -E: the ERR trap below must also fire inside ship(); without errtrace, functions do not inherit it.
set -Eeuo pipefail

DEPLOY=/opt/miyagi/infra/oci
# shellcheck disable=SC1091
set -a; . "$DEPLOY/backup.env"; set +a
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
DAY="$(date -u +%Y/%m/%d)"
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
# R2 — rclone reads the remote entirely from env, same as db-backup.sh.
export RCLONE_CONFIG_R2_TYPE=s3 RCLONE_CONFIG_R2_PROVIDER=Cloudflare RCLONE_CONFIG_R2_NO_CHECK_BUCKET=true
export RCLONE_CONFIG_R2_ACCESS_KEY_ID="$R2_BACKUP_ACCESS_KEY_ID" RCLONE_CONFIG_R2_SECRET_ACCESS_KEY="$R2_BACKUP_SECRET_ACCESS_KEY"
export RCLONE_CONFIG_R2_ENDPOINT="$R2_BACKUP_ENDPOINT"
NS="$(oci os ns get --auth instance_principal --query data --raw-output)" || alert "OCI namespace lookup failed"

# ship NAME PREFIX — upload /data/miyagi/backups/NAME-<stamp>.dump.gz to both vendors under PREFIX/YYYY/MM/DD/,
# reading each back and comparing sizes (a clean exit alone is not evidence the object landed).
ship() {
  local file="$1-${STAMP}.dump.gz"; local LOCAL="/data/miyagi/backups/${file}"; local KEY="$2/${DAY}/${file}"
  local BYTES; BYTES="$(stat -c%s "$LOCAL")"
  [ "$BYTES" -ge 100000 ] || alert "$1 dump suspiciously small (${BYTES} bytes)"   # each is ~340–360 KB
  rclone copyto "$LOCAL" "r2:${R2_BACKUP_BUCKET}/${KEY}" || alert "$1 R2 upload failed"
  local REMOTE; REMOTE="$(rclone size "r2:${R2_BACKUP_BUCKET}/${KEY}" --json | sed -n 's/.*"bytes":\([0-9]*\).*/\1/p')"
  [ "${REMOTE:-0}" = "$BYTES" ] || alert "$1 R2 size mismatch (local ${BYTES} vs remote ${REMOTE:-missing})"
  oci os object put --auth instance_principal --namespace "$NS" --bucket-name "${OCI_BUCKET:-miyagi-backups}" \
    --name "$KEY" --file "$LOCAL" --force >/dev/null || alert "$1 OCI upload failed"
  local OREMOTE; OREMOTE="$(oci os object head --auth instance_principal --namespace "$NS" --bucket-name "${OCI_BUCKET:-miyagi-backups}" \
    --name "$KEY" --query '"content-length"' --raw-output)" || alert "$1 OCI read-back failed"
  [ "$OREMOTE" = "$BYTES" ] || alert "$1 OCI size mismatch (local ${BYTES} vs remote ${OREMOTE})"
  # Keep the last 7 of each locally (the restore drill reads medusa's); the buckets are the archive.
  ls -1t /data/miyagi/backups/"$1"-*.dump.gz | tail -n +8 | xargs -r rm -f
  echo "✓ ${KEY} (${BYTES} bytes) verified in R2 and OCI"
}

# ── Medusa (local) ──────────────────────────────────────────────────────────────────────────────────────
# `-e PGPASSWORD` with NO value: docker copies it from this process's environment, so the password never
# appears in argv (readable by every user via /proc/<pid>/cmdline) — PR #209 security review.
PGPASSWORD="$BACKUP_RO_PASSWORD" docker compose exec -T -e PGPASSWORD postgres \
  pg_dump --format=custom --no-owner --no-privileges -h 127.0.0.1 -U backup_ro medusa \
  | gzip -c > "/data/miyagi/backups/medusa-${STAMP}.dump.gz" || alert "medusa pg_dump failed"
# `medusa` since the 2026-10-16 cutover (the dark period wrote `medusa-oci/` so its dumps never sat beside
# GCP's real prod dumps — PR #209 review). The default is the live value: a backup.env missing the line
# must not silently move prod dumps back under the dark-period prefix.
ship medusa "${BACKUP_PREFIX:-medusa}"

# ── Supabase (remote) ───────────────────────────────────────────────────────────────────────────────────
# The DSN carries a password, so it must not reach pg_dump's argv either: split it into libpq's own PG*
# variables here and pass them to the container BY NAME. `supabase/` is the prefix the GCP job used, so the
# archive stays one continuous series.
[ -n "${SUPABASE_BACKUP_DSN:-}" ] || alert "SUPABASE_BACKUP_DSN is not set in backup.env"
# Captured first, then eval'd: `eval "$(failing)"` evaluates "" and exits 0, which would swallow a parse failure.
SB_ENV="$(SUPABASE_BACKUP_DSN="$SUPABASE_BACKUP_DSN" python3 -c '
import os, shlex, urllib.parse as u
d = u.urlsplit(os.environ["SUPABASE_BACKUP_DSN"]); q = dict(u.parse_qsl(d.query))
env = {"PGHOST": d.hostname, "PGPORT": str(d.port or 5432), "PGUSER": u.unquote(d.username or ""),
       "PGPASSWORD": u.unquote(d.password or ""), "PGDATABASE": d.path.lstrip("/") or "postgres",
       "PGSSLMODE": q.get("sslmode", "require")}
assert env["PGHOST"] and env["PGUSER"] and env["PGPASSWORD"], "DSN lacks host, user or password"
print("\n".join(f"SB_{k}={shlex.quote(v)}" for k, v in env.items()))')" || alert "SUPABASE_BACKUP_DSN does not parse"
eval "$SB_ENV"
PGHOST="$SB_PGHOST" PGPORT="$SB_PGPORT" PGUSER="$SB_PGUSER" PGPASSWORD="$SB_PGPASSWORD" PGDATABASE="$SB_PGDATABASE" \
  PGSSLMODE="$SB_PGSSLMODE" docker compose exec -T -e PGHOST -e PGPORT -e PGUSER -e PGPASSWORD -e PGDATABASE -e PGSSLMODE \
  postgres pg_dump --format=custom --no-owner --no-privileges \
  | gzip -c > "/data/miyagi/backups/supabase-${STAMP}.dump.gz" || alert "supabase pg_dump failed"
ship supabase supabase
