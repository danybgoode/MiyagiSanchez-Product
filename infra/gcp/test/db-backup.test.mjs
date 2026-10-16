// miyagi-to-oracle-vm S1.1 — the db-backup job's target dispatch. Until 2026-10-15 the job ran
// BACKUP_TARGETS=supabase,neon: it dumped the abandoned Neon copy and never the live Cloud SQL commerce
// DB, so the one dataset that matters had no copy outside GCP — and nothing failed to say so.
//
// This runs the REAL infra/gcp/backups/db-backup.sh with stub `pg_dump` and `rclone` on PATH (gzip,
// date and mktemp are the real ones), so what is asserted is the script's own behaviour: which DSN each
// target dumps, where the object lands, and that a stale target fails loud instead of passing quietly.

import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'
import { spawnSync } from 'node:child_process'
import { fileURLToPath } from 'node:url'

const HERE = path.dirname(fileURLToPath(import.meta.url))
const BACKUPS = path.join(HERE, '..', 'backups')
const SCRIPT = path.join(BACKUPS, 'db-backup.sh')
const PROVISION = path.join(BACKUPS, 'provision-db-backup.sh')

// pg_dump: record the DSN it was handed, emit 4 KB of incompressible bytes (the script rejects a
// gzipped dump under 1000 bytes as "suspiciously small"). rclone: `copyto` stores the object under a
// flattened key and logs the key; `size` reports the stored object's bytes as rclone's JSON does.
const PG_DUMP = `#!/usr/bin/env bash
for a in "$@"; do case "$a" in --dbname=*) echo "\${a#--dbname=}" >> "$STUB_LOG/dsns";; esac; done
head -c 4096 /dev/urandom
`
const RCLONE = `#!/usr/bin/env bash
key() { echo "$1" | tr '/:' '__'; }
case "$1" in
  copyto) cp "$2" "$STUB_LOG/obj_$(key "$3")"; echo "$3" >> "$STUB_LOG/keys" ;;
  size)   f="$STUB_LOG/obj_$(key "$2")"; [ -f "$f" ] && printf '{"count":1,"bytes":%s}' "$(wc -c < "$f" | tr -d ' ')" ;;
esac
`

function run(env) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'db-backup-test-'))
  const bin = path.join(dir, 'bin')
  const log = path.join(dir, 'log')
  fs.mkdirSync(bin)
  fs.mkdirSync(log)
  fs.writeFileSync(path.join(bin, 'pg_dump'), PG_DUMP, { mode: 0o755 })
  fs.writeFileSync(path.join(bin, 'rclone'), RCLONE, { mode: 0o755 })
  const r = spawnSync('bash', [SCRIPT], {
    encoding: 'utf8',
    env: {
      PATH: `${bin}:${process.env.PATH}`,
      STUB_LOG: log,
      R2_BACKUP_BUCKET: 'escrow',
      R2_BACKUP_ACCESS_KEY_ID: 'k',
      R2_BACKUP_SECRET_ACCESS_KEY: 's',
      R2_BACKUP_ENDPOINT: 'https://example.invalid',
      ...env,
    },
  })
  const read = (f) => (fs.existsSync(path.join(log, f)) ? fs.readFileSync(path.join(log, f), 'utf8').trim().split('\n') : [])
  return { code: r.status, out: r.stdout + r.stderr, dsns: read('dsns'), keys: read('keys') }
}

test('medusa target dumps MEDUSA_BACKUP_DSN and lands under medusa/YYYY/MM/DD/', () => {
  const r = run({ BACKUP_TARGETS: 'medusa', MEDUSA_BACKUP_DSN: 'postgres://app@10.0.0.3/medusa' })
  assert.equal(r.code, 0, r.out)
  assert.deepEqual(r.dsns, ['postgres://app@10.0.0.3/medusa'])
  assert.equal(r.keys.length, 1)
  assert.match(r.keys[0], /^r2:escrow\/medusa\/\d{4}\/\d{2}\/\d{2}\/medusa-[0-9TZ-]+\.dump\.gz$/)
})

test('supabase,medusa dumps both, each with its own DSN', () => {
  const r = run({ BACKUP_TARGETS: 'supabase,medusa', SUPABASE_BACKUP_DSN: 'postgres://ro@sb/postgres', MEDUSA_BACKUP_DSN: 'postgres://app@pg/medusa' })
  assert.equal(r.code, 0, r.out)
  assert.deepEqual(r.dsns, ['postgres://ro@sb/postgres', 'postgres://app@pg/medusa'])
  assert.deepEqual(r.keys.map((k) => k.split('/')[1]), ['supabase', 'medusa'])
})

test('a missing DSN fails the run but the other target still gets its dump', () => {
  // Under bash 3.2 a `${DSN:?}` at the call site exited 0 here, a green run that dumped nothing; under
  // bash 5 it aborted the run before the next target. Both shapes are wrong.
  const r = run({ BACKUP_TARGETS: 'medusa,supabase', SUPABASE_BACKUP_DSN: 'postgres://ro@sb/postgres' })
  assert.equal(r.code, 1, r.out)
  assert.match(r.out, /medusa DSN is not set/)
  assert.deepEqual(r.keys.map((k) => k.split('/')[1]), ['supabase'])
})

test('a stale `neon` target now fails loud instead of dumping the abandoned copy', () => {
  const r = run({ BACKUP_TARGETS: 'neon', NEON_BACKUP_DSN: 'postgres://ro@neon/neondb' })
  assert.equal(r.code, 1)
  assert.match(r.out, /unknown BACKUP_TARGET 'neon'/)
  assert.deepEqual(r.dsns, [])
})

test('the provisioner is Supabase-only: Medusa, its DSN and the deleted VPC connector are gone (miyagi-to-oracle-vm S3)', () => {
  // The provisioner default IS the live config. On 2026-10-16 Cloud SQL + `medusa-conn` were deleted and the VM
  // took over the Medusa dump; a re-run with the old default would fail on the connector or bind a dead DSN.
  const src = fs.readFileSync(PROVISION, 'utf8')
  assert.match(src, /BACKUP_TARGETS="\$\{BACKUP_TARGETS:-supabase\}"/)
  assert.doesNotMatch(src, /MEDUSA_BACKUP_DSN=|--vpc-connector|medusa-conn"/)
  assert.doesNotMatch(src, /REUSED=\([^)]*DATABASE_URL/)
  assert.doesNotMatch(src, /NEON_BACKUP_DSN/)
})
