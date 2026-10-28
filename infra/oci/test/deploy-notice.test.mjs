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

test('a failure AFTER the swap names what runs — never "nothing new is running"', () => {
  const t = run('dn_fail_text', 'while installing the Caddy site file (exit 1)', 'Storefront 16bcd1f, Backend 6cf1431')
  assert.match(t, /Running now: Storefront 16bcd1f, Backend 6cf1431\. The deploy did not finish\./)
  assert.doesNotMatch(t, /Nothing new is running/)
  assert.match(run('dn_fail_text', 'while pulling the images (exit 1)'), /Nothing new is running/)
})

// update.sh's exit handler, extracted and driven with stubs: what it posts is what the containers RUN.
import { readFileSync } from 'node:fs'
const UPDATE = readFileSync(path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'update.sh'), 'utf8')
const ON_EXIT = UPDATE.slice(UPDATE.indexOf('on_exit() {'), UPDATE.indexOf('\n}\n', UPDATE.indexOf('on_exit() {')) + 3)
const exitPosts = (state) => {
  const script = `
    . "${LIB}"
    POSTS=""
    notify() { POSTS="\${POSTS}<<\$1>>"; }
    notice() { notify "notice $1 $2 $3 $4"; }
    running_rev() { case "$1" in web) printf '%s' "$RUN_WEB";; medusa) printf '%s' "$RUN_MEDUSA";; esac; }
    ${ON_EXIT}
    ${state}
    (exit 1); on_exit; printf '%s' "$POSTS"`
  const r = spawnSync('bash', ['-c', script], { encoding: 'utf8' })
  assert.equal(r.status, 0, r.stderr)
  return r.stdout
}

test('exit before the swap: one Miyagi Sánchez line, nothing new running', () => {
  const p = exitPosts('DEPLOYED=0 SWAPPED=0 STEP="pulling the images" FAILED_APP="" PREV_WEB=a PREV_MEDUSA=b RUN_WEB=a RUN_MEDUSA=b')
  assert.match(p, /^<<<b>Miyagi Sánchez<\/b> · 🚀 deploy FAILED — while pulling the images \(exit 1\)\nNothing new is running/)
})

test('Caddy fails after the swap: each CHANGED app gets its own 🚀 FAILED, naming what it runs', () => {
  const p = exitPosts('DEPLOYED=0 SWAPPED=1 STEP="installing the Caddy site file" FAILED_APP="" PREV_WEB=old PREV_MEDUSA=same RUN_WEB=new RUN_MEDUSA=same')
  assert.equal(p, '<<notice MiyagiSanchez-Storefront new old fail:the deploy did not finish while installing the Caddy site file (exit 1); MiyagiSanchez-Storefront is running this commit>>')
})

test('the health check fails: that app says so under its own name', () => {
  const p = exitPosts('DEPLOYED=0 SWAPPED=1 STEP="installing the Caddy site file" FAILED_APP=medusa PREV_WEB=w PREV_MEDUSA=m0 RUN_WEB=w RUN_MEDUSA=m1')
  assert.equal(p, '<<notice MiyagiSanchez-Backend m1 m0 fail:MiyagiSanchez-Backend did not pass its health check (exit 1)>>')
})

test('a half-failed Compose that changed nothing still says what runs, never "nothing new"', () => {
  const p = exitPosts('DEPLOYED=0 SWAPPED=1 STEP="starting the containers" FAILED_APP="" PREV_WEB=w0000000 PREV_MEDUSA=m0000000 RUN_WEB=w0000000 RUN_MEDUSA=m0000000')
  assert.match(p, /Running now: Storefront w000000, Backend m000000\./)
})

test('a finished deploy posts nothing from the exit handler', () => {
  assert.equal(exitPosts('DEPLOYED=1 SWAPPED=1 STEP=x FAILED_APP="" PREV_WEB=a PREV_MEDUSA=b RUN_WEB=c RUN_MEDUSA=d'), '')
})
