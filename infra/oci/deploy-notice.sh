# shellcheck shell=bash
# The 🚀 half of the Telegram pair: what update.sh posts when a deploy changes what an app runs. Sourced by
# update.sh, and by infra/oci/test/deploy-notice.test.mjs, which drives the pure functions with fixtures.
#
# It MIRRORS the 📦 a merge posts (notify-telegram.yml in MiyagiSanchez-Storefront and MiyagiSanchez-Backend):
# the same repository name, short sha, subject and first plain paragraph, so the two read as one pair. Daniel's
# words (2026-10-28): the bare "web <sha> · medusa <sha>" line "doesn't carry a mirror from the commit".
#
# Names: the apps are MiyagiSanchez-Storefront and MiyagiSanchez-Backend, and the brand is Miyagi Sánchez —
# never "miyagi", never the old repo names.

STOREFRONT_REPO=MiyagiSanchez-Storefront
BACKEND_REPO=MiyagiSanchez-Backend
GITHUB_OWNER=danybgoode

# esc TEXT — Telegram HTML escaping (the same three characters notify-telegram.yml escapes).
dn_esc() {
  # sed, not ${s//&/&amp;}: bash 5.2 (CI, the VM) reads `&` in a pattern REPLACEMENT as the matched text, so the
  # parameter-expansion form printed `<lt;b>gt;`; macOS's bash 3.2 hid it (caught by deploy-notice.test.mjs on CI).
  printf '%s' "${1:-}" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

# dn_prose < MESSAGE — the commit's first plain paragraph, one line. The SAME rule as notify-telegram.yml:
# skip the subject, GitHub's squash list ("* …" lines) and trailers; cap at 600 characters on a word.
dn_prose() {
  local p
  p="$(awk '
    NR == 1 { next }
    /^[[:space:]]*$/ { if (p != "") { print p; done = 1; exit } skip = 0; next }
    skip { next }
    p == "" && ($0 ~ /^[*-] / || $0 ~ /^(Co-Authored-By|Claude-Session|Signed-off-by):/) { skip = 1; next }
    { sub(/^[[:space:]]+/, ""); p = (p == "" ? $0 : p " " $0) }
    END { if (!done && p != "") print p }')"
  if [ "${#p}" -gt 600 ]; then p="${p:0:600}"; p="${p% *}…"; fi
  printf '%s' "$p"
}

# dn_text REPO SHA PREV STATUS MESSAGE [AHEAD] — the notice, as Telegram HTML. Pure.
#   SHA / PREV  full or short commit ids; PREV may be empty (first deploy, or the old container was gone).
#   STATUS      "ok", or "fail:<why>".
#   MESSAGE     the commit's full message; empty when GitHub could not be read (the notice still goes out).
#   AHEAD       how many commits the deploy moved by (GitHub's compare `ahead_by`); empty when unknown.
dn_text() {
  local repo="$1" sha="${2:0:7}" prev="${3:0:7}" status="$4" message="$5" ahead="${6:-}"
  local subject prose url out
  subject="$(printf '%s\n' "$message" | sed -n '1p')"
  prose="$(printf '%s\n' "$message" | dn_prose)"
  url="https://github.com/${GITHUB_OWNER}/${repo}/commit/${2}"
  out="<b>$(dn_esc "$repo")</b> · 🚀 · <code>$(dn_esc "$sha")</code>"
  if [ -n "$subject" ]; then out="${out}"$'\n'"$(dn_esc "$subject")"; fi
  if [ -n "$prose" ]; then out="${out}"$'\n'"$(dn_esc "$prose")"; fi
  if [ "$status" = ok ]; then
    out="${out}"$'\n'"Status: ✅ LIVE in production"
    if [ -n "$prev" ]; then out="${out} · previous <code>$(dn_esc "$prev")</code>"; fi
    if [ -n "$ahead" ] && [ "$ahead" -gt 1 ] 2>/dev/null && [ -n "$prev" ]; then
      out="${out}"$'\n'"+$((ahead - 1)) earlier merge(s) in this deploy: <a href=\"https://github.com/${GITHUB_OWNER}/${repo}/compare/${3}...${2}\">see all</a>"
    fi
  else
    out="${out}"$'\n'"Status: ❌ FAILED — $(dn_esc "${status#fail:}")"
    if [ -n "$prev" ]; then out="${out}. The last good deploy was <code>$(dn_esc "$prev")</code>"; fi
  fi
  out="${out}"$'\n'"<a href=\"${url}\">View deployed commit</a>"
  printf '%s' "$out"
}

# dn_fail_text WHY [RUNNING] — a failure no single app owns. Pure. RUNNING empty: it stopped before the swap, so
# nothing new runs. RUNNING set (e.g. "Storefront 16bcd1f, Backend 6cf1431"): the swap was attempted, so it names what
# the containers actually run — never "nothing new is running" (codex, PR #230).
dn_fail_text() {
  if [ -n "${2:-}" ]; then
    printf '<b>Miyagi Sánchez</b> · 🚀 deploy FAILED — %s\nRunning now: %s. The deploy did not finish. SSH to the VM and re-run update.sh; logs: docker compose logs' "$(dn_esc "$1")" "$(dn_esc "$2")"
  else
    printf '<b>Miyagi Sánchez</b> · 🚀 deploy FAILED — %s\nNothing new is running. SSH to the VM and re-run update.sh; logs: docker compose logs' "$(dn_esc "$1")"
  fi
}

# ── I/O (update.sh only) ──────────────────────────────────────────────────────────────────────────────

# dn_commit_message REPO SHA — the commit's full message from GitHub's public API, or nothing.
dn_commit_message() {
  curl -s -m 10 -H 'Accept: application/vnd.github+json' \
    "https://api.github.com/repos/${GITHUB_OWNER}/$1/commits/$2" 2>/dev/null | jq -r '.commit.message // empty' 2>/dev/null || true
}

# dn_ahead REPO PREV SHA — how many commits SHA is ahead of PREV, or nothing.
dn_ahead() {
  [ -n "$2" ] || return 0
  curl -s -m 10 -H 'Accept: application/vnd.github+json' \
    "https://api.github.com/repos/${GITHUB_OWNER}/$1/compare/$2...$3" 2>/dev/null | jq -r '.ahead_by // empty' 2>/dev/null || true
}
