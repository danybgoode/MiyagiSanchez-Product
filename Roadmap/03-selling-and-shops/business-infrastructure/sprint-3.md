---
epic: business-infrastructure
sprint: 3
title: "Tu plan: what to sell, what to change"
risk: high
phase: Shipped
stories_total: 4
stories:
  - id: S3.1
    title: "The plan: volume, break-even, bottleneck"
    as_a: "a merchant"
    i_want: "to say how much I want to earn a month and see how much I must sell and what limits me"
    so_that: "I know whether my business can pay me and why not"
    risk: high
    status: done
  - id: S3.2
    title: "Moves you can act on"
    as_a: "a merchant"
    i_want: "the few changes that move me toward my goal, each one tap from the tool that does it"
    so_that: "the plan turns into action, not a report"
    risk: high
    status: done
  - id: S3.3
    title: "The words, never the maths"
    as_a: "a merchant"
    i_want: "the plan explained in plain words that only use my real numbers"
    so_that: "I understand it and can trust every figure"
    risk: high
    status: done
  - id: S3.4
    title: "The monthly check-in"
    as_a: "a merchant"
    i_want: "a message each month saying whether I am on track and what to do next"
    so_that: "the plan keeps working after the first day"
    risk: high
    status: done
---
# Business infrastructure — Sprint 3: «Tu plan» — what to sell, what to change

**Status:** ✅ shipped · **Merged:** danybgoode/MiyagiSanchez-Storefront#468 · danybgoode/MiyagiSanchez-Backend#223

## Build contract (locked by the architect before the builder started)
Cite D8–D10 and D12. `lib/business-plan/engine.ts` is pure and the only place a figure is computed; it imports
`solveForPrice` from `lib/profit.ts`. Moves only link (D9) — no new mutation path. The explanation guard is a pure
function with its own spec (any number in the text that is not in the engine output → template fallback). The cron
route mirrors `app/api/cron/p2s-nudges/route.ts` (header secret, 503 on a failed read, claim before send). The timer
file lands in the ROOT repo `infra/oci/systemd/`; installing it on the VM is the orchestrator's post-merge step.
`get_business_plan` (seller MCP tool) returns the engine output.

## Stories

### Story 3.1 — The plan: volume, break-even, bottleneck ✅ danybgoode/MiyagiSanchez-Storefront#468
**As a** merchant, **I want** to say how much I want to earn a month and see how much I must sell and what limits me,
**so that** I know whether my business can pay me and why not.
**Acceptance:** with a goal, the plan shows needed monthly volume, break-even, and one binding constraint: capacity,
demand, or "fill this number first"; the engine spec covers each branch, zero/negative contribution and missing
inputs.
**Risk:** high

### Story 3.2 — Moves you can act on ✅ danybgoode/MiyagiSanchez-Storefront#468
**As a** merchant, **I want** the few changes that move me toward my goal, each one tap from the tool that does it,
**so that** the plan turns into action, not a report.
**Acceptance:** up to three ranked moves (reprice, push the best earner per unit of the bottleneck, pause a
loss-maker, share, fill a number), each opening its existing page; nothing changes until the merchant confirms there.
**Risk:** high (links to the price Apply)

### Story 3.3 — The words, never the maths ✅ danybgoode/MiyagiSanchez-Storefront#468
**As a** merchant, **I want** the plan explained in plain words that only use my real numbers, **so that** I
understand it and can trust every figure.
**Acceptance:** the explanation is es-MX; a spec proves a text with a figure not in the engine output is rejected and
the template is shown; it is regenerated only when the inputs change.
**Risk:** high

### Story 3.4 — The monthly check-in ✅ danybgoode/MiyagiSanchez-Storefront#468
**As a** merchant, **I want** a message each month saying whether I am on track and what to do next, **so that** the
plan keeps working after the first day.
**Acceptance:** the cron sends at most one check-in per shop per month on the merchant's chosen channels, comparing
last month's sales with the plan; a re-run the same month sends nothing; a failed read returns 503.
**Risk:** high

## Sprint QA
- **api spec(s):** `e2e/business-plan-engine.spec.ts`, `e2e/business-plan-explain.spec.ts`,
  `e2e/business-checkin.spec.ts` (order: authorise → read → decide → claim → send).
- **browser smoke owed:** yes, to Daniel — his own plan and one Apply through the profit page (authed).
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green.

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. (auth — owed to Daniel) Open https://miyagisanchez.com/shop/manage/plan and enter "15000" as what you want to earn
   a month.
   → The plan says how many sales a month that takes, your break-even, and what limits you.
2. Read the explanation under the numbers.
   → Every figure in it is one shown above it.
3. Tap the first move.
   → It opens the existing page for that action (the product's editor for a price, the share kit for buyers); nothing has changed yet.
4. (owed to Daniel) On the 1st of next month, check your email or Telegram.
   → One check-in arrives saying whether you are on track.

If any step fails, note the step number + what you saw — that's the bug report.
