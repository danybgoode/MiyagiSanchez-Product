---
title: "Checkout trusts nothing the caller names: zero totals, shipping quotes, offer reuse"
slug: checkout-trust-hardening
status: scaffolded
area: "02-checkout-and-payments"
type: bug
appetite: S
underwritten_by: wave-2026-11
risk: high
epic: "02-checkout-and-payments/checkout-trust-hardening"
build_order: 19
updated: 2026-11-11
intent_ask: proxy
hypothesis: "Checkout still charges amounts the buyer's request names: a shipping price, a $0 line, a reused offer. Making the server re-derive or sign each of them keeps every peso of a sale correct. We'll know when a forged shipping price, a $0 cart and a second checkout on one offer are all refused."
persona: "A merchant whose buyer pays through Miyagi Sánchez checkout, and who must never absorb a forged shipping price or a discount they never agreed to"
grounded: false
grounded_reason: "No strategy yet; funded because the holes are live money defects found in review on 2026-11-11 and Daniel said carry on, ship it all"
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

# Pitch — Checkout trusts nothing the caller names

Moves · Tests: not grounded — no strategy yet

## The ask, as given

> carry on, ship it all to production

(Daniel, 2026-11-11, after the merchant-panel-gaps close listed these as follow-ups.)

### Claims
1. A shipping price is charged only when the server issued it.
2. A $0 item amount is refused by the backend itself.
3. One accepted offer opens one checkout at a time.
4. The review rail treats every checkout path as a security path.

**Teach-back:** yes — "You want the remaining checkout holes closed and live, so no buyer can name their own price. Right?"

## Appetite
S — fixed-scope bug lane. quote: $5–40 (S, n=0, wide)

## Bill of materials
| What | Why |
|---|---|
| Envia rates route signs each rate (HMAC, expiry); start-checkout charges only a valid signed rate | Shipping is charged at the caller's price today |
| start-checkout refuses a final item amount ≤ 0 | The storefront guard is not authoritative |
| Offer reserved atomically at checkout start (conditional update, read back) | One accepted offer can open several checkouts |
| `securityPaths` adds `**/*checkout*` | The charge route sat outside the security lens |

**No-gos:** no new env secret on the VM (derive the signing key from an existing server secret); no re-quote call to Envía at checkout; no new flags.

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
