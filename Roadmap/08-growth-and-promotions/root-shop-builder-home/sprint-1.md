---
epic: root-shop-builder-home
sprint: 1
title: "The shop builder opens at the root"
risk: low
phase: Shipped
stories_total: 6
stories:
  - id: S1.1
    title: "/ renders the Mexico seller page, describe box first"
    as_a: "a merchant who typed miyagisanchez.com"
    i_want: "to see the shop builder first"
    so_that: "I can start a shop without knowing another URL"
    risk: low
    status: done
  - id: S1.2
    title: "No auto-hop from / to /en; footer country and language links"
    as_a: "a merchant in Mexico whose phone is set to English"
    i_want: "to stay on the pitch"
    so_that: "my phone's language does not send me to a country picker"
    risk: low
    status: done
  - id: S1.3
    title: "/mx/vende and /vende go to /, /mercado goes to /mx"
    as_a: "a merchant holding an old flyer or ad link"
    i_want: "the old address to still work"
    so_that: "printed material and campaign tracking survive the move"
    risk: low
    status: done
  - id: S1.4
    title: "Every seller-landing link and agent surface names /"
    as_a: "a visitor or an AI agent"
    i_want: "every 'Vender' link to go to the new home"
    so_that: "nothing points at a redirect"
    risk: low
    status: done
  - id: S1.5
    title: "Old-root specs rewritten for the new contract"
    as_a: "the team"
    i_want: "the root gated by specs that describe what it is now"
    so_that: "a regression to the picker or to products on / fails CI"
    risk: low
    status: done
  - id: S1.6
    title: "Deploy, Cloudflare purge, live smoke"
    as_a: "the product owner"
    i_want: "the new home live on miyagisanchez.com"
    so_that: "I can start saying just the domain"
    risk: low
    status: done
---
# The shop builder opens at miyagisanchez.com — Sprint 1: The shop builder opens at the root

**Status:** ✅ shipped 2026-10-30 — Storefront #454 → `dadfc8c`, deployed (VM web container == `dadfc8c`), live smoke green. Phone walkthrough owed to Daniel.

## Stories

### Story 1.1 — `/` renders the Mexico seller page, describe box first ✅ `dadfc8c`
**As a** merchant who typed miyagisanchez.com, **I want** to see the shop builder first, **so that** I can start a
shop without knowing another URL.
**Acceptance:** `/` shows the anchor seller page with the describe box as the first action; no market picker, no
products. Title, description, canonical, OG and JSON-LD `url` are `/`. One shared server component renders it — never
two copies of the markup (the lock picks: shared component rendered from `(site)`, or the root page moved into
`(shell)`). `/` renders per request like `/mx/vende` (the describe box reads `TURNSTILE_SITE_KEY` at runtime).
**Risk:** low

### Story 1.2 — No auto-hop from `/` to `/en`; footer country and language links ✅ `dadfc8c`
**As a** merchant in Mexico whose phone is set to English, **I want** to stay on the pitch, **so that** my phone's
language does not send me to a country picker.
**Acceptance:** an `en-US` browser opening `/` stays on `/`. The footer on `/` has "México · Estados Unidos · English"
links (`/mx`, `/us`, `/en`). `/en` is byte-for-byte unchanged in behaviour, including its hop to `/` for Spanish
browsers.
**Risk:** low

### Story 1.3 — `/mx/vende` and `/vende` go to `/`, `/mercado` goes to `/mx` ✅ `dadfc8c`
**As a** merchant holding an old flyer or ad link, **I want** the old address to still work, **so that** printed
material and campaign tracking survive the move.
**Acceptance:** `/mx/vende?utm_source=x&v=b&from=y` → 308 `/?…` with all three kept; `/vende` → `/` in one hop;
`/mercado` → 308 `/mx`. `/mx/vende/<persona>`, `/vende/<persona>`, `/vende/fundadoras`, `/vende/promotor/*` resolve
exactly as before. Rules stay below the tenant exits in `middleware.ts`; a subdomain/custom-domain `/` is unaffected.
Pure-helper spec on `platformMarketRedirectPath`.
**Risk:** low

### Story 1.4 — Every seller-landing link and agent surface names `/` ✅ `dadfc8c`
**As a** visitor or an AI agent, **I want** every "Vender" link to go to the new home, **so that** nothing points at a
redirect.
**Acceptance:** `SELLER_LANDING_PATHS.mx === '/'`; header, footer and persona-page back links resolve to `/`;
sitemap, `llms.txt`, `/acerca` and the UCP manifest's seller link name `/`. `seller-landing-link-population` passes
(and is extended if it does not see `/mx/vende` literals).
**Risk:** low

### Story 1.5 — Old-root specs rewritten for the new contract ✅ `dadfc8c`
**As** the team, **I want** the root gated by specs that describe what it is now, **so that** a regression to the
picker or to products on `/` fails CI.
**Acceptance:** `market-selector.browser`, `market-route-population`, `root-language-hop.browser`, `root-language`,
`market-root-layout` rewritten (not deleted): `/` holds the describe box, no `[data-listing-id]`, no listing/Medusa
import, no hop to `/en`; `/en` still the selector. Each new assertion seen red once by a deliberate break.
**Risk:** low

### Story 1.6 — Deploy, Cloudflare purge, live smoke ✅ `dadfc8c`
**As** the product owner, **I want** the new home live on miyagisanchez.com, **so that** I can start saying just the
domain.
**Acceptance:** VM container runs the merge SHA; Cloudflare checked for `/` and `/mx/vende` (purge only if stale — D12); live smoke of `/` shows
the describe box; `/` TTFB recorded before and after (if > 300 ms slower, stop and ask).
**Risk:** low

## Sprint QA
- **api spec(s):** redirect helper (S1.3), landing path + link population (S1.4), the rewritten root specs (S1.5).
- **browser smoke owed:** yes, to Daniel — the phone walkthrough below; no money/auth step.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. On your phone, open https://miyagisanchez.com
   → "Describe tu negocio" box is the first thing; no country picker.
2. Set the phone to English, reopen https://miyagisanchez.com
   → you stay on the same Spanish page; footer shows "English".
3. Open https://miyagisanchez.com/mx/vende?utm_source=prueba
   → the address bar ends at `miyagisanchez.com/?utm_source=prueba`.
4. Open https://miyagisanchez.com/mercado
   → the marketplace at `/mx`.
5. Open https://miyagisanchez.com/mx/vende/creadores
   → the creators page, unchanged.
6. Open https://miyagisanchez.com/en
   → the English country picker, unchanged.

If any step fails, note the step number + what you saw — that's the bug report.

## Sprint 1 — what actually happened
- `/` live TTFB after the move ≈ 0.39 s (6 cache-busted samples, 10-30) vs 0.28 s static before: about +100 ms, inside the 300 ms limit. Cloudflare reports `BYPASS` on `/`, so no stale copy existed and no purge was needed.
- Fresh reviewer findings fixed before merge: the strip's English link bounced es-MX phones back to `/` (now stores the language choice), and the stale-link guard blanked `https://` URLs as comments.
