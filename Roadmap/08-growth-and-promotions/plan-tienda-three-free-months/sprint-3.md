---
epic: plan-tienda-three-free-months
sprint: 3
title: "Three free months, then a pause"
risk: high
phase: Shaping
stories_total: 4
stories:
  - id: S3.1
    title: "Three free months for a new shop"
    as_a: "a merchant opening a shop"
    i_want: "three months of Plan Negocio with no card"
    so_that: "I can sell before I pay"
    risk: high
    status: planned
  - id: S3.2
    title: "Two notices before the end"
    as_a: "a merchant near the end of the free months"
    i_want: "to be told at 15 days and at 5 days, with the way to pay"
    so_that: "my shop is not paused by surprise"
    risk: low
    status: planned
  - id: S3.3
    title: "An unpaid shop is paused"
    as_a: "the product owner"
    i_want: "a shop with no paid plan after its free months to go dark with nothing deleted"
    so_that: "free shops stop costing money and nothing is lost"
    risk: high
    status: planned
  - id: S3.4
    title: "A payment brings the shop back"
    as_a: "a merchant whose shop was paused"
    i_want: "to pay and have the shop on line again at once"
    so_that: "I lose nothing by paying late"
    risk: high
    status: planned
---
# Plan Tienda, three free months, and the promoter packages that follow — Sprint 3: Three free months, then a pause

**Status:** ⬜ not started

## Build contract (locked by the architect before the builder started)
Decisions in the epic README that bind this sprint: D7, D8, D9, D10. The pause job is not deployed until the D2 marker is verified live. Validate, then claim, then apply. `--dry-run` writes nothing.

## Stories

### Story 3.1 — Three free months for a new shop
**As** a merchant opening a shop, **I want** three months of Plan Negocio with no card, **so that** I can sell before I pay.
**Acceptance:** A shop whose owner arrives after the change gets a trial of 90 days. A trial stamped before the change keeps its own end date. The trial is stamped once, as today.
**Risk:** high

### Story 3.2 — Two notices before the end
**As** a merchant near the end of the free months, **I want** to be told at 15 days and at 5 days, with the way to pay, **so that** my shop is not paused by surprise.
**Acceptance:** The owner gets one notice at 15 days and one at 5 days, each claimed once, by the channels they have on. For a non-legacy shop the end notice says the shop is paused and how to bring it back; for a legacy shop it says Plan Gratis, as today.
**Risk:** low

### Story 3.3 — An unpaid shop is paused
**As** the product owner, **I want** a shop with no paid plan after its free months to go dark with nothing deleted, **so that** free shops stop costing money and nothing is lost.
**Acceptance:** A daily job pauses an owned, unmarked, unpaid shop whose three months ended, through the backend status route with the reason `plan_unpaid`. It pauses nothing whose plan it could not read, no legacy shop, no unclaimed shop and no shop with a live grant or subscription. Validate, then claim, then apply; each write conditional and read back. `--dry-run` prints the list and writes nothing. The timer is enabled by Daniel by hand.
**Risk:** high

### Story 3.4 — A payment brings the shop back
**As** a merchant whose shop was paused, **I want** to pay and have the shop on line again at once, **so that** I lose nothing by paying late.
**Acceptance:** A Plan Tienda or Plan Negocio payment restores a shop paused for `plan_unpaid`, and no shop paused for any other reason. A replayed webhook restores nothing twice. The paused owner can sign in, open «Tu plan», see why the shop is paused and pay.
**Risk:** high

## Sprint QA
- **api spec(s):** Pure specs on the trial length rule, the notice decision and the pause/restore decision (three states: legacy, unpaid, unavailable). Backend unit spec if the status route needs to read the reason on unpause. Each seen failing once.
- **browser smoke owed:** yes, to Daniel: a pause and a restore on a test shop
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Open a new test shop and go to https://miyagisanchez.com/shop/manage/negocio
   → «3 meses gratis» with the end date ninety days out
2. In https://miyagisanchez.com/admin/tenants move that shop's trial end to yesterday and run the plan job
   → the shop shows «pausada» with the reason plan_unpaid, and its public address no longer shows the shop
3. (money path, owed to Daniel) Signed in as its owner, open https://miyagisanchez.com/shop/manage/negocio and pay Plan Tienda with a test card
   → within a minute the shop is «activa» and its public address shows it again

If any step fails, note the step number + what you saw — that's the bug report.
