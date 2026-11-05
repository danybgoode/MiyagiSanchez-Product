---
epic: plans-gratis-negocio-and-promoter-packages
sprint: 1
title: "The plan underneath"
risk: high
phase: Building
stories_total: 4
stories:
  - id: S1.1
    title: "The Negocio plan in Medusa Commerce (Backend)"
    as_a: "the platform"
    i_want: "a Negocio subscription plan with monthly billing, read and updated through internal routes"
    so_that: "the Storefront can sell Negocio and know who pays for it"
    risk: high
    status: planned
  - id: S1.2
    title: "One plan seam, the prices and the trial"
    as_a: "a merchant"
    i_want: "my shop to know whether it is on Gratis, its trial or Negocio"
    so_that: "everything the plan opens agrees with what I paid for"
    risk: high
    status: planned
  - id: S1.3
    title: "Buy Negocio: monthly, or yearly in meses sin intereses"
    as_a: "a merchant"
    i_want: "to pay $149 a month, or $1,490 for the year in installments"
    so_that: "I can keep Negocio after the trial without paying a year at once"
    risk: high
    status: planned
  - id: S1.4
    title: "Custom domain and ML sync open for Negocio"
    as_a: "a Negocio merchant"
    i_want: "my custom domain and Mercado Libre sync to work without buying them separately"
    so_that: "Negocio is the one thing I buy"
    risk: high
    status: planned
---
# Two plans (Gratis + Negocio), a 30-day trial, and three promoter packages — Sprint 1: The plan underneath

**Status:** ⬜ not started

## Stories

### Story 1.1 — The Negocio plan in Medusa Commerce (Backend)
**As** the platform, **I want** a Negocio subscription plan with monthly billing, read and updated through internal routes, **so that** the Storefront can sell Negocio and know who pays for it.
**Acceptance:** `POST /internal/setup-negocio-plan` creates or updates the one plan with `metadata.kind = 'negocio_plan'`; `GET /internal/negocio-subscription?seller_clerk_id=` answers `{ active, … }` and fails closed; `PATCH` flips a subscription by its Stripe id. Backend tests mirror the ML-sync routes'.
**Risk:** high

### Story 1.2 — One plan seam, the prices and the trial
**As** a merchant, **I want** my shop to know whether it is on Gratis, its trial or Negocio, **so that** everything the plan opens agrees with what I paid for.
**Acceptance:** `derivePlan` is pure and covered by spec (every precedence row in D1, lapse on read, a shop never re-trialed). The first `/shop/manage` load of an owned shop stamps a 30-day trial once; a second load does not move it. `backfill-negocio-trial.mjs --dry-run` lists the owned shops it would stamp and writes nothing.
**Risk:** high

### Story 1.3 — Buy Negocio: monthly, or yearly in meses sin intereses
**As** a merchant, **I want** to pay $149 a month, or $1,490 for the year in installments, **so that** I can keep Negocio after the trial without paying a year at once.
**Acceptance:** Monthly opens a Stripe subscription checkout on the seeded price; yearly opens a one-time checkout with installments (or the PR states the account refused them). The webhook writes the Medusa subscription or a 12-month `negocio_grant`; a lapse returns the shop to Gratis. A grant write that misses alerts on Telegram.
**Risk:** high

### Story 1.4 — Custom domain and ML sync open for Negocio
**As** a Negocio merchant, **I want** my custom domain and Mercado Libre sync to work without buying them separately, **so that** Negocio is the one thing I buy.
**Acceptance:** With the paywalls ON: a Negocio shop connects a domain and turns on ML sync; a trial shop gets ML sync but not the domain; a Gratis shop gets neither; a shop with an old grant or standalone subscription keeps it. Specs over the composers' pure inputs.
**Risk:** high

## Build contract (locked by the architect before the builder started)

Cite the epic README's locked decisions: D1, D2, D3, D4, D5, D6. Backend first (S1.1), then Storefront. The trial stamp is a conditional write read back (`a-read-is-not-a-claim`); never stamp on a public read.

## Sprint QA
- **api spec(s):** `e2e/plan.spec.ts` (derivePlan, trial planner), `e2e/negocio-checkout.spec.ts` (session shapes, webhook decisions), the composers' existing specs extended; Backend `negocio-subscription` route tests.
- **browser smoke owed:** yes, to Daniel: one real monthly and one real yearly Negocio payment in test mode on production, and the installment option at checkout.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Go to https://miyagisanchez.com/shop/manage/negocio
   → as a merchant whose shop is new: «Estás en tu prueba de Negocio: te quedan 30 días»
2. Go to https://miyagisanchez.com/shop/manage/negocio
   → tap «$149 al mes» → Stripe checkout for $149 MXN monthly (test card 4242 4242 4242 4242) → back on the page, «Negocio activo» (money step, owed to Daniel)
3. Go to https://miyagisanchez.com/shop/manage/negocio
   → on another shop, tap «$1,490 al año» → Stripe checkout offers meses sin intereses with a Mexican test card → paid, «Negocio hasta <date>» (money step, owed to Daniel)
4. Go to https://miyagisanchez.com/shop/manage/canal-propio
   → as the Negocio shop: «Conecta tu dominio» is available without a separate payment
5. Go to https://miyagisanchez.com/shop/manage/mercadolibre
   → as a trial shop: the sync can be turned on

If any step fails, note the step number + what you saw — that's the bug report.
