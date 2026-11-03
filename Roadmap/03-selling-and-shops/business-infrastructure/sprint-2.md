---
epic: business-infrastructure
sprint: 2
title: "One business model per shop"
risk: high
phase: Shaping
stories_total: 3
stories:
  - id: S2.1
    title: "The business model and its sources"
    as_a: "a merchant"
    i_want: "one model of my business where every number says whether it is estimated, told by me or measured"
    so_that: "I know which numbers to trust and which to fix"
    risk: high
    status: planned
  - id: S2.2
    title: "«Tus números» in the canvas"
    as_a: "a merchant describing a new business"
    i_want: "to see what each thing costs me, what it takes and what limits me, before I sign up"
    so_that: "I start with my numbers, not without them"
    risk: high
    status: planned
  - id: S2.3
    title: "Existing shops are seeded from their sales"
    as_a: "a merchant already selling on Miyagi"
    i_want: "my model filled from my real catalog, costs and sales, asked only for what is missing"
    so_that: "I get the same plan without retyping my business"
    risk: high
    status: planned
---
# Business infrastructure — Sprint 2: One business model per shop

**Status:** ⬜ not started

## Build contract (locked by the architect before the builder started)
Cite D4–D7 and D11. Migration **M1** (`supabase/migrations/2026110320xxxx_business_models.sql`): `shop_drafts.numbers
jsonb`, `save_p2s_block` key list + `'numbers'` (CREATE OR REPLACE, same signature, same REVOKE/GRANT), table
`business_models` with `REVOKE ALL … FROM PUBLIC, anon, authenticated` and service-role grants. The orchestrator
applies M1 via MCP before the PR merges and realigns `schema_migrations`. Pure modules: `lib/business-plan/model.ts`
(types, provenance merge, `MEASURED_MIN_UNITS`), `lib/business-plan/seed.ts` (draft numbers → model; catalog + ledger
→ model). The numbers block uses `generateBlock`'s retry/fallback and `RESPONSE_SCHEMAS`; its fallback is an empty
model. The photo confirm card carries the replaced example's `unit_cost` (D4).

## Stories

### Story 2.1 — The business model and its sources
**As a** merchant, **I want** one model of my business where every number says whether it is estimated, told by me or
measured, **so that** I know which numbers to trust and which to fix.
**Acceptance:** a pure spec shows: told beats estimated; measured replaces estimated only past `MEASURED_MIN_UNITS`;
missing stays missing (never 0); the row is created at keep from the draft's numbers.
**Risk:** high (migration)

### Story 2.2 — «Tus números» in the canvas
**As a** merchant describing a new business, **I want** to see what each thing costs me, what it takes and what limits
me, before I sign up, **so that** I start with my numbers, not without them.
**Acceptance:** after the catalog block, a «Tus números» block shows cost per offer, minutes per unit, monthly
capacity and its limiting resource, fixed monthly costs, each marked «estimado» and editable; edits persist on the
draft; replacing an example with a photo keeps its cost as the product's cost.
**Risk:** high

### Story 2.3 — Existing shops are seeded from their sales
**As a** merchant already selling on Miyagi, **I want** my model filled from my real catalog, costs and sales, asked
only for what is missing, **so that** I get the same plan without retyping my business.
**Acceptance:** `/shop/manage/plan` for a shop with products and costs shows them as `measured`/`told`; a product
with no cost shows "falta tu costo", never $0; the merchant can fill gaps inline.
**Risk:** high

## Sprint QA
- **api spec(s):** `e2e/business-model.spec.ts` (provenance, seed from draft, seed from catalog + ledger, missing ≠ 0),
  `e2e/p2s-numbers.spec.ts` (block validation + empty fallback, planner order with four blocks).
- **browser smoke owed:** yes, to Daniel — the seeded plan on his own shop (authed).
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green; M1 verified live before merge.

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Signed out, describe "hago pasteles sobre pedido en Puebla" at https://miyagisanchez.com/mx/vende.
   → After the examples, «Tus números» shows a cost per cake, hours per cake, how many you can make a month and what
   limits you (the oven or your time), all marked «estimado».
2. Change the cost of one cake.
   → The value keeps your number and is no longer marked «estimado» after a reload.
3. (auth — owed to Daniel) Keep the shop, then open https://miyagisanchez.com/shop/manage/plan.
   → The same numbers are there.
4. (auth — owed to Daniel) On your own existing shop, open https://miyagisanchez.com/shop/manage/plan.
   → Your products appear with their real costs; any product without a cost says "falta tu costo".

If any step fails, note the step number + what you saw — that's the bug report.
