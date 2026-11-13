---
title: "US commerce parity: shipping, plans, tax and the tools Mexican shops already have"
slug: us-commerce-parity
status: raw
area: "07-agentic-and-federated-commerce"
type: feature
appetite: null
underwritten_by: null
risk: high
epic: null
build_order: null
updated: 2026-11-12
intent_ask: verbatim
hypothesis: null
persona: "A small US merchant — including Spanish-speaking US merchants — selling online in dollars"
grounded: false
grounded_reason: "No North Star strategy exists in Roadmap/00-strategy/."
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

# Idea — US commerce parity

Moves · Tests: not grounded — no strategy yet

Split out of `one-front-door-both-markets` (2026-11-12). That epic makes the builder create US shops; this one makes a US shop as complete as a Mexican one.

## The ask, as given

> lets extend all the new features to the US as well, i see no reason why keep it off … Lets of course review the us market and persona needs
> for the us what gaps in the product do we have? from my memory one key gap is shipping overall but im sure theres plenty

> Additionaly run market research to come up with price points for us. yes compare shipping providers.

> yes to all, L, $9/$90, 1 photo, remove everywhere

## Decisions already made by the product owner (2026-11-12)

- **Plan Tienda US: $9 a month or $90 a year**, with the same 90-day trial as Mexico. (Negocio US price still open.)
- **Shipping provider: EasyPost**, Forge with EasyPost-managed (decentralized) billing — each merchant a sub-account billed directly, the platform carries no shipping liability.
- **Sales tax is in scope** for this epic.
- **Spanish for US merchants: yes.**

## Gaps (verified in code on storefront `origin/main` b8729e5 unless marked)

1. **Shipping** — `lib/checkout-market-strategy.ts` refuses `shipping` for `us` (`US_CARRIER_UNAVAILABLE`); Envía is MX→MX in MXN only (`lib/envia.ts:173`). us-marketplace D18's evidence gate still needs Daniel's EasyPost account, a US origin ZIP and a representative parcel.
2. **Plans** — trial/pause/notices are Mexico-only (`lib/plan-pause.ts:61`, `lib/negocio-trial-notices.ts:61`); no USD Plan Tienda price.
3. **Payments** — US = Stripe card only (`US_ONLINE_PAYMENT_REQUIRED`); `/shop/manage/cobros` and `/shop/manage/en-persona` are MX-only (backend `IN_PERSON_MX_ONLY`). US in-person = Stripe Tap to Pay.
4. **Sales tax** — nothing exists. Marketplace-facilitator rules may apply to `/us` sales: legal question first; Stripe Tax is the likely tool. *(not verified)*
5. **Seller portal in English** — ~550 strings es-MX as of 2026-08-12 (memory; not re-counted).
6. **US landings** — 1 (`/us/sell`) vs ~20 Mexican persona pages.
7. **Importers** — no Etsy or Square; no US equivalent of the Mercado Libre channel (Google Merchant Center).
8. **Sweepstakes** — Buen Fin framing; some US states have registration rules. *(not verified)*
9. **Owed** — the first real USD charge (us-marketplace, Daniel's by design).

## Research (2026-11-12)

US monthly prices: Big Cartel free (5 products) · $15 · $30 ($12/$24 annual) · Square Online free · $49 · $149 · Squarespace ≈ $23–29 · Wix $29 · Shopify $39 ($29 annual). Mexico Plan Tienda = $228 MXN/yr or $29 MXN/mo.
Sources: [Big Cartel pricing](https://checkthat.ai/brands/big-cartel/pricing), [Shopify alternatives priced](https://retailpresso.com/reviews/shopify-alternatives), [Squarespace](https://www.squarespace.com/blog/shopify-alternatives).

Shipping APIs: EasyPost — 3,000 free labels/mo, then $0.08/label, Forge for platforms ([Forge](https://docs.easypost.com/guides/forge-overview), [how Forge works](https://docs.easypost.com/guides/how-forge-works)). Shippo — $0.05–0.07/label (sources conflict), no platform-account docs found. ShipEngine — folding into ShipStation API, $75–600/mo. Sources: [RevAddress 2026](https://revaddress.com/blog/shipping-api-comparison-2026/), [carrier API pricing](https://www.carrierintegrations.com/carrier-api-pricing-2026-what-7-platforms-charge/), [AfterShip](https://www.aftership.com/blog/easypost-vs-shippo).
