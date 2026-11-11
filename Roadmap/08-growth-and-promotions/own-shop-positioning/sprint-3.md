---
epic: own-shop-positioning
sprint: 3
title: "Pages by business type"
risk: low
phase: Locking architecture
stories_total: 1
stories:
  - id: S3.1
    title: "One page per business type"
    as_a: "a field promoter"
    i_want: "to send a merchant one link that speaks to their business"
    so_that: "they see their kind of shop working"
    risk: low
    status: planned
---
# Own-shop positioning: the site says what Miyagi Sánchez is now — Sprint 3: Pages by business type

**Status:** ⬜ not started

## Stories

### Story 3.1 — One page per business type
**As** a field promoter, **I want** to send a merchant one link that speaks to their business, **so that** they see their kind of shop working.
**Acceptance:** From `page-config.ts`: inmuebles, servicios con reservas, comida (autos gets the new copy) and the promoter zones imprentas, vestidos de novia, plomería y baños, ropa interior por mayoreo, materiales e interiorismo, bazar y artesanos; each renders without JS, has its OG card and canonical, shows a demo shop labelled «ejemplo», and an empty proof slot that renders nothing until a consenting real shop is attached. If S3 overflows the appetite, cut to the three zones with the most promoter visits.
**Risk:** low
## Sprint QA
- **api spec(s):** every business-type route renders no-JS with OG + canonical; proof slot renders nothing when empty
- **browser smoke owed:** yes, to Daniel — phone read of two business-type pages
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge; every new spec seen red once by a mutation

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Open https://miyagisanchez.com/mx/vende/imprentas
   → a print-shop page with a demo shop labelled «ejemplo» and «Abrir mi tienda»
2. Share that link on WhatsApp
   → the preview card names print shops

If any step fails, note the step number + what you saw — that's the bug report.
