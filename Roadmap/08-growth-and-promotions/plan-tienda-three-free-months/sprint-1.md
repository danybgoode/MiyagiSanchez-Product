---
epic: plan-tienda-three-free-months
sprint: 1
title: "Plan Tienda exists"
risk: high
phase: Shaping
stories_total: 4
stories:
  - id: S1.1
    title: "The plan seam knows Plan Tienda"
    as_a: "a merchant"
    i_want: "my shop to be on Plan Tienda when I have paid for it"
    so_that: "every page and gate agrees on what I bought"
    risk: high
    status: planned
  - id: S1.2
    title: "Every existing shop is marked legacy"
    as_a: "a merchant whose shop already exists"
    i_want: "to keep Plan Gratis for good"
    so_that: "the promise on the pricing page I read is kept"
    risk: high
    status: planned
  - id: S1.3
    title: "Plan Tienda has its AI amounts"
    as_a: "a merchant on Plan Tienda"
    i_want: "the shop chat and the photo step to work at the amounts I was told"
    so_that: "I know what is included"
    risk: low
    status: planned
  - id: S1.4
    title: "A month of AI use and cost per shop"
    as_a: "the product owner"
    i_want: "to see how many chat answers and photos each shop used in a month and what they cost"
    so_that: "the allowances are set on a measured number"
    risk: low
    status: planned
---
# Plan Tienda, three free months, and the promoter packages that follow — Sprint 1: Plan Tienda exists

**Status:** ⬜ not started

## Stories

### Story 1.1 — The plan seam knows Plan Tienda
**As** a merchant, **I want** my shop to be on Plan Tienda when I have paid for it, **so that** every page and gate agrees on what I bought.
**Acceptance:** A shop with a live Tienda grant or subscription resolves to `tienda`. Precedence: Negocio (comp, dated grant, subscription), then the trial, then Tienda (dated grant, subscription), then legacy Plan Gratis, then unpaid. A shop holding Tienda time that moves up to Negocio keeps its remaining Tienda time for when Negocio ends. "Could not read the subscription" is reported as unavailable, never as unpaid. Pure spec on `derivePlan` covering every combination.
**Risk:** high

### Story 1.2 — Every existing shop is marked legacy
**As** a merchant whose shop already exists, **I want** to keep Plan Gratis for good, **so that** the promise on the pricing page I read is kept.
**Acceptance:** A script writes the legacy marker on every shop that exists on the day of the change, with a dry run that prints the count and writes nothing. Each write is conditional and read back. A marked shop with an ended trial resolves to Plan Gratis; an unmarked one resolves to unpaid. The count is taken again at apply time. The 18 shops whose trial ends 2026-12-05 are marked and are not extended.
**Risk:** high

### Story 1.3 — Plan Tienda has its AI amounts
**As** a merchant on Plan Tienda, **I want** the shop chat and the photo step to work at the amounts I was told, **so that** I know what is included.
**Acceptance:** Plan Tienda gets 50 chat answers and 20 photos a month from `lib/plan-allowances.ts`. Negocio and the trial keep 1,000 and 60. The custom domain, Mercado Libre sync, the badge and the monthly check-in answer the same as today for Negocio and the trial, and "no" for Tienda.
**Risk:** low

### Story 1.4 — A month of AI use and cost per shop
**As** the product owner, **I want** to see how many chat answers and photos each shop used in a month and what they cost, **so that** the allowances are set on a measured number.
**Acceptance:** A script prints, per shop and in total, the chat answers and photos used in a given month, with the cost where it is logged and «no registrado» where it is not. Never a zero for a cost that was not logged. `--dry-run` is fully read-only.
**Risk:** low

## Sprint QA
- **api spec(s):** Pure specs on `lib/plan.ts` (`derivePlan`, the legacy read) and `lib/plan-allowances.ts`; a spec on the legacy script's pure planner. Each seen failing once by breaking the implementation.
- **browser smoke owed:** no
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Open https://miyagisanchez.com/shop/manage/negocio signed in as the owner of a shop that existed before the change
   → it says Plan Gratis, exactly as before
2. Open https://miyagisanchez.com/admin/tenants and look at any shop created before the change
   → it shows the legacy mark
3. Ask for the AI report for last month
   → a table of shops with answers, photos and cost, or «no registrado»

If any step fails, note the step number + what you saw — that's the bug report.
