---
epic: plan-tienda-three-free-months
sprint: 2
title: "Buying Plan Tienda"
risk: high
phase: Shipped
stories_total: 3
stories:
  - id: S2.1
    title: "Plan Tienda for a year, in one payment"
    as_a: "a merchant"
    i_want: "to pay Plan Tienda for a year at once"
    so_that: "my shop is paid for twelve months at the lowest price"
    risk: high
    status: done
  - id: S2.2
    title: "Plan Tienda month to month"
    as_a: "a merchant who will not pay a year at once"
    i_want: "to pay Plan Tienda every month"
    so_that: "I can start with a small charge"
    risk: high
    status: done
  - id: S2.3
    title: "The price pages show the two paid plans"
    as_a: "a visitor or an AI assistant"
    i_want: "to see Plan Tienda and Plan Negocio with their prices"
    so_that: "I know what the shop costs after the three free months"
    risk: low
    status: done
---
# Plan Tienda, three free months, and the promoter packages that follow — Sprint 2: Buying Plan Tienda

**Status:** ✅ merged 2026-11-10 (Backend #228 → `21830e8`, Storefront #485 → `6f817a3`), live 2026-11-11 01:30 UTC

## Build contract (locked by the architect before the builder started)
Decisions in the epic README that bind this sprint: D3, D5, D6. Backend first: the `tienda_plan` setup route and subscription read, modelled on `setup-negocio-plan` and `negocio-subscription`. Then the storefront. Prices only through `lib/tienda-pricing.ts`. **Added at review of Backend #228 (2026-11-10), binding on the storefront half:** (1) on every Stripe subscription event, for Plan Negocio and Plan Tienda, the webhook retrieves the subscription from Stripe and sends its CURRENT status to the backend PATCH, never the status in the event payload, so a delayed event cannot restore a plan; (2) it sends Stripe's status as is (`unpaid`, `paused`, `incomplete`, `incomplete_expired` included) and stops mapping `unpaid` to `past_due`; the backend decides what is live; (3) `{ updated }` counts rows written or already cancelled, and 0 still means failure; (4) the Tienda grant writer uses `merge_shop_metadata_guards` with a guard on every key it read (D12b).

## Stories

### Story 2.1 — Plan Tienda for a year, in one payment ✅ `6f817a3`
**As** a merchant, **I want** to pay Plan Tienda for a year at once, **so that** my shop is paid for twelve months at the lowest price.
**Acceptance:** Paying the yearly price from `lib/tienda-pricing.ts` writes a 12-month Tienda grant once. A replayed webhook adds nothing. Paying during the three free months starts the year when they end. A second yearly payment adds twelve months after the current end. Nothing a client sends sets a price. IVA is included in the price shown.
**Risk:** high

### Story 2.2 — Plan Tienda month to month ✅ `21830e8 · 6f817a3`
**As** a merchant who will not pay a year at once, **I want** to pay Plan Tienda every month, **so that** I can start with a small charge.
**Acceptance:** The monthly price is a Stripe subscription on a new Medusa Commerce plan, created through an internal route like `setup-negocio-plan`. A live subscription resolves to Plan Tienda. Cancelling it from «Tu plan» ends Plan Tienda at the period end. Subscribing during the three free months sets the first charge at their end.
**Risk:** high

### Story 2.3 — The price pages show the two paid plans ✅ `6f817a3`
**As** a visitor or an AI assistant, **I want** to see Plan Tienda and Plan Negocio with their prices, **so that** I know what the shop costs after the three free months.
**Acceptance:** `/mx/precios`, «Tu plan», the manifest, the MCP tools and `llms.txt` show Plan Tienda («desde $19 al mes», the yearly and the monthly price) and Plan Negocio, with «IVA incluido». Plan Gratis is no longer offered to a new shop. A legacy shop's «Tu plan» still says Plan Gratis and offers both paid plans. Every price is a token from its module.
**Risk:** low

## Sprint QA
- **api spec(s):** Pure specs on the Tienda checkout rules and the payment decision (replay, add-after-end, start-after-trial); `e2e/pricing-source-sweep.spec.ts` extended to the new tokens. Each seen failing once.
- **browser smoke owed:** yes, to Daniel: the two test-card payments
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Go to https://miyagisanchez.com/mx/precios
   → Plan Tienda «desde $19 al mes» and Plan Negocio, both «IVA incluido», and «3 meses gratis»
2. (money path, owed to Daniel) In https://miyagisanchez.com/shop/manage/negocio on a test shop, pay Plan Tienda for a year with a test card
   → «Tu plan» says Plan Tienda with an end date twelve months after the free months end
3. (money path, owed to Daniel) On a second test shop, subscribe to Plan Tienda month to month with a test card, then cancel it from «Tu plan»
   → it says Plan Tienda until the period end, then no renewal

If any step fails, note the step number + what you saw — that's the bug report.
