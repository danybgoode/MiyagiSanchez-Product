---
epic: checkout-trust-hardening
sprint: 1
title: "Server-derived amounts"
risk: high
phase: Building
stories_total: 4
stories:
  - id: S1.1
    title: "A shipping price is charged only when the server issued it"
    as_a: "a merchant shipping a sale"
    i_want: "shipping to be charged at the rate our server quoted"
    so_that: "I never absorb a forged shipping price"
    risk: high
    status: planned
  - id: S1.2
    title: "The backend refuses a $0 item amount"
    as_a: "a merchant"
    i_want: "checkout to refuse any item charged at $0"
    so_that: "a free Evento or an unpriced listing can't become a $0 order through the public store API"
    risk: high
    status: planned
  - id: S1.3
    title: "One accepted offer opens one checkout at a time"
    as_a: "a merchant who accepted an offer"
    i_want: "each accepted offer to be paid once"
    so_that: "a buyer can't open several discounted checkouts"
    risk: high
    status: planned
  - id: S1.4
    title: "Every checkout path is a security path"
    as_a: "the reviewers"
    i_want: "the security lens to run on every checkout change"
    so_that: "charge routes are never reviewed without it"
    risk: high
    status: planned
---
# Checkout trusts nothing the caller names — Sprint 1: Server-derived amounts

**Status:** ⬜ not started

## Stories

### Story 1.1 — A shipping price is charged only when the server issued it
**As** a merchant shipping a sale, **I want** shipping to be charged at the rate our server quoted, **so that** I never absorb a forged shipping price.
**Acceptance:** `/store/envia/rates` returns each rate with a signature over rate_id, carrier, service, amount, currency, the sorted product ids, the destination postcode and an expiry (not the cart id: rates are quoted before a cart exists); start-checkout charges shipping only for a valid, unexpired signature matching that cart, else 422 «Vuelve a elegir el envío.»; the storefront passes the signature through unchanged; a forged amount_cents is refused (unit spec).
**Risk:** high

### Story 1.2 — The backend refuses a $0 item amount
**As** a merchant, **I want** checkout to refuse any item charged at $0, **so that** a free Evento or an unpriced listing can't become a $0 order through the public store API.
**Acceptance:** start-checkout refuses when the final item amount is ≤ 0 (after offer/support/rental/coupon/bundle resolution), 422 with a plain message; server-built carts keep their own rules; unit spec.
**Risk:** high

### Story 1.3 — One accepted offer opens one checkout at a time
**As** a merchant who accepted an offer, **I want** each accepted offer to be paid once, **so that** a buyer can't open several discounted checkouts.
**Acceptance:** at checkout start the offer is reserved with a conditional update, read back with `.select()`; a second concurrent checkout gets 409 «Esta oferta ya tiene un pago abierto.»; an abandoned checkout's reservation expires so the offer is not locked forever; unit spec.
**Risk:** high

### Story 1.4 — Every checkout path is a security path
**As** the reviewers, **I want** the security lens to run on every checkout change, **so that** charge routes are never reviewed without it.
**Acceptance:** `scripts/review-config.json` `securityPaths` adds `**/*checkout*` and `**/*checkout*/**`; a review-route test proves the backend start-checkout route and `src/lib/offer-checkout.ts` trigger the lens.
**Risk:** high

## Sprint QA
- **api spec(s):** backend unit specs per story (pure helpers, injected lookups); money-path integration stays green; root `node --test` for S1.4
- **browser smoke owed:** yes, to Daniel — one real shipped checkout and one real offer checkout
- **deterministic gate:** backend tsc + unit + integration; storefront tsc + build + api; root `node --test "scripts/**/*.test.mjs"`

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. (money path — owed to Daniel) Buy a shipped product, choose a rate, pay with a test card
   → the order's shipping equals the rate shown at checkout
2. (money path — owed to Daniel) Accept an offer, open its checkout in two tabs and pay in the first
   → the second tab is refused with «Esta oferta ya tiene un pago abierto.»

If any step fails, note the step number + what you saw — that's the bug report.
