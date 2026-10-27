---
epic: envia-byo-connect
sprint: 2
title: "Ship on their account"
risk: high
phase: Shaping
stories_total: 4
stories:
  - id: S2.1
    title: "envia-client per-call token + environment; quote and checkout-options threaded"
    as_a: "a buyer at checkout"
    i_want: "shipping quotes from the merchant's own Envía rates"
    so_that: "I pay the price the merchant's carrier actually charges"
    risk: high
    status: planned
  - id: S2.2
    title: "Label path, fulfillment provider and profit ledger threaded; legacy frontend path retired"
    as_a: "a merchant shipping an order"
    i_want: "to print the label on my own Envía account"
    so_that: "the label is paid from my balance and my margins stay right"
    risk: high
    status: planned
  - id: S2.3
    title: "Webhook registration at connect/disconnect + per-connection receiver auth + surcharge notice"
    as_a: "a merchant with a connected account"
    i_want: "tracking updates and surcharge notices to arrive on their own"
    so_that: "my buyer sees where the parcel is without me touching Envía's developer settings"
    risk: high
    status: planned
  - id: S2.4
    title: "es-MX error mapping + manual-ship fallback"
    as_a: "a merchant whose label fails"
    i_want: "a plain message that tells me the fix is in my Envía account, and a way to still ship"
    so_that: "an empty balance or a revoked key never strands an order"
    risk: high
    status: planned
---
# BYO Envía connect — Sprint 2: Ship on their account

**Status:** ⬜ not started

## Stories

### Story 2.1 — envia-client per-call token + environment; quote and checkout-options threaded
**As** a buyer at checkout, **I want** shipping quotes from the merchant's own Envía rates, **so that** I pay the price the merchant's carrier actually charges.
**Acceptance:** Every `envia-client` call takes `{ token, environment }`; the host follows the environment; with none given it keeps today's platform behaviour. `store/envia/rates`, `sellers/[slug]/checkout-options` and `carts/[id]/start-checkout` resolve the owning seller and call the S1.3 seam once. The locking pass sweeps every importer of `envia-client` and lists them here. Confirm the shipping line reaches the seller's own rail under every payment method (no platform money). Covered by the backend money-path CI gate.
**Risk:** high

### Story 2.2 — Label path, fulfillment provider and profit ledger threaded; legacy frontend path retired
**As** a merchant shipping an order, **I want** to print the label on my own Envía account, **so that** the label is paid from my balance and my margins stay right.
**Acceptance:** `sellers/me/orders/[id]/ship`, `modules/fulfillment-envia/service.ts` and `lib/ml-fulfillment-apply.ts` use the resolved credential; `parseEnviaLabelCost` still records the label cost in the profit ledger. The frontend `app/api/orders/[id]/ship` legacy direct-Envía branch is removed (Medusa orders already proxy); the locking pass counts unshipped legacy orders, which ship manually. The platform account shows no label for a connected shop.
**Risk:** high

### Story 2.3 — Webhook registration at connect/disconnect + per-connection receiver auth + surcharge notice
**As** a merchant with a connected account, **I want** tracking updates and surcharge notices to arrive on their own, **so that** my buyer sees where the parcel is without me touching Envía's developer settings.
**Acceptance:** On connect, the backend registers `tracking.simple` (type 3) and `surcharge` (type 5) webhooks on the merchant's account with our own per-connection bearer in `Authorization` (only its hash is stored); on disconnect it deactivates them. The receiver matches the bearer to the connection before trusting a payload, dedupes on `X-Webhook-Id`, and answers 2xx within 5 s. A surcharge event creates a seller notice through `lib/notifications/*`. The locking pass confirms registration and delivery on a sandbox account; the platform's own webhook keeps working unchanged.
**Risk:** high

### Story 2.4 — es-MX error mapping + manual-ship fallback
**As** a merchant whose label fails, **I want** a plain message that tells me the fix is in my Envía account, and a way to still ship, **so that** an empty balance or a revoked key never strands an order.
**Acceptance:** `mapEnviaError` maps the seller-account auth and balance failures to «Tu cuenta de Envía no tiene saldo suficiente. Recárgala en envia.com y vuelve a intentarlo, o envía con paquetería manual.» and «Tu clave de Envía ya no funciona. Pégala de nuevo en Envíos.»; a 401 marks the connection invalid; the order page offers «Enviar con paquetería manual». No retry on the platform key (spec-asserted).
**Risk:** high

## Sprint QA
- **backend integration specs:** quote, start-checkout and label through the money-path CI gate with a fixture seller connection (sandbox host stubbed); the no-platform-retry assertion; webhook bearer accept/reject + dedupe
- **api specs:** token never appears in any quote, checkout-options, ship or MCP response
- **browser smoke owed:** the sandbox walkthrough below on the test shop, plus **one real production label owed to Daniel by name**
- **review:** fresh pr-reviewer + codex cross-family pass + the security lens (money path + credentials)
- **deterministic gate:** backend `npm test` + money-path CI gate; frontend `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. As a buyer, add a product from the connected test shop to the cart at https://miyagisanchez.com and go to checkout with a real CP
   → carrier rates appear; they match the test shop's Envía sandbox quote
2. Complete the order with a test payment
   → the order shows the chosen carrier
3. As the shop, open the order and print the label
   → a label prints marked PRUEBA; the Envía sandbox dashboard shows it; the platform account does not
4. Wait for (or trigger in Envía sandbox) a tracking update
   → the order moves to «En camino»
5. Empty the sandbox balance (or revoke the key in Envía) and print another label
   → the es-MX message naming your Envía account, plus «Enviar con paquetería manual»
6. (money, owed to Daniel) On a real shop with a production key, print one real label
   → it's charged to that shop's Envía balance, not the platform's

If any step fails, note the step number + what you saw — that's the bug report.
