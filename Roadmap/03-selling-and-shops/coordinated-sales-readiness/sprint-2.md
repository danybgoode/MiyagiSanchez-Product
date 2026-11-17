---
epic: coordinated-sales-readiness
sprint: 2
title: "Services and rentals publish as buyable only where they can be paid"
risk: high
phase: Shipped
stories_total: 3
stories:
  - id: S2.1
    title: "The readiness rule covers services, rentals and events"
    as_a: "a merchant"
    i_want: "a priced service or rental to need SPEI or cash, a paid event any rail, and an unpriced service nothing"
    so_that: "nothing publishes as buyable where checkout refuses it"
    risk: high
    status: done
  - id: S2.2
    title: "Every door and surface follows the rule"
    as_a: "a merchant and a buyer"
    i_want: "the form, activation, PDP buttons, offers, banner and badges to agree"
    so_that: "the shop never promises a payment it cannot take"
    risk: high
    status: done
  - id: S2.3
    title: "Owed money smokes are run or handed over"
    as_a: "the product owner"
    i_want: "a real paid Evento bought by card and a service publish on a card-only shop walked"
    so_that: "the money path is proven live"
    risk: high
    status: done
---
# Coordinated sales readiness — Sprint 2: Services and rentals publish as buyable only where they can be paid

**Status:** ✅ shipped 2026-11-17 (storefront #505, `94e1694`); S2.3 smokes owed to Daniel

## Stories

### Story 2.1 — The readiness rule covers services, rentals and events
**As a** merchant, **I want** `listingReadiness` (storefront) to take the price and the event flag: a priced `service`
or `rental` → online only with SPEI or cash (`manual_payment`), a paid event → online with any rail, `price_cents`
null or 0 → online (contact/RSVP). `listingCanBePaid` delegates to it. The event predicate is the seated-event rule (D5), mirrored from the backend.
**Acceptance:** rule table spec; a sweep that the storefront event predicate equals the backend's definition.
**Risk:** high

### Story 2.2 — Every door and surface follows the rule
**As a** merchant and buyer, **I want** `POST /api/sell/create` (body), activation (`readListingReadiness`, using
S1.2's `is_event` + `priced`), MCP's `listingActivationBlock`, the PDP «Comprar»/«Hacer oferta», the offer gate, the
panel banner and the «Solo catálogo» badges to pass price + event to the rule; the manual-payment message names
services and rentals («Los servicios y rentas se pagan por SPEI o en efectivo»).
**Acceptance:** a priced service on a card-only shop → 422 LISTING_NOT_READY naming SPEI/efectivo; with
`publish_as_catalog` → published; its PDP shows no «Comprar»; a paid event on the same shop → buyable.
**Risk:** high

### Story 2.3 — Owed money smokes are run or handed over
Run what an agent can run (unauthenticated + API-level), hand the authed money steps to Daniel by name.
**Risk:** high

## Sprint QA
- **api spec(s):** `e2e/listing-readiness.spec.ts` extended (rule table, doors, predicate parity).
- **browser smoke owed:** yes, to Daniel — the walkthrough below.
- **deterministic gate:** `next build` + full api project vs a clean-`main` baseline.

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. On a shop with only card payments, publish a service with a price at https://miyagisanchez.com/sell.
   → «Antes de publicar» says services are paid by SPEI or cash, with «Activar cobros» and «Publicar como catálogo».
2. Choose «Publicar como catálogo» and open the service.
   → No «Comprar», no «Hacer oferta»; «Escríbele» instead.
3. Publish a paid Evento on the same shop.
   → It publishes normally and shows «Comprar».
4. Publish a service with «Precio a consultar».
   → It publishes with no readiness panel (contact-only).

If any step fails, note the step number + what you saw — that's the bug report.
