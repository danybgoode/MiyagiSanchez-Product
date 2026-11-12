---
epic: listing-readiness
sprint: 2
title: "Guided and visible"
risk: low
phase: Shipped
stories_total: 2
stories:
  - id: S2.1
    title: "The new-listing form shows what is required and fixes it in place"
    as_a: "a merchant"
    i_want: "a checklist before «Publicar» with an inline way to turn on payments, or to publish as catalog"
    so_that: "I never have to guess the conditions"
    risk: low
    status: done
  - id: S2.2
    title: "The panel keeps an unpayable shop visible"
    as_a: "a merchant"
    i_want: "a «Tu tienda aún no puede cobrar» banner, «Solo catálogo» badges and a payments step I can't hide"
    so_that: "the state stays obvious after publishing"
    risk: low
    status: done
---
# Guided listing readiness — Sprint 2: Guided and visible

**Status:** ✅ shipped — storefront #497 (`b8729e5`), backend #234 (`d35a7d6`)

## Stories

### Story 2.1 — The new-listing form shows what is required and fixes it in place ✅ `b8729e5`
**As a** merchant, **I want** `GET /api/sell/readiness` (owner-authed) to drive a checklist above «Publicar» for products: ✓/✗ entrega, ✓/✗ cobro; when something is missing, the shipped `CobrosChooser` opens inline, and «Publicar como catálogo» is offered explicitly.
**Acceptance:** on a no-payment shop the checklist shows ✗ cobro before publishing; enabling bank transfer inline turns it ✓ without leaving the form; «Publicar como catálogo» publishes.
**Risk:** low

### Story 2.2 — The panel keeps an unpayable shop visible ✅ `b8729e5`
**As a** merchant, **I want** a banner on `/shop/manage` while I have live products and no way to collect, «Solo catálogo» badges on those products in Catálogo, and the setup guide not hideable until payments are done.
**Acceptance:** the banner and badges appear on a no-payment shop with a live product and vanish once a method is on.
**Risk:** low

## Sprint QA
- **api spec(s):** `e2e/listing-readiness.spec.ts` (readiness view + guide rule).
- **browser smoke owed:** yes, to Daniel — the walkthrough below on a phone.
- **deterministic gate:** `next build` + Playwright `api` green.

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. As a merchant with no payment method, open https://miyagisanchez.com/sell and fill a product.
   → Above «Publicar»: «✓ Entrega · ✗ Cobro» and «Activar cobros aquí».
2. Open «Activar cobros aquí», enter a CLABE and save.
   → The checklist turns «✓ Cobro»; «Publicar» works normally.
3. Open https://miyagisanchez.com/shop/manage on a shop that has a live product and no payment method.
   → The banner «Tu tienda aún no puede cobrar» with a link to Pagos; the guide has no «Ocultar».
4. Open https://miyagisanchez.com/shop/manage/catalogo.
   → That shop's products show «Solo catálogo».

If any step fails, note the step number + what you saw — that's the bug report.
