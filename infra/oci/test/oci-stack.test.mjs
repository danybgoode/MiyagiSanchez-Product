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
