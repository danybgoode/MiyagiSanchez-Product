---
epic: listing-readiness
sprint: 1
title: "One rule, every door"
risk: high
phase: Building
stories_total: 3
stories:
  - id: S1.1
    title: "One readiness rule"
    as_a: "the platform"
    i_want: "one rule for 'can this product be bought online'"
    so_that: "every door gives the same answer"
    risk: high
    status: planned
  - id: S1.2
    title: "The new-listing form and activation ask the rule"
    as_a: "a merchant"
    i_want: "to be told what is missing before an unbuyable product goes live, or to choose catalog on purpose"
    so_that: "nothing is published unbuyable by accident"
    risk: high
    status: planned
  - id: S1.3
    title: "Offers only where the shop can collect"
    as_a: "a buyer"
    i_want: "no offer path on a shop that cannot take payment"
    so_that: "an accepted price is always payable"
    risk: high
    status: planned
---
# Guided listing readiness — Sprint 1: One rule, every door

**Status:** ⬜ not started

## Stories

### Story 1.1 — One readiness rule
**As** the platform, **I want** `lib/listing-readiness.ts` (pure rule + `ownerShopFacts` + `publicShopFacts`), **so that**
`deriveCheckoutViability`, `checkCheckoutViability`, `listingActivationBlock` and `shopAcceptsAnyPayment` all delegate.
**Acceptance:** rule table spec (payment × delivery × arranged × type); each old entry point returns the same as before for the cases it already covered; the CLABE/`configured` drift is gone.
**Risk:** high

### Story 1.2 — The new-listing form and activation ask the rule
**As a** merchant, **I want** `POST /api/sell/create` to refuse an unready product with 422 `LISTING_NOT_READY` + what is missing, unless I sent `publish_as_catalog: true`; the single activate accepts the same flag.
**Acceptance:** a no-payment shop's product create → 422 naming «cobro»; with the flag → published; a ready shop → unchanged.
**Risk:** high

### Story 1.3 — Offers only where the shop can collect
**As a** buyer, **I want** no «Hacer oferta» on a shop that can't collect, and the server to refuse creating, accepting or countering an offer there (Medusa read; unreadable = 503).
**Acceptance:** offer create on a no-payment shop → 409 with a plain message; seller accept/counter → refused with a link to Pagos; decline still works; a transfer-only shop is NOT refused.
**Risk:** high

## Sprint QA
- **api spec(s):** `e2e/listing-readiness.spec.ts` (rule, readers, door sweep, offer decision).
- **browser smoke owed:** yes, to Daniel — publish + offer on a real no-payment shop.
- **deterministic gate:** `next build` + Playwright `api` green before merge.

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. As a merchant whose shop has no payment method, go to https://miyagisanchez.com/sell and publish a product.
   → Publishing stops and says a payment method is missing (sprint 2 adds the guided panel).
2. Choose «Publicar como catálogo».
   → The product is live; its page shows «Escríbele», no «Comprar», no «Hacer oferta».
3. As a buyer, try an offer on a product of a shop that takes only bank transfer.
   → The offer is accepted by the server (transfer counts).
4. (money — Daniel) As the seller of a no-payment shop, open an existing offer at https://miyagisanchez.com/shop/manage/offers and press «Aceptar».
   → Refused with «Activa cómo cobrar para aceptar ofertas» and a link to Pagos.

If any step fails, note the step number + what you saw — that's the bug report.
