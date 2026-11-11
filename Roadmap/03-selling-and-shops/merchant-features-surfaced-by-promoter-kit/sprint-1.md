---
epic: merchant-features-surfaced-by-promoter-kit
sprint: 1
title: "Seats"
risk: high
phase: In review
stories_total: 1
stories:
  - id: S1.1
    title: "A seat limit on every event listing"
    as_a: "a merchant selling a play or a workshop"
    i_want: "to set «Cupo» when I create or edit an event listing"
    so_that: "it sells out at that number instead of overselling"
    risk: high
    status: in-progress
---
# Merchant panel gaps: seats, one Evento, Comparte into Canales, the field loop — Sprint 1: Seats

**Status:** 🟡 in review — backend #230, storefront #490

## Stories

### Story 1.1 — A seat limit on every event listing
**As** a merchant selling a play or a workshop, **I want** to set «Cupo» when I create or edit an event listing, **so that** it sells out at that number instead of overselling.
**Acceptance:** An event listing (digital or service with the event block) created with Cupo 40 shows 40 available; the 41st ticket is refused on the PDP, `/checkout` and UCP checkout; lowering Cupo below tickets sold is refused with a plain message; an MCP-created event honours `capacity`; a money-path spec goes red when the inventory write is removed.
**Risk:** high
## Sprint QA
- **api spec(s):** a pure validation spec for Cupo (lib seam) + a money-path spec on create → tracked inventory → cap
- **browser smoke owed:** yes, to Daniel — buy a real ticket on an event with Cupo 2 until it shows «Agotado»
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge; every new spec seen red once by a mutation

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. In https://miyagisanchez.com/sell choose Servicio, fill «Detalles del evento» and set Cupo to 2, publish
   → the listing shows 2 lugares
2. Open the listing as a buyer
   → the quantity selector stops at 2
3. (money path — owed to Daniel) buy 2 tickets with a test card
   → the listing shows «Agotado»; a third purchase is refused
4. In https://miyagisanchez.com/shop/manage/catalogo edit the listing and set Cupo to 1
   → the edit is refused: tickets already sold exceed it

If any step fails, note the step number + what you saw — that's the bug report.
