---
epic: plans-gratis-negocio-and-promoter-packages
sprint: 4
title: "Promoter packages"
risk: high
phase: Shaping
stories_total: 3
stories:
  - id: S4.1
    title: "Three packages with their own prices and rates"
    as_a: "a promoter"
    i_want: "Anual, Arranque and the setup Gratis with fixed prices and splits"
    so_that: "I can say the whole deal in one sentence"
    risk: high
    status: planned
  - id: S4.2
    title: "Closing a package in the workspace"
    as_a: "a promoter at the counter"
    i_want: "to close Anual, Arranque or the setup Gratis by card or by transfer"
    so_that: "the merchant's shop gets what they paid for and I keep my part"
    risk: high
    status: planned
  - id: S4.3
    title: "10% of the year-2 renewal"
    as_a: "a promoter"
    i_want: "10% of my merchant's Negocio payments in their second year"
    so_that: "I keep looking after the merchants I signed up"
    risk: high
    status: planned
---
# Two plans (Gratis + Negocio), a 30-day trial, and three promoter packages — Sprint 4: Promoter packages

**Status:** ⬜ not started

## Stories

### Story 4.1 — Three packages with their own prices and rates
**As** a promoter, **I want** Anual, Arranque and the setup Gratis with fixed prices and splits, **so that** I can say the whole deal in one sentence.
**Acceptance:** M1's rate rows exist (55, 50, 80, 10). The rate card and handbook show «Cobras $2,000 · nos pagas $900 · te quedas $1,100» and the other two; the admin can edit the rates. Package prices are never clamped to Negocio's price.
**Risk:** high

### Story 4.2 — Closing a package in the workspace
**As** a promoter at the counter, **I want** to close Anual, Arranque or the setup Gratis by card or by transfer, **so that** the merchant's shop gets what they paid for and I keep my part.
**Acceptance:** By transfer, the admin sees $900 / $300 / $50 owed and approving it grants 12 months, 3 months or nothing; by card, the promoter pays the full price, the grant lands and the commission accrues. The merchant receipt email lists the package.
**Risk:** high

### Story 4.3 — 10% of the year-2 renewal
**As** a promoter, **I want** 10% of my merchant's Negocio payments in their second year, **so that** I keep looking after the merchants I signed up.
**Acceptance:** A Negocio payment 12–24 months after a promoter's first package payment for that shop accrues 10%; a payment outside the window or a replayed webhook accrues nothing; specs on the pure rule.
**Risk:** high

## Build contract (locked by the architect before the builder started)

Cite the epic README's locked decisions: D12, D13, D18 (M1 already applied in S2). Money: every grant write is read back; a paid write that misses alerts on Telegram.

## Sprint QA
- **api spec(s):** `e2e/promoter-packages.spec.ts` (prices, owed amounts, no clamp), `e2e/promoter-commission.spec.ts` extended (renewal window, replay).
- **browser smoke owed:** yes, to Daniel: one transfer close and one card close with his test promoter, approved in `/admin/promoter`.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 4 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Go to https://miyagisanchez.com/mx/vende/promotor/sell-sheet
   → the three packages with what the promoter charges, sends and keeps
2. Go to https://miyagisanchez.com/promotor/cerrar
   → signed in as a test promoter: open a test shop, choose «Anual», pay by transfer → «transferencia reportada» (owed to Daniel)
3. Go to https://miyagisanchez.com/admin/promoter
   → «Transferencias pendientes» shows $900 owed; approve → the test shop shows «Negocio hasta <date>» (owed to Daniel)

If any step fails, note the step number + what you saw — that's the bug report.
