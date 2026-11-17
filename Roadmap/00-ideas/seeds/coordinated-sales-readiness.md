---
title: "Event tickets sell by card, and services or rentals publish as buyable only where they can be paid"
slug: coordinated-sales-readiness
status: scaffolded
area: "03-selling-and-shops"
type: bug
appetite: S
underwritten_by: wave-2026-11
risk: high
epic: "03-selling-and-shops/coordinated-sales-readiness"
build_order: 22
updated: 2026-11-16
intent_ask: verbatim
hypothesis: null
persona: "A merchant selling a service, a rental or a paid Evento, and the buyer paying for it."
grounded: null
grounded_reason: null
target_metric: null
target_from: null
target_to: null
read_date: null
flag_key: null
target_segment: null
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null
intent_match: null
---

# Pitch — Event tickets sell by card; services and rentals publish as buyable only where they can be paid

Moves · Tests: not grounded — no strategy yet

## The ask, as given

> refine the services/rentals publish gap as an epic or whatever the issue type needed. no need for only a seed at all, lets be len on ceremony, not on technical thoroughness

### Claims
1. Close the gap where a service or rental publishes on a shop that cannot be paid for it.
2. Pick the right issue type; scaffold it as a buildable epic, not a seed only.
3. Technically thorough: find what the gap really is.

**Teach-back:** yes — "You want services and rentals to never look buyable where checkout will refuse them. Right?" (and
Daniel chose, 2026-11-16: event tickets take any rail; plain services and rentals stay SPEI/cash only).

## Problem (what the investigation found)
Backend `isCoordinatedListing` (`src/api/store/_utils/delivery-catalog.ts`) makes **every `service` and `rental`** a
coordinated sale: checkout-options offers only manual rails and `start-checkout` 422s any card/MP/DiMo payment.
1. **A shipped bug:** the Evento preset (merchant-panel-gaps, 2026-11-11) stores a paid event as `listing_type:
   'service'`. Its buy box goes through the ordinary cart → the ticket is **refused by card and Mercado Pago
   everywhere**; on a shop without SPEI/cash there is no way to pay at all. Nothing to coordinate for a ticket: the
   venue/date is fixed and the backend mints one ticket per unit. The owed Evento money smoke would have caught it.
2. **The publish gap:** `lib/listing-readiness.ts` exempts non-product types, so a priced service or rental on a
   card-only shop publishes, shows «Comprar»/«Hacer oferta» paths that the offer gate partly refuses (`listingCanBePaid`
   already requires manual for them) and checkout refuses.

Live 2026-11-16: 9 priced active services across 8 shops — all but one on **unclaimed** shops (claim gate already stops
buying); the claimed one (`bright`) is a paid event on a shop with no payment method. No money lost yet.

## Appetite
S — one sprint, one epic-mode run (backend + storefront).
quote: not quoted (no history script in this checkout)

## Outcome & signal
- A paid event ticket can be bought by card / MP / SPEI / DiMo; plain services and rentals still only by SPEI or cash.
- A priced service or rental on a shop without SPEI/cash is «Solo catálogo» at publish (fix inline or choose catalog);
  a paid event needs any rail; an unpriced service («precio a consultar») stays contact-only, ungated.
- PDP «Comprar»/«Hacer oferta», the offer gate, the panel banner and badges all agree, from the one rule.

## Stage-2.5 bucket
light-enhancement — two predicates (backend `isCoordinatedListing`, storefront `listingReadiness`) and the facts they read.

## Bill of materials (What / Why)

| What | Why |
|---|---|
| Backend: a service with an event block is NOT coordinated (`hasEventBlock`, the seats predicate) | Tickets were refused by card |
| Backend owner product read also returns `is_event` + `priced` | The activation gate needs them for drafts |
| Storefront rule: priced service/rental → manual; paid event → any rail; unpriced → contact | The publish gap |
| Same event predicate on both sides (date or venue — the backend's) | Checkout and publish must never disagree |
| Copy: «Los servicios y rentas se pagan por SPEI o en efectivo» | The manual message said «entrega acordada» |

## Scope
**In v1:** the table. **Out (no-gos):** card-payable plain services (Daniel kept them manual); rental card pricing (the
dark `checkout.rental_pricing_enabled` stays dark); unclaimed shops (claim gate); any flag.

## Rabbit holes
- **One event predicate.** Backend `hasEventBlock` reads a date OR a venue; the storefront's must be the same (a
  "Futbol 2026" service with only a venue counts as an event on both sides) — or publish and checkout disagree.
- **Price shapes.** «Precio a consultar» / `price_cents` null = contact-only (no checkout); a free event (0) = RSVP, no
  payment; only a positive price needs a rail.
- **Money path.** `start-checkout` and checkout-options both call `isCoordinatedListing` — change the predicate once,
  pass the product metadata from both; the money-path integration gate must stay green.

## What already exists (reuse, don't rebuild)
- Backend `isCoordinatedListing` + `buildDeliveryCatalog` (`_utils/delivery-catalog.ts`), `start-checkout` COORD guard,
  `hasEventBlock` (`_utils/inventory.ts`), `listingSaleFacts` (`sellers/me/products/[id]/route.ts`, epic listing-readiness).
- Storefront `lib/listing-readiness.ts` (`listingReadiness`, `listingCanBePaid`, `COORDINATED_TYPES`), `lib/shop-collect.ts`,
  `lib/readiness-view.ts`, `ReadinessPanel`, `lib/evento-preset.ts`.

## Flags
No flag (AGENTS operating posture); rollback = revert. High risk → fresh pr-reviewer + cross-family + security lens.

## QA
Backend unit specs on the predicate (event / plain service / rental / arranged / digital) + money-path integration green;
storefront rule specs + a sweep that both sides share the event predicate's definition. **Owed to Daniel:** a real paid
Evento bought by card (the 11-11 owed smoke), and a service publish on a card-only shop.
