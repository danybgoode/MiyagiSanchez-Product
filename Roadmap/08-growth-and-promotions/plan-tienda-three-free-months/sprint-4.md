---
epic: plan-tienda-three-free-months
sprint: 4
title: "The promoter's three packages"
risk: high
phase: Shaping
stories_total: 4
stories:
  - id: S4.1
    title: "Three packages, three free months on top"
    as_a: "a promoter at a merchant's counter"
    i_want: "to sell Tienda for a year, Negocio for six months or Negocio for a year"
    so_that: "every merchant has a package at their size"
    risk: high
    status: planned
  - id: S4.2
    title: "10% of Plan Tienda renewals"
    as_a: "a promoter"
    i_want: "10% of the Plan Tienda payments a shop I opened makes in its second year"
    so_that: "I have a reason to keep the merchant happy"
    risk: high
    status: planned
  - id: S4.3
    title: "A share when a Tienda shop moves up"
    as_a: "a promoter"
    i_want: "20% of the first Plan Negocio payment when a Tienda shop I opened moves up in its first year"
    so_that: "I go back and sell the bigger plan"
    risk: high
    status: planned
  - id: S4.4
    title: "The promoter pages name the three packages"
    as_a: "a promoter"
    i_want: "every page to state the same three packages and what I keep"
    so_that: "I can say the deal in one sentence"
    risk: low
    status: planned
---
# Plan Tienda, three free months, and the promoter packages that follow — Sprint 4: The promoter's three packages

**Status:** ⬜ not started

## Build contract (locked by the architect before the builder started)
Decisions in the epic README that bind this sprint: D11, D12, D13, D14. M1 is applied before the PR merges.

## Stories

### Story 4.1 — Three packages, three free months on top
**As** a promoter at a merchant's counter, **I want** to sell Tienda for a year, Negocio for six months or Negocio for a year, **so that** every merchant has a package at their size.
**Acceptance:** `tienda_anual` ($500, pass $200, keep $300), `negocio_semestral` ($1,100, pass $495, keep $605) and `negocio_anual` ($2,000, pass $900, keep $1,100) are sold by card and by transfer. Each grants three months of Plan Negocio from the payment day and then its paid time (12 months of Tienda, 6 or 12 more of Negocio). `negocio_arranque` and `setup_gratis` are refused with a plain message; their old receipts, transfers and rows still open.
**Risk:** high

### Story 4.2 — 10% of Plan Tienda renewals
**As** a promoter, **I want** 10% of the Plan Tienda payments a shop I opened makes in its second year, **so that** I have a reason to keep the merchant happy.
**Acceptance:** A Plan Tienda payment 12 to 24 months after the promoter's first package payment for that shop accrues `tienda_renewal` (10%) to that promoter, once per payment.
**Risk:** high

### Story 4.3 — A share when a Tienda shop moves up
**As** a promoter, **I want** 20% of the first Plan Negocio payment when a Tienda shop I opened moves up in its first year, **so that** I go back and sell the bigger plan.
**Acceptance:** A Tienda-package shop's first Plan Negocio payment inside twelve months of the package accrues `negocio_upgrade` (20% of that payment) to the promoter who opened it, once. A later Negocio payment accrues nothing under this rule.
**Risk:** high

### Story 4.4 — The promoter pages name the three packages
**As** a promoter, **I want** every page to state the same three packages and what I keep, **so that** I can say the deal in one sentence.
**Acceptance:** «Cobra», the promoter page, the sell sheet, the receipt and `/admin/promoter` name the three packages with «Cobras… Le pasas… Te quedas…» computed from the same numbers, and say the three free months are on top.
**Risk:** low

## Sprint QA
- **api spec(s):** Pure specs on `lib/promoter-packages.ts` (splits, grants from the payment day, the retired packages), the renewal window and the upgrade rule. Each seen failing once.
- **browser smoke owed:** yes, to Daniel: one package by card and one by transfer with a test promoter
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 4 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Go to https://miyagisanchez.com/promotor/cerrar with a test promoter code and reach «Cobra»
   → three packages, each with «Cobras… Le pasas… Te quedas…»
2. (money path, owed to Daniel) Sell «Tienda · 1 año» paying the platform share with a test card
   → the receipt says Activo; the shop has three months of Plan Negocio and then twelve of Plan Tienda
3. (money path, owed to Daniel) Sell «Negocio · 6 meses» by transfer and approve it in https://miyagisanchez.com/admin/promoter
   → the receipt goes from Pendiente to Activo; the shop has nine months of Plan Negocio

If any step fails, note the step number + what you saw — that's the bug report.
