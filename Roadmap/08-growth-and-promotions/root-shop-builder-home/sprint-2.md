---
epic: root-shop-builder-home
sprint: 2
title: "The upgraded pitch"
risk: low
phase: Shipped
stories_total: 4
stories:
  - id: S2.1
    title: "Section order: describe, what you get, pricing, marketplace bonus"
    as_a: "a merchant reading the home page"
    i_want: "to see what my shop gets before the marketplace"
    so_that: "I understand the offer is a shop, not a listing"
    risk: low
    status: done
  - id: S2.2
    title: "Pricing block from the one catalog"
    as_a: "a merchant asking how much"
    i_want: "the price on the page"
    so_that: "I don't leave to find it"
    risk: low
    status: done
  - id: S2.3
    title: "'¿Vienes a comprar?' link to /mx"
    as_a: "a buyer who typed the domain"
    i_want: "one tap to the marketplace"
    so_that: "I am not stuck on a seller pitch"
    risk: low
    status: done
  - id: S2.4
    title: "Mobile sweep, deploy, purge, smoke"
    as_a: "the product owner"
    i_want: "the upgraded home live and clean on a phone"
    so_that: "I can send it to anyone"
    risk: low
    status: done
---
# The shop builder opens at miyagisanchez.com — Sprint 2: The upgraded pitch

**Status:** ✅ shipped 2026-10-30 — Storefront #455 → `9e4094a`, deployed (VM web container == `9e4094a`), live smoke green. Phone walkthrough owed to Daniel.

## Stories

### Story 2.1 — Section order: describe, what you get, pricing, marketplace bonus ✅ `9e4094a`
**As a** merchant reading the home page, **I want** to see what my shop gets before the marketplace, **so that** I
understand the offer is a shop, not a listing.
**Acceptance:** sections run: describe box → what you get (own shop and domain, payments, catalog link / PDF / feed,
setup guide) → pricing → "y además apareces en el mercado". Marketplace-first copy on the anchor is cut or moved to
the bonus line. Copy lives in the dictionary (editable in `/admin/contenido`); accent/ñ guard passes. Persona pages
are not reordered. No proof section (product owner, 10-29).
**Risk:** low

### Story 2.2 — Pricing block from the one catalog ✅ `9e4094a`
**As a** merchant asking how much, **I want** the price on the page, **so that** I don't leave to find it.
**Acceptance:** "0% de comisión" plus the free-forever line and one or two optional extras, every figure read from
the pricing catalog `/mx/precios` uses; the hand-typed-MXN guard passes; a "Ver precios" link to `/mx/precios`.
**Risk:** low

### Story 2.3 — "¿Vienes a comprar?" link to `/mx` ✅ `9e4094a`
**As a** buyer who typed the domain, **I want** one tap to the marketplace, **so that** I am not stuck on a seller
pitch.
**Acceptance:** a quiet "¿Vienes a comprar? Explora el mercado" link to `/mx`, visible without scrolling on desktop and
in the first two screens on a 390 px phone.
**Risk:** low

### Story 2.4 — Mobile sweep, deploy, purge, smoke ✅ `9e4094a`
**As** the product owner, **I want** the upgraded home live and clean on a phone, **so that** I can send it to anyone.
**Acceptance:** no horizontal overflow at 360/390/414 px (browser spec); deployed, VM container == merge SHA,
Cloudflare `/` purged, live smoke screenshot of `/`.
**Risk:** low

## Sprint QA
- **api spec(s):** section-order + pricing-from-catalog source spec (S2.1, S2.2); overflow browser spec (S2.4).
- **browser smoke owed:** yes, to Daniel — the phone walkthrough below; no money/auth step.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. On your phone, open https://miyagisanchez.com and scroll once
   → after the describe box: what you get (shop, domain, cobros, catálogo/PDF/feed, guía).
2. Keep scrolling
   → a pricing block with "0% de comisión"; tap "Ver precios" → `/mx/precios`.
3. Go back, find "¿Vienes a comprar?"
   → tap it → the marketplace at `/mx`.
4. Swipe sideways anywhere on the home page
   → nothing moves sideways.

If any step fails, note the step number + what you saw — that's the bug report.

## Sprint 2 — what actually happened
- The "Lo que te llevas" block is the rewritten proof block, not `premiumFeatures` (D11 named the latter); the proof block sits right under the hero, which is where "what you get first" needs it. The premium grid stays as "included features", without the paid domain and without "parte del marketplace".
- The hero line changed too (product owner's ask: shop over marketplace) — it promised "compradores en el marketplace". Still one line for hero + description, prompt-to-shop's contract.
- One admin override exists live: `sellerAcquisition.anchor.proofTitle` («Estas son algunas de las funcionalidades incluidas», 07-12). It does not render on `/` today ("Lo que te llevas" does); left untouched for Daniel.
- The home-page smoke flaked ~1 in 4 on console errors from Cloudflare Turnstile's own iframe (the describe box now lives on `/`); filtered by source in Storefront #456.
