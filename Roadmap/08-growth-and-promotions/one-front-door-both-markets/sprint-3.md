---
epic: one-front-door-both-markets
sprint: 3
title: "Every landing, one hero"
risk: low
phase: Shipped
stories_total: 4
stories:
  - id: S3.1
    title: "The builder on every landing page"
    as_a: "a merchant arriving on a persona page"
    i_want: "the describe box at the top, with examples for my kind of business"
    so_that: "I start right where I landed"
    risk: low
    status: done
  - id: S3.2
    title: "The hero is just the input"
    as_a: "a visitor"
    i_want: "no «Compruébalo tú mismo» line and no «Copiar prompt para mi IA» block in any hero"
    so_that: "the first thing I see is where to start"
    risk: low
    status: done
  - id: S3.3
    title: "«Lo que tu tienda hace»"
    as_a: "a visitor"
    i_want: "the section named «Lo que tu tienda hace» (and «What your shop does»)"
    so_that: "—"
    risk: low
    status: done
  - id: S3.4
    title: "We can see where shops start"
    as_a: "the product owner"
    i_want: "to know which input and which market each start came from"
    so_that: "I can tell whether the US and the new inputs are used"
    risk: low
    status: done
---
# One front door for both markets — Sprint 3: Every landing, one hero

**Status:** ✅ shipped `25889ab` (#500), deployed 2026-11-13

## Stories

### Story 3.1 — The builder on every landing page ✅ `25889ab`
**As a** a merchant arriving on a persona page, **I want** the describe box at the top, with examples for my kind of business, **so that** I start right where I landed.
**Acceptance:** Every `/mx/vende/*` page, `/us/sell` and `/us/vende` opens on the describe box, with chips that fit the page (food on comida, cars on autos).
**Risk:** low

### Story 3.2 — The hero is just the input ✅ `25889ab`
**As a** a visitor, **I want** no «Compruébalo tú mismo» line and no «Copiar prompt para mi IA» block in any hero, **so that** the first thing I see is where to start.
**Acceptance:** No hero on `/`, `/en` or any landing carries the trust line or the copy-prompt block; the copy guards assert they are gone.
**Risk:** low

### Story 3.3 — «Lo que tu tienda hace» ✅ `25889ab`
**As a** a visitor, **I want** the section named «Lo que tu tienda hace» (and «What your shop does»), **so that** —.
**Acceptance:** The heading reads «Lo que tu tienda hace» on `/` and the persona pages, «What your shop does» in English.
**Risk:** low

### Story 3.4 — We can see where shops start ✅ `25889ab`
**As a** the product owner, **I want** to know which input and which market each start came from, **so that** I can tell whether the US and the new inputs are used.
**Acceptance:** `p2s_describe_submitted` carries `input` (text·photo·file·url) and `market` beside the page path.
**Risk:** low
## Sprint QA
- **api spec(s):** pure-logic `node:test`/Playwright `api` specs on the `lib/` seams this sprint adds (named in the README's locking decisions); every new spec observed failing once by a deliberate mutation.
- **browser smoke owed:** yes, to Daniel — the walkthrough below on production.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge.

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Open https://miyagisanchez.com/mx/vende/comida
   → the page opens on the describe box with chips «Tamales · Postres · Comida corrida»; no «Compruébalo tú mismo».
2. Open https://miyagisanchez.com/ and scroll
   → no copy-prompt block anywhere; the section reads «Lo que tu tienda hace».
3. Open https://miyagisanchez.com/mx/vende/promotor
   → no describe box (it recruits promoters, not merchants).

If any step fails, note the step number + what you saw — that's the bug report.
