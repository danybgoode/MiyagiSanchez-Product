---
epic: one-front-door-both-markets
sprint: 4
title: "Existing merchants"
risk: high
phase: Shipped
stories_total: 1
stories:
  - id: S4.1
    title: "«Crear con IA» on my dashboard"
    as_a: "a merchant who already has a shop"
    i_want: "a card on my dashboard home to add products from a photo, a file or a link"
    so_that: "I can use the builder's tools after day one"
    risk: high
    status: done
---
# One front door for both markets — Sprint 4: Existing merchants

**Status:** ✅ shipped `f3a7996` (#501), deployed 2026-11-13

## Stories

### Story 4.1 — «Crear con IA» on my dashboard ✅ `f3a7996`
**As a** a merchant who already has a shop, **I want** a card on my dashboard home to add products from a photo, a file or a link, **so that** I can use the builder's tools after day one.
**Acceptance:** On `/shop/manage` a «Crear con IA» card opens: photo → product (monthly photos as today), a catalog file, a store link; each goes through the same screen and lands in my products for review.
**Risk:** high
## Sprint QA
- **api spec(s):** pure-logic `node:test`/Playwright `api` specs on the `lib/` seams this sprint adds (named in the README's locking decisions); every new spec observed failing once by a deliberate mutation.
- **browser smoke owed:** yes, to Daniel — the walkthrough below on production.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge.

## Sprint 4 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. (auth — owed to Daniel) Signed in, open https://miyagisanchez.com/shop/manage
   → a «Crear con IA» card: Desde una foto · Desde tu lista · Desde tu tienda anterior.
2. Tap «Desde tu tienda anterior», paste a `*.myshopify.com` address, «Traer productos»
   → the products appear in the review grid; «Importar» → they are in https://miyagisanchez.com/shop/manage/catalogo.
3. Tap «Una foto» with a photo of a product → one row in the grid, priced in the shop's currency.

If any step fails, note the step number + what you saw — that's the bug report.
