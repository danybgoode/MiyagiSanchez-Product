---
epic: plans-gratis-negocio-and-promoter-packages
sprint: 3
title: "The price page and agents"
risk: high
phase: Shaping
stories_total: 3
stories:
  - id: S3.1
    title: "One price list: Gratis and Negocio"
    as_a: "a merchant comparing platforms"
    i_want: "to see two plans and what each includes, with real prices"
    so_that: "I understand what I get free and what Negocio adds"
    risk: low
    status: planned
  - id: S3.2
    title: "«Tu suscripción»"
    as_a: "a merchant"
    i_want: "one page that says my plan, how long my trial has left and how to pay"
    so_that: "I can upgrade or check my plan without hunting"
    risk: low
    status: planned
  - id: S3.3
    title: "Agents read the plan and start Negocio"
    as_a: "a merchant's AI agent"
    i_want: "to read the shop's plan and start Negocio"
    so_that: "agents can do what the merchant can"
    risk: high
    status: planned
---
# Two plans (Gratis + Negocio), a 30-day trial, and three promoter packages — Sprint 3: The price page and agents

**Status:** ⬜ not started

## Stories

### Story 3.1 — One price list: Gratis and Negocio
**As** a merchant comparing platforms, **I want** to see two plans and what each includes, with real prices, **so that** I understand what I get free and what Negocio adds.
**Acceptance:** `/mx/precios` shows Gratis and Negocio from the catalog, plus the print ad and migration as extras and the processors' fees; `/acerca`, `/agent`, `llms.txt` and the MCP about surfaces say the same; no typed MXN price in copy.
**Risk:** low

### Story 3.2 — «Tu suscripción»
**As** a merchant, **I want** one page that says my plan, how long my trial has left and how to pay, **so that** I can upgrade or check my plan without hunting.
**Acceptance:** `/shop/manage/negocio` shows the plan, the trial's days left, what Negocio includes, and the monthly and yearly buttons (S1.3's routes); the panel's nav links to it; «Tu plan» is untouched.
**Risk:** low

### Story 3.3 — Agents read the plan and start Negocio
**As** a merchant's AI agent, **I want** to read the shop's plan and start Negocio, **so that** agents can do what the merchant can.
**Acceptance:** MCP `get_plan` returns plan, ends_at and what it includes; `start_negocio` with `cadence: month | year` returns a checkout URL for the token's own shop only; another shop's slug is refused.
**Risk:** high

## Build contract (locked by the architect before the builder started)

Cite the epic README's locked decisions: D15, D16, D17. Copy uses `{token}`s only; the pricing-source sweep must stay green.

## Sprint QA
- **api spec(s):** `e2e/pricing-catalog.spec.ts` extended (plans), `e2e/mcp-plan-tools.spec.ts`, the full `npm run test:e2e`.
- **browser smoke owed:** yes, to Daniel: `/mx/precios` and «Tu suscripción» on his phone.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Go to https://miyagisanchez.com/mx/precios
   → two columns, Gratis and Negocio, with $149 al mes / $1,490 al año and what each includes
2. Go to https://miyagisanchez.com/shop/manage/negocio
   → «Tu suscripción» with the plan and the days left
3. Go to https://miyagisanchez.com/acerca
   → the prices match `/mx/precios`

If any step fails, note the step number + what you saw — that's the bug report.
