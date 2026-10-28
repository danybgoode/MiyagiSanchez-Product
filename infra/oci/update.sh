#!/usr/bin/env bash
# Deploy Miyagi on `panfleto-prod`: pull main, pin the newest arm64 images by digest, (re)start the stack,
# install the Caddy site file, reload Caddy, and wait for both apps to answer. Run ON the VM:
#   /opt/miyagi/infra/oci/update.sh
#
# Images: `ghcr.io/danybgoode/{medusa-web,miyagi-web}:main` is resolved to an immutable DIGEST and that
# digest is what runs — the moving tag never does. To roll back, pin an older sha in infra/oci/.env:
#   MEDUSA_IMAGE_PIN=ghcr.io/danybgoode/medusa-web:<sha>      (or WEB_IMAGE_PIN=…)
# and re-run; delete the line to roll forward. A pin always wins over :main.
#
# When a commit changes THIS script, bash keeps reading the old inode — re-run it after the pull.
set -euo pipefail

ROOT=/opt/miyagi
DEPLOY="$ROOT/infra/oci"
ENV_FILE="$DEPLOY/.env"
cd "$DEPLOY"

for f in .env medusa.env web.env; do
  [ -s "$f" ] || { echo "✗ infra/oci/$f is missing — restore it from Daniel's password manager (0600, owner ubuntu); bootstrap.sh's source is deleted" >&2; exit 1; }
done

# Telegram: one line to the CI/CD chat when a deploy finishes, ✅ or ❌. The push to main already pings (📦, the
# app repos' notify-telegram.yml); this is its pair. It went missing with Cloud Build, and from 10-16 to 10-28 a
# deploy said nothing. Same bot, chat and `curl -K -` (token never in argv) as backup.sh, read from backup.env in
# a subshell so nothing else in that file reaches this script. Best effort: a Telegram outage never fails a deploy.
notify() {
  ( set +x
    # shellcheck disable=SC1091
    . "$DEPLOY/backup.env" 2>/dev/null || exit 0
    [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CICD_CHAT_ID:-}" ] || exit 0
    printf 'url = "https://api.telegram.org/bot%s/sendMessage"\n' "$TELEGRAM_BOT_TOKEN" \
      | curl -s -m 10 -o /dev/null -K - --data-urlencode "chat_id=${TELEGRAM_CICD_CHAT_ID}" \
        --data-urlencode "parse_mode=HTML" --data-urlencode "disable_web_page_preview=true" \
        --data-urlencode "text=$1" ) || true
}
# rev IMAGE — the commit an image was built from, short.
rev() { docker image inspect "$1" --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' 2>/dev/null | cut -c1-7; }
# Every way out that is not the success line below (set -e, an explicit `exit 1`, a failed health wait) pages.
DEPLOYED=0
trap 'rc=$?; [ "$DEPLOYED" = 1 ] || notify "❌ <b>miyagi</b> deploy FAILED (exit $rc) — ssh in and run update.sh; logs: docker compose logs"' EXIT

git -C "$ROOT" fetch -q origin main
git -C "$ROOT" reset -q --hard origin/main
echo "▶ repo at $(git -C "$ROOT" rev-parse --short HEAD)"

# set_env KEY VALUE — rewrite one managed line of .env, keeping a single .env.bak (the only other copy of
# this host's DB password).
set_env() {
  cp "$ENV_FILE" "$ENV_FILE.bak"
  if grep -q "^$1=" "$ENV_FILE"; then sed -i "s|^$1=.*|$1=$2|" "$ENV_FILE"; else echo "$1=$2" >> "$ENV_FILE"; fi
}

# resolve NAME TAG_REPO — the pinned image if .env has one, else :main resolved to its digest.
resolve() {
  local pin; pin="$(grep -E "^$1_PIN=" "$ENV_FILE" | tail -1 | cut -d= -f2- || true)"
  if [ -n "$pin" ]; then docker pull -q "$pin" >/dev/null; echo "$pin"; return; fi
  docker pull -q "$2:main" >/dev/null
  docker image inspect "$2:main" --format '{{index .RepoDigests 0}}'
}
MEDUSA_IMAGE="$(resolve MEDUSA_IMAGE ghcr.io/danybgoode/medusa-web)"
WEB_IMAGE="$(resolve WEB_IMAGE ghcr.io/danybgoode/miyagi-web)"
set_env MEDUSA_IMAGE "$MEDUSA_IMAGE"
set_env WEB_IMAGE "$WEB_IMAGE"
for img in "$MEDUSA_IMAGE" "$WEB_IMAGE"; do
  echo "  $img → commit $(docker image inspect "$img" --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' | cut -c1-7)"
done

docker compose up -d --remove-orphans

# The backup's own read-only role (pg_read_all_data) — backup.sh never dumps as the app's role. Idempotent;
# the password reaches psql by environment NAME (`-e` with no value, then \getenv), never on a command line.
BACKUP_RO_PASSWORD="$(grep '^BACKUP_RO_PASSWORD=' "$ENV_FILE" | cut -d= -f2-)" \
docker compose exec -T -e BACKUP_RO_PASSWORD postgres psql -q -v ON_ERROR_STOP=1 -U medusa -d medusa <<'SQL'
\getenv pw BACKUP_RO_PASSWORD
SELECT format('CREATE ROLE backup_ro LOGIN PASSWORD %L', :'pw')
  WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'backup_ro') \gexec
SELECT format('ALTER ROLE backup_ro PASSWORD %L', :'pw') \gexec
GRANT pg_read_all_data TO backup_ro;
SQL
echo "✓ backup_ro role"
# The site file goes into a directory the SHARED Caddy imports, so a bad one must never stay there: a
# failed reload keeps the old config live, but the next restart of panfleto's Caddy (its own deploy, a
# reboot) would not start, taking panfleto and aomx down with Miyagi (PR #209 review). Install, VALIDATE
# inside the running container, and put the previous file back on any failure.
SITE=/opt/edge/sites/miyagi.caddy
[ -f "$SITE" ] && cp "$SITE" "$SITE.prev"
install -m 0644 "$DEPLOY/miyagi.caddy" "$SITE"
if ! docker exec deploy-caddy-1 caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile >/dev/null 2>&1 \
   || ! docker exec deploy-caddy-1 caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile >/dev/null; then
  if [ -f "$SITE.prev" ]; then mv "$SITE.prev" "$SITE"; else rm -f "$SITE"; fi
  echo "✗ Caddy rejected miyagi.caddy — previous site file restored; Caddy is unchanged" >&2
  exit 1
fi
rm -f "$SITE.prev"
echo "✓ caddy validated + reloaded"

# Wait for both apps from INSIDE their containers — a 200 here is the app, not Caddy or Cloudflare.
wait_for() { # service url
  for _ in $(seq 1 60); do
    if docker compose exec -T "$1" node -e "fetch('$2').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))" 2>/dev/null; then
      echo "✓ $1 healthy"; return 0
    fi
    sleep 5
  done
  echo "✗ $1 did not become healthy in 5 min — docker compose logs $1" >&2; return 1
}
wait_for medusa http://127.0.0.1:8080/health
wait_for web http://127.0.0.1:8080/

DEPLOYED=1
WEB_REV="$(rev "$WEB_IMAGE")"; MEDUSA_REV="$(rev "$MEDUSA_IMAGE")"
notify "✅ <b>miyagi</b> deployed · 🚀
web <a href=\"https://github.com/danybgoode/miyagisanchezcommerce/commit/${WEB_REV}\"><code>${WEB_REV}</code></a> · medusa <a href=\"https://github.com/danybgoode/medusa-bonsai-backend/commit/${MEDUSA_REV}\"><code>${MEDUSA_REV}</code></a>"
echo "✓ deployed (Telegram notified)"
