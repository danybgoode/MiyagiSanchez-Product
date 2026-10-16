#!/usr/bin/env bash
# Workstation-side bootstrap for Miyagi on the Oracle VM — the ONE step that moves credentials.
# Run by Daniel from the medusa-bonsai checkout (gcloud on lolis-profile, gh authed, OCI CLI configured):
#   bash infra/oci/bootstrap.sh            # everything below, idempotent
#   bash infra/oci/bootstrap.sh --only env # just rewrite medusa.env / web.env / backup.env
#
# It reads every value AS THE OPERATOR and streams it over ssh into 0600 files on the VM owned by the deploy
# user `ubuntu` — the account docker compose reads env_file as, and already root-equivalent through its
# `docker` group membership, so no other account on the box can read them. Nothing
# is printed, nothing is written to this machine's disk, and .env.local is never a source (it caused the
# 2026-07-13 outage — LEARNINGS). What it does:
#   1. clones/updates /opt/miyagi (this public repo) on the VM and runs install-host.sh;
#   2. infra/oci/.env        — POSTGRES_PASSWORD + BACKUP_RO_PASSWORD, generated ON the VM once;
#   3. infra/oci/medusa.env  — medusa-web's Cloud Run env: plain values from the service, secrets from
#      Secret Manager by the exact mapping the service uses (minus DATABASE_URL/REDIS_URL/PORT/
#      MEDUSA_WORKER_MODE, which the compose file owns);
#   4. infra/oci/web.env     — the same for miyagi-web (MEDUSA_STORE_URL is overridden by compose);
#   5. infra/oci/backup.env  — the R2 escrow token + Telegram, for backup.sh / restore-drill.sh;
#   6. Cloudflare Origin CA certs for miyagisanchez.com (+ wildcard) and mschz.org (+ www) — the key and
#      CSR are generated ON the VM, only the CSR travels, so the private keys never leave it;
#   7. the 8 browser-public NEXT_PUBLIC_* keys into the frontend repo's `production` GitHub Environment as
#      PROD_NEXT_PUBLIC_* (the prefix stops a missing value falling back to the repo-level CI variable),
#      which image-arm64.yml builds from.
set -euo pipefail

PROJECT="${PROJECT:-miyagisanchez-prod}"
REGION="${REGION:-us-east4}"
VM="${VM:-ubuntu@159.54.158.4}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/panfleto_oci}"
WEB_REPO="${WEB_REPO:-danybgoode/miyagisanchezcommerce}"
ONLY="${2:-}"; [ "${1:-}" = "--only" ] || ONLY=""

ssh_vm() { ssh -i "$SSH_KEY" -o ConnectTimeout=15 "$VM" "$@"; }
step() { printf '\n\033[1;36m▶ %s\033[0m\n' "$*"; }
want() { [ -z "$ONLY" ] || [ "$ONLY" = "$1" ]; }

# write_vm PATH — stdin → a 0600 file on the VM, atomically (re-owned to `ubuntu` below; see the header).
write_vm() { ssh_vm "sudo install -m 0600 -o root -g root /dev/stdin '$1.tmp' && sudo mv '$1.tmp' '$1'"; }

# service_env SERVICE SKIP_REGEX — the service's env as KEY='value' lines: plain values as Cloud Run holds
# them, secret refs resolved from Secret Manager (the ref's own secret name + version, e.g.
# TELEGRAM_CHAT_ID ← TELEGRAM_CHAT_ID_APP). Fails on any value compose cannot carry safely.
service_env() {
  gcloud run services describe "$1" --region "$REGION" --project "$PROJECT" --format=json \
    | python3 -c '
import json, re, subprocess, sys
skip = re.compile(sys.argv[2])
c = json.load(sys.stdin)["spec"]["template"]["spec"]["containers"][0]
out = []
for e in c.get("env", []):
    k = e["name"]
    if skip.fullmatch(k):
        continue
    if "valueFrom" in e:
        ref = e["valueFrom"]["secretKeyRef"]
        v = subprocess.run(["gcloud", "secrets", "versions", "access", ref.get("key", "latest"),
                            "--secret", ref["name"], "--project", sys.argv[1]],
                           capture_output=True, text=True, check=True).stdout
    else:
        v = e.get("value", "")
    if "\n" in v.rstrip("\n") or "\x27" in v:
        sys.exit(f"✗ {k}: value has a newline or single quote; compose env_file cannot carry it as-is")
    out.append(f"{k}=\x27{v.rstrip(chr(10))}\x27")
print("\n".join(out))
print(f"# {len(out)} vars from Cloud Run service — written by infra/oci/bootstrap.sh", file=sys.stderr)
' "$PROJECT" "$2"
}

secret() { gcloud secrets versions access latest --secret "$1" --project "$PROJECT"; }

if want repo; then
  step "VM checkout + host setup"
  ssh_vm 'set -e
    if [ ! -d /opt/miyagi/.git ]; then
      sudo install -d -o ubuntu -g ubuntu /opt/miyagi
      git clone -q https://github.com/danybgoode/miyagi-product-management.git /opt/miyagi
    fi
    git -C /opt/miyagi fetch -q origin main && git -C /opt/miyagi reset -q --hard origin/main
    sudo /opt/miyagi/infra/oci/install-host.sh'
fi

if want env; then
  step "infra/oci/.env (DB passwords generated on the VM, once)"
  ssh_vm 'set -e; F=/opt/miyagi/infra/oci/.env
    sudo test -s "$F" || { printf "POSTGRES_PASSWORD=%s\nBACKUP_RO_PASSWORD=%s\n" "$(openssl rand -hex 24)" "$(openssl rand -hex 24)" | sudo install -m 0600 /dev/stdin "$F"; }
    sudo grep -q "^BACKUP_RO_PASSWORD=" "$F" || printf "BACKUP_RO_PASSWORD=%s\n" "$(openssl rand -hex 24)" | sudo tee -a "$F" >/dev/null
    sudo chown ubuntu "$F"'
  # Each file is BUFFERED and checked before it is written: piping straight into write_vm would replace a good
  # file with an empty or partial one when gcloud / a secret read failed mid-stream (pipefail only reports
  # afterwards), and a failed $(secret …) inside a printf argument does not trip `set -e` at all.
  step "medusa.env ← Cloud Run medusa-web"
  BUF="$(service_env medusa-web 'DATABASE_URL|REDIS_URL|PORT|MEDUSA_WORKER_MODE')"
  printf '%s\n' "$BUF" | grep -q "^STRIPE_SECRET_KEY='sk_" || { echo "✗ medusa.env looks incomplete — not written" >&2; exit 1; }
  printf '%s\n' "$BUF" | write_vm /opt/miyagi/infra/oci/medusa.env
  step "web.env ← Cloud Run miyagi-web"
  BUF="$(service_env miyagi-web 'PORT|MEDUSA_STORE_URL')"
  printf '%s\n' "$BUF" | grep -q "^CRON_SECRET='." || { echo "✗ web.env looks incomplete — not written" >&2; exit 1; }
  printf '%s\n' "$BUF" | write_vm /opt/miyagi/infra/oci/web.env
  step "backup.env ← R2 escrow token + Telegram"
  BUF="$(printf "R2_BACKUP_BUCKET='miyagi-db-escrow'\nOCI_BUCKET='miyagi-backups'\nBACKUP_PREFIX='medusa-oci'")"
  for s in R2_BACKUP_ACCESS_KEY_ID R2_BACKUP_SECRET_ACCESS_KEY R2_BACKUP_ENDPOINT TELEGRAM_BOT_TOKEN TELEGRAM_CICD_CHAT_ID; do
    v="$(secret "$s")"; [ -n "$v" ] || { echo "✗ secret $s is empty — backup.env not written" >&2; exit 1; }
    BUF="$BUF"$'\n'"$s='$v'"
  done
  printf '%s\n' "$BUF" | write_vm /opt/miyagi/infra/oci/backup.env
  # backup.sh reads BACKUP_RO_PASSWORD from backup.env; keep it in step with .env without it passing here.
  ssh_vm 'P=$(sudo grep "^BACKUP_RO_PASSWORD=" /opt/miyagi/infra/oci/.env | cut -d= -f2); printf "BACKUP_RO_PASSWORD=%s\n" "$P" | sudo tee -a /opt/miyagi/infra/oci/backup.env >/dev/null'
  ssh_vm 'sudo chown ubuntu /opt/miyagi/infra/oci/{medusa,web,backup}.env'
fi

if want certs; then
  step "Cloudflare Origin CA certs (keys generated on the VM)"
  CF_TOKEN="$(secret CLOUDFLARE_API_TOKEN)"
  issue() { # name hostnames(csv)
    if ssh_vm "sudo test -s /opt/edge/certs/$1.pem"; then echo "  $1.pem exists — skipped (delete it on the VM to reissue)"; return; fi
    local san csr body
    san="$(echo "$2" | tr ',' '\n' | sed 's/^/DNS:/' | paste -sd, -)"
    csr="$(ssh_vm "sudo openssl req -new -newkey rsa:2048 -nodes -keyout /opt/edge/certs/$1.key -subj '/CN=${2%%,*}' -addext 'subjectAltName=$san' 2>/dev/null")"   # key stays 0600 root: Caddy runs as root
    body="$(python3 -c 'import json,sys; print(json.dumps({"hostnames": sys.argv[1].split(","), "requested_validity": 5475, "request_type": "origin-rsa", "csr": sys.stdin.read()}))' "$2" <<<"$csr")"
    # The token goes to curl as a config on stdin, never in argv.
    printf 'header = "Authorization: Bearer %s"\n' "$CF_TOKEN" \
      | curl -fsS -K - https://api.cloudflare.com/client/v4/certificates \
      -H 'Content-Type: application/json' --data "$body" \
      | python3 -c 'import json,sys; j=json.load(sys.stdin); assert j["success"], j["errors"]; print(j["result"]["certificate"])' \
      | ssh_vm "sudo install -m 0644 /dev/stdin /opt/edge/certs/$1.pem"
    echo "  ✓ $1 issued for $2"
  }
  issue miyagisanchez 'miyagisanchez.com,*.miyagisanchez.com'
  issue mschz 'mschz.org,www.mschz.org'
fi

if want gh; then
  step "production GitHub Environment ← the 8 browser-public keys ($WEB_REPO)"
  for s in NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY NEXT_PUBLIC_MEDUSA_MXN_REGION_ID \
           NEXT_PUBLIC_MP_PUBLIC_KEY NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY NEXT_PUBLIC_SUPABASE_ANON_KEY \
           NEXT_PUBLIC_VAPID_PUBLIC_KEY; do
    secret "$s" | gh variable set "PROD_$s" --env production -R "$WEB_REPO"
  done
  # cloudbuild.yaml feeds NEXT_PUBLIC_SUPABASE_URL from the SUPABASE_URL secret.
  secret SUPABASE_URL | gh variable set PROD_NEXT_PUBLIC_SUPABASE_URL --env production -R "$WEB_REPO"
  echo "  ✓ 8 variables set"
fi

step "done — next, on the VM: /opt/miyagi/infra/oci/update.sh"
