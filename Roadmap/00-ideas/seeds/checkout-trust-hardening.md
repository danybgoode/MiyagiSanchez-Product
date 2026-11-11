---
title: "Checkout trusts nothing the caller names: zero totals, shipping quotes, offer reuse"
slug: checkout-trust-hardening
status: raw
area: "02"
type: bug
priority: null
risk: high
epic: null
build_order: null
updated: 2026-11-11
---

# Raw seed: checkout trust hardening

Surfaced by the reviews of merchant-panel-gaps (storefront #491, backend #231) on 2026-11-11. Backend #231 closed the
worst hole: `offer_amount_cents` used to be charged exactly as the caller sent it. These are the same kind of
hole, still open:

1. **Shipping is charged at the caller's price.** In backend `start-checkout`, `normalizeShippingQuote` takes
   `shipping_quote.amount_cents` from the body and charges it as its own Stripe or Mercado Pago line, with no check
   against Envía. A buyer can pay 1 centavo of shipping, and the seller absorbs the label cost.
2. **No zero-total refusal in the backend.** The storefront refuses any $0 line before start-checkout, but the public
   Medusa store route is reachable directly. Refuse a final item amount ≤ 0 in start-checkout itself.
3. **One accepted offer can open several checkouts.** The offer stays `accepted` until it is reconciled as paid,
   indefinitely when `checkout_expires_at` is null (a seller without Stripe). Reserve or consume the offer atomically
   at checkout start.
4. **Review coverage:** `scripts/review-config.json` `securityPaths` misses `**/*checkout*` and `**/*checkout*/**`, so
   the backend charge route sat outside the security lens.

Also from the same reviews, lower stakes: an automatic repair when a free Evento's RSVP-row sync fails after a listing
save. And a $0 Evento is Mexico-only, because the US create path requires a positive price.
