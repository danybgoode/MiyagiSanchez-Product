---
epic: merchant-features-surfaced-by-promoter-kit
sprint: 3
title: "Comparte into Canales and the field loop"
risk: low
phase: Shipped
stories_total: 2
stories:
  - id: S3.1
    title: "Share tools live in Canales"
    as_a: "a merchant"
    i_want: "to find my catalog link, PDF and Meta feed in Canales"
    so_that: "I can share my shop without knowing a hidden URL"
    risk: low
    status: done
  - id: S3.2
    title: "Promoter field reports are counted"
    as_a: "a field promoter"
    i_want: "to send what a merchant asked for from my panel in under a minute"
    so_that: "it is counted in one place, not lost in WhatsApp"
    risk: low
    status: done
---
# Merchant panel gaps: seats, one Evento, Comparte into Canales, the field loop — Sprint 3: Comparte into Canales and the field loop

**Status:** ✅ shipped 2026-11-11 — storefront #489 `f664098`, deployed; migration `20261111010000` applied live

## Stories

### Story 3.1 — Share tools live in Canales ✅ `f664098`
**As** a merchant, **I want** to find my catalog link, PDF and Meta feed in Canales, **so that** I can share my shop without knowing a hidden URL.
**Acceptance:** Canales (`/shop/manage/canal-propio`) shows the catalog link, the PDF and the Meta feed tiles; `/shop/manage/comparte` redirects to Canales; the business-plan engine links point to Canales; `ConnectAgentPanel` is imported only by Configuración › Agentes and `/sell/setup`.
**Risk:** low

### Story 3.2 — Promoter field reports are counted ✅ `f664098`
**As** a field promoter, **I want** to send what a merchant asked for from my panel in under a minute, **so that** it is counted in one place, not lost in WhatsApp.
**Acceptance:** A «Reportar» form in `/promotor/cerrar` writes `platform_feedback` with `author_kind = 'promoter'` (CHECK migration applied by the orchestrator first); the report appears in `/admin/feedback` labelled promoter.
**Risk:** low
## Sprint QA
- **api spec(s):** Canales renders the three tiles; `/comparte` redirect target; feedback insert with author_kind promoter
- **browser smoke owed:** yes, to Daniel — authed seller Canales view and one promoter report
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge; every new spec seen red once by a mutation

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Signed in as a seller, open https://miyagisanchez.com/shop/manage/canal-propio
   → the catalog link, PDF and Meta feed tiles are there
2. Open https://miyagisanchez.com/shop/manage/comparte
   → it redirects to Canales
3. As a promoter, open https://miyagisanchez.com/promotor/cerrar and send a report
   → a confirmation shows
4. As admin, open https://miyagisanchez.com/admin/feedback
   → the report is listed, labelled promoter

If any step fails, note the step number + what you saw — that's the bug report.
