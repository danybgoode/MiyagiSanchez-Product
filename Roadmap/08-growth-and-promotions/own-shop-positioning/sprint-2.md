---
epic: own-shop-positioning
sprint: 2
title: "What the shop already does"
risk: low
phase: Locking architecture
stories_total: 1
stories:
  - id: S2.1
    title: "Six features merchants never see, said in our words"
    as_a: "a merchant deciding whether to open a shop"
    i_want: "to see what the shop already does for me"
    so_that: "I understand it is more than a catalog"
    risk: low
    status: planned
---
# Own-shop positioning: the site says what Miyagi Sánchez is now — Sprint 2: What the shop already does

**Status:** ⬜ not started

## Stories

### Story 2.1 — Six features merchants never see, said in our words
**As** a merchant deciding whether to open a shop, **I want** to see what the shop already does for me, **so that** I understand it is more than a catalog.
**Acceptance:** `/mx/vende` and `about_miyagi` carry six stories, each linking to the real feature: omnichannel («un inventario para cada mostrador»), financial intelligence (Tu plan, Analíticas, Ganancias), offers and haggling, AI (shop chat, Import, the merchant's own agent as a support channel, true to what the MCP can do), sorteos, «pon tu negocio en línea»; `/mx/precios` gets a short «Qué incluye tu tienda» list; no hand-typed price; copy polished and logged in the copy bank.
**Risk:** low
## Sprint QA
- **api spec(s):** the six stories render on `/mx/vende` and in `about_miyagi`; hand-typed-price spec stays green
- **browser smoke owed:** yes, to Daniel — phone read of `/mx/vende` and `/mx/precios`
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge; every new spec seen red once by a mutation

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Open https://miyagisanchez.com/mx/vende
   → six feature sections appear, each with a working link
2. Open https://miyagisanchez.com/mx/precios
   → «Qué incluye tu tienda» lists them

If any step fails, note the step number + what you saw — that's the bug report.
