# Coordinated sales readiness — Retrospective

_Closed: 2026-11-17_
_Intent: yes | mostly | no_
<!-- Daniel's one-word answer goes here (yes, mostly or no). -->
_Quote vs actual: not quoted → not stamped (`scripts/epic-actuals.mjs` unavailable in this session) (—)_
_Crew (actual): Claude Opus 5.5 builder (epic mode, one run) · reviewers: fresh pr-reviewer (backend ×3 passes, storefront ×3), Codex gpt-6-luna xhigh general + security (backend 4 rounds, storefront 3) · prose: builder — every review round found a real gap._

## What shipped
- **Sprint 1, backend #237 (`81bec0d`):** a paid Evento ticket is no longer a coordinated sale. A **seated event** (an
  event block AND capped seats on every variant, D5) takes card, Mercado Pago, SPEI or DiMo. Plain services and rentals
  stay SPEI/cash. start-checkout's early pre-check no longer refuses the `service` method (D6). The owner product read
  returns `is_event` + `priced`. Verified live: `checkout-options` for `panfleto` offers manual only for a plain service
  and card + manual for an event.
- **Sprint 2, storefront #505 (`94e1694`):** the one readiness rule covers services, rentals and events. A priced service/rental
  needs SPEI or cash, a paid seated event any rail, and an unpriced or free listing is ungated at publish (a payment or
  offer is always priced). Every door follows it: the form + readiness panel, create, activation, the MCP create and
  set_listing_status, PDP «Comprar», offers, the banner and badges, and the web + UCP checkout hint.

## What went well
- The investigation turned a vague "publish gap" into a shipped bug: paid tickets were refused by card everywhere.
- Every review round caught something real (below). None were noise.

## What we learned
- **An exemption has to clear EVERY guard on the path, not the one you changed.** The ticket exemption lived in the
  product guard, but a cheaper client-trusting pre-check earlier in the same route still refused `service` by card.
  Unit specs on the predicate were green. Only a reviewer who traced the request end to end found it.
- **"Is it capped?" is a property of every variant and every mode.** `manage_inventory` alone missed backorder and an
  unlimited sibling variant. Two security rounds.
- **A display hint needs a sender.** The backend learned `is_event`, but the checkout never sent it. Caught by tracing
  the storefront caller before merge.

## Gaps / follow-ups
- **Owed to Daniel (S2.3):** buy a real paid Evento by card (check which confirmation email arrives; a card ticket
  gets the generic order email), and publish a priced service on a card-only shop to see «Solo catálogo».
- **Product call:** a card buyer who loses the race for the last seats is charged and the cart fails to complete
  (reconcile retries + Telegram, no auto-refund). Fix: authorize-only for tickets, or reserve before payment.
- **Product call:** a seller can tag an ordinary service with a date/venue + seats to take card. This is treated as a
  product rule, not a security boundary.
- Known safe edge: an event with mixed managed/unmanaged variants looks like a ticket on public surfaces (the public
  listing ORs `manage_inventory`), and start-checkout 422s it before any charge.
- Existing priced services/rentals on card-only shops now show «Solo catálogo» (checkout already refused them).
