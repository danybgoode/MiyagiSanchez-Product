---
epic: promoter-panel
sprint: 1
title: "The ownership guard and promoter imports"
risk: high
phase: Shipped
stories_total: 3
stories:
  - id: S1.1
    title: "One guard for writing to a shop"
    as_a: "a promoter"
    i_want: "to add products only to the shops I opened that nobody has claimed yet"
    so_that: "no promoter account can write to a merchant's live shop"
    risk: high
    status: done
  - id: S1.2
    title: "Shopify import into the shop the promoter opened"
    as_a: "a promoter"
    i_want: "to bring a Shopify merchant's catalog into the shop I just opened"
    so_that: "the shop has its products in one step, before the claim"
    risk: high
    status: done
  - id: S1.3
    title: "File import (Tiendanube, WooCommerce, Big Cartel)"
    as_a: "a promoter"
    i_want: "to upload the export file of a merchant on Tiendanube, WooCommerce or Big Cartel"
    so_that: "their catalog arrives without typing"
    risk: high
    status: done
---
# El panel del promotor: open a shop in one visit, manual-first, in four steps — Sprint 1: The ownership guard and promoter imports

**Status:** ✅ merged — Storefront [#480](https://github.com/danybgoode/MiyagiSanchez-Storefront/pull/480), squash `ff3a8be` · deployed 2026-11-06

## Stories

### Story 1.1 — One guard for writing to a shop
**As** a promoter, **I want** to add products only to the shops I opened that nobody has claimed yet, **so that** no promoter account can write to a merchant's live shop.
**Acceptance:** A hand-made request from a promoter to add a product to a shop they didn't open, or to a claimed shop, gets 403 (and for a claimed shop, «Esta tienda ya es de su dueño. Pídele que agregue productos desde su panel.»). Their own unclaimed shop still works. The photo fill obeys the same rule. Self-close stays refused.
**Risk:** high

### Story 1.2 — Shopify import into the shop the promoter opened
**As** a promoter, **I want** to bring a Shopify merchant's catalog into the shop I just opened, **so that** the shop has its products in one step, before the claim.
**Acceptance:** A Shopify address shows «Encontramos {n} productos» with up to 5 examples, and one confirm adds up to 150 products, private until consent. More than 150 adds 150 and reports the rest. A bad address gets «No pudimos leer esa tienda. Revisa la dirección con el dueño.» Only the promoter's own unclaimed shop can be the target.
**Risk:** high

### Story 1.3 — File import (Tiendanube, WooCommerce, Big Cartel)
**As** a promoter, **I want** to upload the export file of a merchant on Tiendanube, WooCommerce or Big Cartel, **so that** their catalog arrives without typing.
**Acceptance:** Each platform's real export header row (pinned in a spec fixture) maps to name, price, stock, description and images. One confirm adds up to 150 products, private until consent. An unreadable file gets «No pudimos leer este archivo. Pídele que lo descargue otra vez desde su plataforma.» Same guard as S1.1.
**Risk:** high

## Build contract
Cite the epic README's locked decisions (D1–D12). Escalate per WAYS-OF-WORKING → *Escalate, don't guess*.

## Sprint QA
- **api spec:** e2e/promoter-panel-guard.spec.ts (D1, incl. a hand-made request to another shop and to a claimed shop)
- **api spec:** e2e/promoter-panel-import.spec.ts (D2–D4: 150 cap, private status, header fixtures per platform)
- **browser smoke owed:** no UI yet: the routes are proved by specs; the browser smoke rides on Sprint 3
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge; every new spec seen red under a mutation

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. (no visible change yet) The routes are called from Sprint 3's screens.

If any step fails, note the step number + what you saw — that's the bug report.
