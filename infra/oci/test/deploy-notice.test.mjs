// The 🚀 notice (infra/oci/deploy-notice.sh) mirrors the merge's 📦: same name, sha, subject and first plain
// paragraph. Driven through bash with fixtures — no network, no Telegram.
import { test } from 'node:test'
import assert from 'node:assert/strict'
import { spawnSync } from 'node:child_process'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const LIB = path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'deploy-notice.sh')
const run = (fn, ...args) => {
  const r = spawnSync('bash', ['-c', `. "$0"; "$@"`, LIB, fn, ...args], { encoding: 'utf8' })
  assert.equal(r.status, 0, r.stderr)
  return r.stdout
}

const MESSAGE = `Prompt-to-shop, part 4: merchants turn their own photos into products (#441)

* feat(p2s): the squash list GitHub writes

A merchant who kept their shop now sees a short checklist over it. Each photo
becomes a product, ready to confirm.

S4.1 — engineering detail that stays in the commit.

Co-Authored-By: Someone <x@y.z>`

test('success: the 📦 mirror — name, sha, subject, first plain paragraph, LIVE with the previous commit, a link', () => {
  const t = run('dn_text', 'MiyagiSanchez-Storefront', '16bcd1f319a9a5788c0daf67c727fdcc1ac97e6d', '871e7eed2ffc', 'ok', MESSAGE, '1')
  assert.equal(t, [
    '<b>MiyagiSanchez-Storefront</b> · 🚀 · <code>16bcd1f</code>',
    'Prompt-to-shop, part 4: merchants turn their own photos into products (#441)',
    'A merchant who kept their shop now sees a short checklist over it. Each photo becomes a product, ready to confirm.',
    'Status: ✅ LIVE in production · previous <code>871e7ee</code>',
    '<a href="https://github.com/danybgoode/MiyagiSanchez-Storefront/commit/16bcd1f319a9a5788c0daf67c727fdcc1ac97e6d">View deployed commit</a>',
  ].join('\n'))
})

test('several merges in one deploy name the earlier ones and link the comparison', () => {
  const t = run('dn_text', 'MiyagiSanchez-Backend', 'bbbbbbbbbb', 'aaaaaaaaaa', 'ok', 'Routine updates', '3')
  assert.match(t, /\+2 earlier merge\(s\) in this deploy: <a href="https:\/\/github.com\/danybgoode\/MiyagiSanchez-Backend\/compare\/aaaaaaaaaa\.\.\.bbbbbbbbbb">see all<\/a>/)
  assert.doesNotMatch(run('dn_text', 'MiyagiSanchez-Backend', 'b', 'a', 'ok', 'x', '1'), /earlier merge/)
})

test('a failure says FAILED, why, and the last good commit', () => {
  const t = run('dn_text', 'MiyagiSanchez-Storefront', 'cccccccccc', '871e7eed2ffc', 'fail:MiyagiSanchez-Storefront did not pass its health check (exit 1)', MESSAGE)
  assert.match(t, /Status: ❌ FAILED — MiyagiSanchez-Storefront did not pass its health check \(exit 1\)\. The last good deploy was <code>871e7ee<\/code>/)
  assert.doesNotMatch(t, /LIVE/)
})

test('GitHub unreadable: the notice still goes out, with no invented prose', () => {
  const t = run('dn_text', 'MiyagiSanchez-Storefront', 'dddddddddd', '', 'ok', '')
  assert.equal(t, '<b>MiyagiSanchez-Storefront</b> · 🚀 · <code>ddddddd</code>\nStatus: ✅ LIVE in production\n<a href="https://github.com/danybgoode/MiyagiSanchez-Storefront/commit/dddddddddd">View deployed commit</a>')
})

test('HTML in a commit is escaped, and a long paragraph is capped on a word', () => {
  const long = 'word '.repeat(200)
  const t = run('dn_text', 'MiyagiSanchez-Storefront', 'e', '', 'ok', `fix: <b>bold</b> & co\n\n${long}`)
  assert.match(t, /fix: &lt;b&gt;bold&lt;\/b&gt; &amp; co/)
  const prose = t.split('\n')[2]
  assert.ok(prose.length <= 601 && prose.endsWith('…'), prose.length)
})

test('a failure before the swap is one Miyagi Sánchez line — the brand, never "miyagi"', () => {
  assert.match(run('dn_fail_text', 'while pulling the images (exit 1)'), /^<b>Miyagi Sánchez<\/b> · 🚀 deploy FAILED — while pulling the images \(exit 1\)/)
})

test('a failure AFTER the swap says the new containers are running — never "nothing new is running"', () => {
  const t = run('dn_fail_text', 'while installing the Caddy site file (exit 1)', 'Storefront 16bcd1f, Backend 6cf1431')
  assert.match(t, /The new containers ARE running \(Storefront 16bcd1f, Backend 6cf1431\)/)
  assert.doesNotMatch(t, /Nothing new is running/)
  assert.match(run('dn_fail_text', 'while pulling the images (exit 1)'), /Nothing new is running/)
})
