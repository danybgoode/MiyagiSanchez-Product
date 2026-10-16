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

// services: block → { name: body }
const services = Object.fromEntries(
  compose
    .slice(compose.indexOf('\nservices:'), compose.indexOf('\nnetworks:'))
    .split(/\n  (?=[a-z]+:\n)/)
    .slice(1)
    .map((b) => [b.slice(0, b.indexOf(':')), b]),
)

test('the four services were parsed (a vacuous loop asserts nothing)', () => {
  assert.deepEqual(Object.keys(services).sort(), ['medusa', 'postgres', 'redis', 'web'])
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

test('dark-period backups never share the prod prefix; every failure path alerts', () => {
  const b = read('backup.sh')
  assert.match(b, /KEY="\$\{BACKUP_PREFIX:-medusa-oci\}\//)
  assert.match(b, /trap 'alert "unexpected failure at line \$LINENO"' ERR/)
  assert.match(read('bootstrap.sh'), /BACKUP_PREFIX='medusa-oci'/)
})

test('no secret reaches argv in update.sh or bootstrap.sh', () => {
  assert.doesNotMatch(read('update.sh'), /-v pw="/)
  assert.match(read('update.sh'), /\\getenv pw BACKUP_RO_PASSWORD/)
  assert.doesNotMatch(read('bootstrap.sh'), /-H "Authorization: Bearer \$CF_TOKEN"/)
})
