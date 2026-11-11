---
epic: merchant-features-surfaced-by-promoter-kit
sprint: 2
title: "One Evento"
risk: high
phase: Locking architecture
stories_total: 1
stories:
  - id: S2.1
    title: "«Evento» is one choice in the wizard, free or paid"
    as_a: "a merchant hosting an event"
    i_want: "to create it from the same wizard as everything else, free or paid"
    so_that: "I manage one thing, not two systems"
    risk: high
    status: planned
---
# Merchant panel gaps: seats, one Evento, Comparte into Canales, the field loop — Sprint 2: One Evento

**Status:** ⬜ not started

## Stories

### Story 2.1 — «Evento» is one choice in the wizard, free or paid
**As** a merchant hosting an event, **I want** to create it from the same wizard as everything else, free or paid, **so that** I manage one thing, not two systems.
**Acceptance:** «Evento» appears in the `/sell` wizard with date, time, venue, Cupo and price (≥ 0, required event fields); a $0 Evento shows «Registrarme», verifies the email and issues the existing QR ticket, counted against Cupo; a paid Evento goes through checkout; Eventos leaves `SELLER_NAV` and `/shop/manage/eventos` redirects to the catalog; a Wall event entry renders the listing; the redirect target is asserted by spec.
**Risk:** high
## Sprint QA
- **api spec(s):** wizard type → payload spec; RSVP keyed to a listing; Wall event kind resolves a listing; redirect target asserted
- **browser smoke owed:** yes, to Daniel — register for a $0 Evento and redeem the QR; buy a ticket to a paid one
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge; every new spec seen red once by a mutation

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. In https://miyagisanchez.com/sell choose «Evento», price $0, Cupo 5, publish
   → the listing shows «Registrarme»
2. Register with an email and enter the code
   → a QR ticket arrives by email
3. Open https://miyagisanchez.com/shop/manage/eventos
   → it redirects to the catalog; the panel has no Eventos entry
4. (money path — owed to Daniel) create a paid Evento and buy one ticket
   → checkout completes and the ticket is issued

If any step fails, note the step number + what you saw — that's the bug report.
