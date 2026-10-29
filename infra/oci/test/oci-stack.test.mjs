// miyagi-to-oracle-vm S1.3/S1.6 — invariants of Miyagi's stack on the SHARED Oracle VM `panfleto-prod`.
//
// Each assertion is a rule whose breakage would hurt something other than Miyagi, or would fail silently:
// a published port bypasses the one Caddy; an uncapped container can starve panfleto; a dark copy running
// Medusa's jobs talks to the real world with production credentials; a Caddy upstream that names a
// container alias nobody declares is a 502 only visible after DNS moves; a cron timer whose schedule
// drifted from Cloud Scheduler's moves a daily email by hours. Plain text checks, no YAML dependency.

import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const OCI = path.join(path.dirname(fileURLToPath(import.meta.url)), '..')
const read = (f) => fs.readFileSync(path.join(OCI, f), 'utf8')
const compose = read('docker-compose.yml')
const caddy = read('miyagi.caddy')
const update = read('update.sh')

// services: block → { name: body }
const services = Object.fromEntries(
  compose
    .slice(compose.indexOf('\nservices:'), compose.indexOf('\nnetworks:'))
    .split(/\n  (?=[a-z][a-z-]*:\n)/)
    .slice(1)
    .map((b) => [b.slice(0, b.indexOf(':')), b]),
)

test('the five services were parsed (a vacuous loop asserts nothing)', () => {
  assert.deepEqual(Object.keys(services).sort(), ['medusa', 'postgres', 'print-pdf', 'redis', 'web'])
})

test('the PDF renderer is reachable only from inside the stack (share-kit S2.1)', () => {
  const body = services['print-pdf']
  assert.doesNotMatch(body, /edge/, 'print-pdf must never join the shared edge network')
  assert.doesNotMatch(body, /ports:/)
  assert.match(body, /\n    networks: \[miyagi\]\n/)
  assert.match(body, /env_file: \[\.\/print\.env\]/)
})

test('update.sh pins the renderer by digest, requires its env file, and waits for it', () => {
  assert.match(update, /PRINT_PDF_IMAGE="\$\(resolve PRINT_PDF_IMAGE ghcr\.io\/danybgoode\/miyagisanchez-print-pdf\)"/)
  assert.match(update, /for f in \.env medusa\.env web\.env print\.env; do/)
  assert.match(update, /wait_for print-pdf http:\/\/127\.0\.0\.1:8080\/health/)
})

test('nothing publishes a port — the shared Caddy is the only public entrypoint', () => {
  assert.doesNotMatch(compose, /^\s+ports:/m)
})

test('every service has a memory and CPU cap', () => {
  for (const [name, body] of Object.entries(services)) {
    assert.match(body, /\n    mem_limit: \d+m\n/, `${name} has no mem_limit`)
    assert.match(body, /\n    cpus: [\d.]+\n/, `${name} has no cpus cap`)
  }
})

test('the caps fit beside panfleto (≤ 5 GB of the 12 GB box)', () => {
  const mb = [...compose.matchAll(/mem_limit: (\d+)m/g)].reduce((s, m) => s + Number(m[1]), 0)
  assert.ok(mb <= 5120, `${mb} MB of caps`)
})

test('Medusa defaults to server mode — no jobs or subscribers until the cutover sets it', () => {
  assert.match(services.medusa, /MEDUSA_WORKER_MODE: \$\{MEDUSA_WORKER_MODE:-server\}/)
})

test('Postgres and Redis are not on the shared edge network', () => {
  for (const name of ['postgres', 'redis']) assert.doesNotMatch(services[name], /edge/)
})

test('every Caddy upstream is an edge alias the compose file declares', () => {
  const upstreams = [...caddy.matchAll(/reverse_proxy (\S+):8080/g)].map((m) => m[1])
  assert.ok(upstreams.length >= 3)
  const aliases = [...compose.matchAll(/aliases: \[([^\]]+)\]/g)].flatMap((m) => m[1].split(',').map((s) => s.trim()))
  for (const u of upstreams) assert.ok(aliases.includes(u), `caddy proxies to ${u}, which no service declares`)
})

test('the API host goes to Medusa, everything else to the storefront', () => {
  assert.match(caddy, /api\.miyagisanchez\.com \{[^}]*reverse_proxy miyagi-medusa:8080/)
  assert.match(caddy, /miyagisanchez\.com, \*\.miyagisanchez\.com \{[^}]*reverse_proxy miyagi-web:8080/)
})

test('TLS is the Cloudflare Origin CA cert from /etc/caddy/certs, never ACME, on every site', () => {
  const sites = caddy.split(/\n(?=\S[^\n]*\{\n)/).filter((b) => /reverse_proxy/.test(b))
  for (const s of sites) assert.match(s, /tls \/etc\/caddy\/certs\/\w+\.pem \/etc\/caddy\/certs\/\w+\.key/, s.split('\n')[0])
})

// The Cloud Scheduler jobs, measured live 2026-10-15 (`gcloud scheduler jobs list`, all UTC).
const CLOUD_SCHEDULER = {
  'launchpad-campaigns': '06',
  'domain-lapse-sweep': '07',
  'print-pending': '08',
  'order-autoconfirm': '09',
  'merchant-lifecycle-sweep': '10',
  // Born on the VM (prompt-to-shop S5.4, D19): never a Cloud Scheduler job. 15:00 UTC = 09:00 Mexico City.
  'p2s-nudges': '15',
}

test('one timer per Cloud Scheduler cron, at the same UTC hour, calling the same route', () => {
  const timers = fs.readdirSync(path.join(OCI, 'systemd')).filter((f) => f.startsWith('miyagi-cron-'))
  assert.equal(timers.length, Object.keys(CLOUD_SCHEDULER).length)
  for (const [name, hour] of Object.entries(CLOUD_SCHEDULER)) {
    const t = read(`systemd/miyagi-cron-${name}.timer`)
    assert.match(t, new RegExp(`OnCalendar=\\*-\\*-\\* ${hour}:00:00 UTC`), name)
    assert.match(t, new RegExp(`Unit=miyagi-cron@${name}\\.service`), name)
  }
  assert.match(read('systemd/miyagi-cron@.service'), /\/api\/cron\/%i'.*'x-cron-secret':process\.env\.CRON_SECRET/)
})

test('install-host enables backups but NOT the cron timers (no double-run with Cloud Scheduler)', () => {
  const install = read('install-host.sh')
  assert.match(install, /systemctl enable --now miyagi-backup\.timer miyagi-restore-drill\.timer/)
  assert.doesNotMatch(install, /enable[^\n]*miyagi-cron/)
})

test('the backup dumps as the read-only role and writes to both vendors', () => {
  const backup = read('backup.sh')
  assert.match(backup, /-U backup_ro medusa/)
  assert.match(backup, /rclone copyto/)
  assert.match(backup, /oci os object put --auth instance_principal/)
  assert.match(read('update.sh'), /GRANT pg_read_all_data TO backup_ro/)
})

test('the restore drill fails when EITHER side cannot be counted (PR #209 review)', () => {
  const drill = read('restore-drill.sh')
  assert.match(drill, /\[ "\$r" = "\?" \] \|\| \[ "\$l" = "\?" \]/)
  assert.match(drill, /\[ -n "\$LIVE" \] \|\| fail/)
})

test('install-host fails loud without the OCI CLI the backup needs (PR #209 review)', () => {
  assert.match(read('install-host.sh'), /command -v oci >\/dev\/null \|\| \{/)
})

test('no secret reaches argv: PGPASSWORD by name only, the Telegram token via curl -K - (PR #209 security review)', () => {
  for (const f of ['backup.sh', 'restore-drill.sh']) {
    const s = read(f)
    assert.doesNotMatch(s, /api\.telegram\.org\/bot\$\{TELEGRAM_BOT_TOKEN\}[^\n]*\n?[^\n]*curl|curl[^|]*api\.telegram\.org\/bot\$/, `${f} puts the bot token on curl's command line`)
    assert.match(s, /\| curl [^\n]*-K -/, f)
  }
  assert.doesNotMatch(read('backup.sh'), /-e PGPASSWORD="/)
})

// ── PR #209 fresh-review fixes ────────────────────────────────────────────────────────────────────────────
test('miyagi.caddy names every host it serves — no catch-all that hijacks the shared Caddy\'s TLS', () => {
  // An `https://` (or `:443`, `*`, `https://*`) site block became a matcher-less TLS policy pinned to Miyagi's
  // cert, and panfleto.win / aomx's host were served CN=miyagisanchez.com — reproduced with openssl.
  const addresses = [...caddy.matchAll(/^([^\s#(][^{\n]*)\{\s*$/gm)].map((m) => m[1].trim())
  assert.ok(addresses.length >= 3, 'site blocks were parsed')
  for (const a of addresses) {
    for (const host of a.split(',').map((h) => h.trim())) {
      assert.match(host, /^(\*\.)?[a-z0-9-]+(\.[a-z0-9-]+)+$/, `"${host}" is not a named host`)
    }
  }
  assert.doesNotMatch(read('miyagi.caddy'), /fallback_sni/)
})

test('the upstreams receive the real client IP, not the Cloudflare edge', () => {
  assert.match(caddy, /header_up X-Real-IP \{http\.request\.header\.CF-Connecting-IP\}/)
  assert.match(caddy, /header_up X-Forwarded-For \{http\.request\.header\.CF-Connecting-IP\}/)
  const proxies = [...caddy.matchAll(/reverse_proxy \S+ \{\n\s+import miyagi_upstream/g)].length
  assert.equal(proxies, [...caddy.matchAll(/reverse_proxy /g)].length, 'a reverse_proxy without miyagi_upstream')
})

test('CPU caps leave the 2-OCPU box at least a quarter core for panfleto', () => {
  const cpus = [...compose.matchAll(/\n    cpus: ([\d.]+)/g)].reduce((s, m) => s + Number(m[1]), 0)
  assert.ok(cpus <= 1.75 + 1e-9, `${cpus} CPUs of caps`)
})

test('update.sh validates the site file inside Caddy and restores the previous one on failure', () => {
  const u = read('update.sh')
  assert.match(u, /caddy validate --config \/etc\/caddy\/Caddyfile/)
  assert.match(u, /mv "\$SITE\.prev" "\$SITE"; else rm -f "\$SITE"/)
  assert.ok(u.indexOf('caddy validate') < u.indexOf('caddy reload'), 'validate runs before reload')
})

test('since the cutover the backup writes the PROD prefix, by default and from bootstrap; every failure alerts', () => {
  // The dark period wrote `medusa-oci/`; on 2026-10-16 this VM became prod. A provisioner default IS the live
  // config, so neither the script's fallback nor bootstrap may name the dark-period prefix any more.
  const b = read('backup.sh')
  assert.match(b, /ship medusa "\$\{BACKUP_PREFIX:-medusa\}"/)
  assert.doesNotMatch(b + read('bootstrap.sh'), /BACKUP_PREFIX='medusa-oci'|:-medusa-oci\}/)
  assert.match(read('bootstrap.sh'), /BACKUP_PREFIX='medusa'/)
  assert.match(b, /trap 'alert "unexpected failure at line \$LINENO"' ERR/)
  assert.match(b, /^set -Eeuo pipefail$/m, 'errtrace: the ERR trap must reach inside ship()')
})

test('the VM also backs up Supabase, under the GCP job\'s own `supabase/` prefix (one continuous series)', () => {
  const b = read('backup.sh')
  assert.match(b, /ship supabase supabase\n/)
  assert.match(b, /\[ -n "\$\{SUPABASE_BACKUP_DSN:-\}" \] \|\| alert/)
  assert.match(read('bootstrap.sh'), /TELEGRAM_CICD_CHAT_ID \\\n\s+SUPABASE_BACKUP_DSN; do/)
})

test('the Supabase DSN never reaches argv: split into PG* vars, passed to the container by NAME', () => {
  const b = read('backup.sh')
  assert.match(b, /docker compose exec -T -e PGHOST -e PGPORT -e PGUSER -e PGPASSWORD -e PGDATABASE -e PGSSLMODE \\/)
  assert.doesNotMatch(b, /pg_dump[^\n]*(--dbname|-d )/)
  assert.doesNotMatch(b, /-e PG[A-Z]+=/)
  // `eval "$(cmd)"` evaluates "" when cmd fails and exits 0 — the parse must be captured, checked, then eval'd.
  assert.match(b, /SB_ENV="\$\(SUPABASE_BACKUP_DSN=/)
  assert.match(b, /\|\| alert "SUPABASE_BACKUP_DSN does not parse"\neval "\$SB_ENV"/)
})

test('bootstrap never rebuilds medusa.env / web.env on a full run — their Cloud Run sources are deleted', () => {
  const b = read('bootstrap.sh')
  assert.match(b, /\nif \[ "\$ONLY" = env \]; then\n/)
  assert.doesNotMatch(b, /\nif want env; then/)
  assert.match(b, /\nif want backup-env; then\n/)
})

test('no secret reaches argv in update.sh or bootstrap.sh', () => {
  assert.doesNotMatch(read('update.sh'), /-v pw="/)
  assert.match(read('update.sh'), /\\getenv pw BACKUP_RO_PASSWORD/)
  assert.doesNotMatch(read('bootstrap.sh'), /-H "Authorization: Bearer \$CF_TOKEN"/)
})

test('bootstrap writes the PROD_-prefixed names image-arm64.yml reads (PR #432 review)', () => {
  const b = read('bootstrap.sh')
  assert.match(b, /gh variable set "PROD_\$s" --env production/)
  assert.match(b, /gh variable set PROD_NEXT_PUBLIC_SUPABASE_URL --env production/)
  assert.doesNotMatch(b, /gh variable set "\$s"/)
})

test('a missing dump reaches the drill\'s alert instead of dying in pipefail (PR #209 review)', () => {
  assert.match(read('restore-drill.sh'), /DUMP="\$\(ls -1t [^\n]*\| head -1 \|\| true\)"/)
})

test('Medusa\'s DATABASE_URL disables TLS — Medusa forces TLS on any non-localhost URL otherwise', () => {
  assert.match(services.medusa, /DATABASE_URL: postgres:\/\/[^\n]*@postgres:5432\/medusa\?sslmode=disable\n/)
})

test('update.sh pings Telegram on every deploy: 🚀 per changed app on success, ❌ on every other way out, token never in argv', () => {
  const u = read('update.sh')
  // The success notices are the LAST thing the script does, after both health waits.
  assert.ok(u.lastIndexOf('notice "$STOREFRONT_REPO" "$WEB_REV"') > u.lastIndexOf('wait_for web'), 'success notice must follow the health waits')
  assert.ok(u.indexOf('DEPLOYED=1') > u.lastIndexOf('wait_for web'), 'DEPLOYED=1 only after the health waits')
  // Only an app whose running commit CHANGED posts — a re-run that changes nothing stays quiet.
  assert.match(u, /if \[ "\$WEB_REV" != "\$PREV_WEB" \]; then notice/)
  assert.match(u, /if \[ "\$MEDUSA_REV" != "\$PREV_MEDUSA" \]; then notice/)
  // "previous" is read BEFORE the swap.
  assert.ok(u.indexOf('PREV_WEB="$(running_rev web)"') < u.indexOf('docker compose up -d'), 'previous revisions are read before the swap')
  // An EXIT trap, not ERR: the Caddy rollback path leaves with an explicit `exit 1`, which ERR never sees.
  assert.match(u, /trap on_exit EXIT/)
  // Swap state is set BEFORE `up` (a half-failed Compose may have started one), and a post-swap failure reads what
  // actually runs, with a per-app 🚀 FAILED for every app that changed (codex, PR #230).
  assert.ok(u.indexOf('SWAPPED=1') < u.indexOf('docker compose up -d'), 'SWAPPED=1 is set before compose up')
  assert.match(u, /cur_web="\$\(running_rev web\)"; cur_medusa="\$\(running_rev medusa\)"/)
  assert.match(u, /notice "\$repo" "\$cur" "\$prev" "fail:\$\{why\}"/)
  assert.match(u, /curl -s -m 10 -o \/dev\/null -K -/)
  assert.doesNotMatch(u, /bot\$\{?TELEGRAM_BOT_TOKEN\}?\/sendMessage" *\\?\n?\s*--data/)
  assert.match(u, /\) \|\| true\n\}/, 'a Telegram failure never fails the deploy')
  // The brand and the app names, never the old ones (Daniel, 2026-10-28).
  assert.doesNotMatch(u + read('deploy-notice.sh'), /<b>miyagi<\/b>|miyagisanchezcommerce|medusa-bonsai-backend|ghcr\.io\/danybgoode\/(miyagi-web|medusa-web):main/)
})

test('resolve picks the digest under the REQUESTED name, never RepoDigests[0] (the 2026-10-28 rename kept the old name)', () => {
  const u = read('update.sh')
  assert.doesNotMatch(u, /index \.RepoDigests 0/)
  assert.match(u, /grep -m1 "\^\$2@"/)
})

test('a failed image pull fails the deploy instead of pinning the cached :main (share-kit S1, 2026-10-28)', () => {
  const update = read('update.sh')
  const fn = update.slice(update.indexOf('resolve() {'), update.indexOf('\n}\n', update.indexOf('resolve() {')))
  assert.match(fn, /docker pull -q "\$pin" >\/dev\/null \|\| \{[^}]*return 1; \}/)
  assert.match(fn, /docker pull -q "\$2:main" >\/dev\/null \|\| \{[^}]*return 1; \}/)
  for (const name of ['MEDUSA_IMAGE', 'WEB_IMAGE', 'PRINT_PDF_IMAGE']) {
    assert.match(update, new RegExp(`${name}="\\$\\(resolve ${name} [^)]+\\)" \\|\\| exit 1`), name)
  }
})

test('the renderer secret must be set and identical in print.env and web.env, never echoed (share-kit S2.1)', () => {
  assert.match(update, /secret_of\(\) \{ grep -E '\^PRINT_PDF_SECRET=' "\$1"/)
  assert.match(update, /\[ -z "\$\(secret_of print\.env\)" \] \|\| \[ "\$\(secret_of print\.env\)" != "\$\(secret_of web\.env\)" \]/)
  assert.doesNotMatch(update, /echo[^\n]*\$\(secret_of/)
})
