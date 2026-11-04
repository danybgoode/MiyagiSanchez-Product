---
epic: plans-gratis-negocio-and-promoter-packages
sprint: 2
title: "What each plan gets"
risk: high
phase: Shaping
stories_total: 4
stories:
  - id: S2.1
    title: "«Hecho con Miyagi Sánchez» on Gratis shops"
    as_a: "the platform"
    i_want: "a small «Hecho con Miyagi Sánchez» link on Gratis shops' subdomain and embed"
    so_that: "every free shop brings people back, and Negocio has a visible reason to upgrade"
    risk: low
    status: planned
  - id: S2.2
    title: "AI allowances by plan"
    as_a: "the platform"
    i_want: "the AI that costs money to grow with the plan"
    so_that: "Gratis stays sustainable and Negocio is worth paying for"
    risk: high
    status: planned
  - id: S2.3
    title: "The check-in for Negocio, and the trial emails"
    as_a: "a merchant on a trial"
    i_want: "to hear 5 days before my trial ends, and when I am on Gratis"
    so_that: "day 31 is never a surprise"
    risk: low
    status: planned
  - id: S2.4
    title: "The subdomain is free and sold nowhere"
    as_a: "a merchant"
    i_want: "the subdomain to be simply free, and not to be charged for it again"
    so_that: "I am never billed for something everyone gets"
    risk: high
    status: planned
---
# Two plans (Gratis + Negocio), a 30-day trial, and three promoter packages — Sprint 2: What each plan gets

**Status:** ⬜ not started

## Stories

### Story 2.1 — «Hecho con Miyagi Sánchez» on Gratis shops
**As** the platform, **I want** a small «Hecho con Miyagi Sánchez» link on Gratis shops' subdomain and embed, **so that** every free shop brings people back, and Negocio has a visible reason to upgrade.
**Acceptance:** A Gratis shop's subdomain and embed show the badge linking to the home page with the shop's campaign tag; a trial or Negocio shop shows none.
**Risk:** low

### Story 2.2 — AI allowances by plan
**As** the platform, **I want** the AI that costs money to grow with the plan, **so that** Gratis stays sustainable and Negocio is worth paying for.
**Acceptance:** M1 applied and verified live. A Gratis shop's 51st chat answer of the month comes back `answered: false` with the fixed line, and the buyer sees «Déjale tu pregunta a la tienda»; a Negocio shop keeps answering. Owner prompt-to-shop versions and photos follow `lib/plan-allowances.ts`. Specs on the pure allowance decision.
**Risk:** high

### Story 2.3 — The check-in for Negocio, and the trial emails
**As** a merchant on a trial, **I want** to hear 5 days before my trial ends, and when I am on Gratis, **so that** day 31 is never a surprise.
**Acceptance:** The monthly check-in goes only to Negocio and trial shops. A shop on day 25 gets «te quedan 5 días» once; on day 31 «ya estás en Gratis» once; a re-run of the timer sends nothing twice (claim then send).
**Risk:** low

### Story 2.4 — The subdomain is free and sold nowhere
**As** a merchant, **I want** the subdomain to be simply free, and not to be charged for it again, **so that** I am never billed for something everyone gets.
**Acceptance:** No surface sells the subdomain (price page, canal-propio, promoter close, rate card, MCP answers «gratis»). `cancel-subdomain-subscriptions.mjs --dry-run` lists every live subdomain subscription; `--apply` cancels each at period end and emails its owner, once.
**Risk:** high

## Build contract (locked by the architect before the builder started)

Cite the epic README's locked decisions: D7, D8, D9, D10, D11, D18 (M1). M1 is applied by the orchestrator through MCP before this sprint's PR merges. `cancel-subdomain-subscriptions.mjs --apply` runs only after the deploy, by the orchestrator.

## Sprint QA
- **api spec(s):** `e2e/plan-allowances.spec.ts`, `e2e/shop-chat.spec.ts` extended (allowance path), `e2e/negocio-trial-emails.spec.ts`, `e2e/pricing-source-sweep.spec.ts` unchanged and green.
- **browser smoke owed:** yes, to Daniel: the badge on a real Gratis subdomain on his phone; the trial emails in his inbox.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Go to https://<a-gratis-shop>.miyagisanchez.com
   → the footer shows «Hecho con Miyagi Sánchez»; tapping it opens the home page
2. Go to https://<a-negocio-shop>.miyagisanchez.com
   → no badge
3. Go to https://miyagisanchez.com/s/<a-gratis-shop>
   → after the shop's monthly chat allowance, «Pregúntale a la tienda» answers that the shop will reply and shows «Déjale tu pregunta a la tienda»
4. Go to https://miyagisanchez.com/shop/manage/canal-propio
   → the subdomain shows as included, with no price and no buy button

If any step fails, note the step number + what you saw — that's the bug report.
