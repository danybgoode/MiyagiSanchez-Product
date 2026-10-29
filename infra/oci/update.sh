#!/usr/bin/env bash
# Deploy Miyagi Sánchez (MiyagiSanchez-Storefront + MiyagiSanchez-Backend) on `panfleto-prod`: pull main, pin the newest arm64 images by digest, (re)start the stack,
# install the Caddy site file, reload Caddy, and wait for both apps to answer. Run ON the VM:
#   /opt/miyagi/infra/oci/update.sh
#
# Images: `ghcr.io/danybgoode/{miyagisanchez-backend,miyagisanchez-storefront}:main` is resolved to an
# immutable DIGEST and that digest is what runs — the moving tag never does. To roll back, pin an older sha in
# infra/oci/.env:
#   MEDUSA_IMAGE_PIN=ghcr.io/danybgoode/miyagisanchez-backend:<sha>      (or WEB_IMAGE_PIN=…, PRINT_PDF_IMAGE_PIN=…)
# (Until 2026-10-28 the images were `medusa-web` / `miyagi-web`; a pin to an old-name sha still works.)
# and re-run; delete the line to roll forward. A pin always wins over :main.
#
# When a commit changes THIS script, bash keeps reading the old inode — re-run it after the pull.
set -euo pipefail

ROOT=/opt/miyagi
DEPLOY="$ROOT/infra/oci"
ENV_FILE="$DEPLOY/.env"
cd "$DEPLOY"

for f in .env medusa.env web.env print.env; do
  [ -s "$f" ] || { echo "✗ infra/oci/$f is missing — restore it from Daniel's password manager (0600, owner ubuntu); bootstrap.sh's source is deleted" >&2; exit 1; }
done

# The renderer and the web app read PRINT_PDF_SECRET from two files. A missing or mismatched copy still passes the
# /health wait, then every PDF answers 401, so it is checked here. The values are compared, never printed.
secret_of() { grep -E '^PRINT_PDF_SECRET=' "$1" | tail -1 | cut -d= -f2- || true; }
if [ -z "$(secret_of print.env)" ] || [ "$(secret_of print.env)" != "$(secret_of web.env)" ]; then
  echo "✗ PRINT_PDF_SECRET must be set, and identical, in infra/oci/print.env and web.env" >&2; exit 1
fi

# Telegram: the 🚀 pair of each merge's 📦 (notify-telegram.yml in the app repos), one per app whose running
# commit CHANGED, mirroring that commit's subject and first paragraph (deploy-notice.sh). A re-run that changes
# nothing posts nothing. It went missing with Cloud Build, and from 10-16 to 10-28 a deploy said nothing. Same bot, chat and `curl -K -` (token never in argv) as backup.sh, read from backup.env in
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
# shellcheck source=infra/oci/deploy-notice.sh
. "$DEPLOY/deploy-notice.sh"
# rev IMAGE — the full commit an image was built from.
rev() { docker image inspect "$1" --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' 2>/dev/null || true; }
# running_rev SERVICE — the commit the CURRENT container of a compose service runs, or nothing.
running_rev() {
  local id; id="$(docker compose ps -q "$1" 2>/dev/null | head -1)"
  [ -n "$id" ] && docker inspect -f '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$id" 2>/dev/null || true
}
# notice REPO NEW PREV STATUS — the 🚀 for one app (deploy-notice.sh builds it; GitHub supplies the prose).
notice() { notify "$(dn_text "$1" "$2" "$3" "$4" "$(dn_commit_message "$1" "$2")" "$(dn_ahead "$1" "$3" "$2")")"; }
# Every way out that is not the success path below pages. Once the swap was ATTEMPTED, the notice reads what the
# containers actually run (a Compose that fails halfway can still have started one), and each app whose running
# commit changed gets its own 🚀 FAILED under its name, with its subject and paragraph; only a failure where nothing
# changed is one Miyagi Sánchez line (codex, PR #230).
DEPLOYED=0 SWAPPED=0 STEP="pulling the repo" FAILED_APP="" PREV_WEB="" PREV_MEDUSA=""
on_exit() {
  local rc=$? why cur_web cur_medusa changed=0
  [ "$DEPLOYED" = 1 ] && return
  if [ "$SWAPPED" != 1 ]; then notify "$(dn_fail_text "while ${STEP} (exit $rc)")"; return; fi
  cur_web="$(running_rev web)"; cur_medusa="$(running_rev medusa)"
  for app in web medusa; do
    if [ "$app" = web ]; then cur="$cur_web" prev="$PREV_WEB" repo="$STOREFRONT_REPO"; else cur="$cur_medusa" prev="$PREV_MEDUSA" repo="$BACKEND_REPO"; fi
    [ -n "$cur" ] && [ "$cur" != "$prev" ] || continue
    changed=$((changed + 1))
    if [ "$FAILED_APP" = "$app" ]; then why="${repo} did not pass its health check (exit $rc)"
    else why="the deploy did not finish while ${STEP} (exit $rc); ${repo} is running this commit"; fi
    notice "$repo" "$cur" "$prev" "fail:${why}"
  done
  [ "$changed" -gt 0 ] || notify "$(dn_fail_text "while ${STEP} (exit $rc)" "Storefront ${cur_web:0:7}, Backend ${cur_medusa:0:7}")"
}
trap on_exit EXIT

# The repository was renamed 2026-10-28 (GitHub redirects the old URL; this makes the clone say so).
git -C "$ROOT" remote set-url origin https://github.com/danybgoode/MiyagiSanchez-Product.git

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
# A FAILED PULL MUST FAIL THE DEPLOY. `resolve` runs inside `$(…)`, where bash does not inherit `set -e`, so a pull that
# timed out used to fall through to `image inspect` of the LOCALLY CACHED `:main` — the previous build — and the deploy
# reported success on the old commit (share-kit S1, 2026-10-28: GHCR timed out from the VM; it "deployed" 78e73d2 over
# the merge 3daba88). Every pull is checked, and the caller exits on a failed resolve.
resolve() {
  local pin; pin="$(grep -E "^$1_PIN=" "$ENV_FILE" | tail -1 | cut -d= -f2- || true)"
  if [ -n "$pin" ]; then docker pull -q "$pin" >/dev/null || { echo "✗ could not pull $pin" >&2; return 1; }; echo "$pin"; return; fi
  docker pull -q "$2:main" >/dev/null || { echo "✗ could not pull $2:main — refusing to deploy a cached image" >&2; return 1; }
  # The digest UNDER THIS NAME. One image can carry several (during the 2026-10-28 rename the same build was pushed
  # as miyagi-web and miyagisanchez-storefront), and RepoDigests[0] is whichever was pulled first, so the old name won.
  local digest
  digest="$(docker image inspect "$2:main" --format '{{range .RepoDigests}}{{println .}}{{end}}' | grep -m1 "^$2@" || true)"
  [ -n "$digest" ] || { echo "✗ no $2 digest after pulling $2:main" >&2; return 1; }
  echo "$digest"
}
STEP="pulling the images"
MEDUSA_IMAGE="$(resolve MEDUSA_IMAGE ghcr.io/danybgoode/miyagisanchez-backend)" || exit 1
WEB_IMAGE="$(resolve WEB_IMAGE ghcr.io/danybgoode/miyagisanchez-storefront)" || exit 1
# The PDF renderer (share-kit S2.1), built from the storefront repo's services/print-pdf. Pinned by digest like the others.
PRINT_PDF_IMAGE="$(resolve PRINT_PDF_IMAGE ghcr.io/danybgoode/miyagisanchez-print-pdf)" || exit 1
set_env MEDUSA_IMAGE "$MEDUSA_IMAGE"
set_env WEB_IMAGE "$WEB_IMAGE"
set_env PRINT_PDF_IMAGE "$PRINT_PDF_IMAGE"
for img in "$MEDUSA_IMAGE" "$WEB_IMAGE" "$PRINT_PDF_IMAGE"; do
  echo "  $img → commit $(docker image inspect "$img" --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' | cut -c1-7)"
done

# What runs NOW, before the swap: the "previous" each 🚀 names, and how a re-run that changes nothing stays quiet.
PREV_WEB="$(running_rev web)"; PREV_MEDUSA="$(running_rev medusa)"
STEP="starting the containers"
SWAPPED=1   # set BEFORE `up`: a Compose that fails halfway may already have started a new container
docker compose up -d --remove-orphans
STEP="creating the backup role"

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
STEP="installing the Caddy site file"
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
  FAILED_APP="$1"
  echo "✗ $1 did not become healthy in 5 min — docker compose logs $1" >&2; return 1
}
wait_for medusa http://127.0.0.1:8080/health
wait_for web http://127.0.0.1:8080/
wait_for print-pdf http://127.0.0.1:8080/health

DEPLOYED=1
WEB_REV="$(rev "$WEB_IMAGE")"; MEDUSA_REV="$(rev "$MEDUSA_IMAGE")"
sent=0
if [ "$WEB_REV" != "$PREV_WEB" ]; then notice "$STOREFRONT_REPO" "$WEB_REV" "$PREV_WEB" ok; sent=$((sent + 1)); fi
if [ "$MEDUSA_REV" != "$PREV_MEDUSA" ]; then notice "$BACKEND_REPO" "$MEDUSA_REV" "$PREV_MEDUSA" ok; sent=$((sent + 1)); fi
echo "✓ deployed — Storefront ${WEB_REV:0:7}, Backend ${MEDUSA_REV:0:7} (${sent} Telegram notice(s); an unchanged app posts none)"
