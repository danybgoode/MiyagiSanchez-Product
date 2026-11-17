---
epic: coordinated-sales-readiness
sprint: 1
title: "Event tickets sell by card"
risk: high
phase: Shaping
stories_total: 2
stories:
  - id: S1.1
    title: "An event ticket is not a coordinated sale"
    as_a: "a buyer"
    i_want: "to pay a paid event ticket by card, Mercado Pago, SPEI or DiMo"
    so_that: "a ticket is bought like any other ticket"
    risk: high
    status: planned
  - id: S1.2
    title: "The owner product read says whether it is an event and priced"
    as_a: "the storefront activation gate"
    i_want: "is_event and priced for a product in any status"
    so_that: "a service draft is gated by the same rule as checkout"
    risk: high
    status: planned
---
# Coordinated sales readiness — Sprint 1: Event tickets sell by card

**Status:** ⬜ not started

## Stories

### Story 1.1 — An event ticket is not a coordinated sale
**As a** buyer, **I want** `isCoordinatedListing` to return false for a `service` whose metadata carries an event block
(`hasEventBlock` — a date or a venue), **so that** checkout-options offers every rail and `start-checkout` accepts a card
for a ticket. Both callers pass the product metadata; plain services, rentals and arranged products are unchanged.
**Acceptance:** unit table (event service → not coordinated; plain service, rental, arranged+flag → coordinated;
digital → not); money-path integration gate green; a paid Evento's checkout options include card.
**Risk:** high

### Story 1.2 — The owner product read says whether it is an event and priced
**As** the storefront gate, **I want** `GET /store/sellers/me/products/:id` to also return `is_event` (the same
`hasEventBlock`) and `priced` (a positive price on the first variant), **so that** activation of a draft service is
judged by the same facts checkout uses. Unknown values never echo the metadata bag.
**Acceptance:** `listingSaleFacts` unit specs; the fields absent on an older storefront break nothing.
**Risk:** high

## Sprint QA
- **api spec(s):** backend unit specs (predicate table, `listingSaleFacts`), money-path integration green.
- **browser smoke owed:** yes, to Daniel — buy a real paid Evento by card (the 11-11 owed smoke).
- **deterministic gate:** backend type-check + build + unit + money path.

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. On a shop with card payments, open a paid Evento's page and choose tickets.
   → Checkout lists card (and the shop's other rails), not only SPEI/efectivo.
2. (money — Daniel) Pay one ticket by card.
   → The order is placed and the ticket appears for the buyer.
3. Open a plain service (no date/venue) on the same shop and go to checkout.
   → Only SPEI / efectivo are offered, as before.

If any step fails, note the step number + what you saw — that's the bug report.
