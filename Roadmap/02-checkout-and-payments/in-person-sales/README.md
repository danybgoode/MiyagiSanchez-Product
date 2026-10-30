---
status: in-progress  # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Building      # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: in-person-sales
title: "In person: POS-lite and payment links"
area: 02-checkout-and-payments
risk: high
type: feature
sprints_total: 4
stories_total: 12   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 94   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 50    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 300
quote_basis: "L, n=0, wide"
hypothesis: "We believe that a phone counter for in-person sales and shareable payment links will make Miyagi the one place a micro-merchant records every sale, because today their counter and chat sales live outside it. We'll know when shops record in-person sales and get paid through links, with stock and margins right."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: null   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A Mexican micro-merchant who sells at a stall, a market or by WhatsApp chat, takes cash, transfers and cards, and keeps track on paper"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist); funded as E5 of the T1 review — T1 includes a POS and payment links, and the digital-payments bill points the same way"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 13      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: In person: POS-lite and payment links

> **Area:** 02-checkout-and-payments · **Risk:** high · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/in-person-sales.md`](../../00-ideas/seeds/in-person-sales.md)
<!-- Class (above) is the Stage-2 classification: Feature, Spike, Bug, or Chore — see SKILL.md's
     Stage 2 table; sourced from scaffold-epic.mjs's --type flag (a fixed 4-value enum, not free
     text — a longer description belongs in the Why section below, not here; this comment never names
     that heading literally, so an edit anchored on it cannot land inside the comment).
     Optional: if this epic was ALSO tagged with an archetype at refining (see spike-role-archetypes.md),
     append " · **Archetype:** <Prototyper|Builder|Sweeper|Grower|Maintainer>" after Class. Omit entirely
     for the Builder default — untagged is fine.
     Scope-seed link: always points at seeds/ — lifecycle lives in the seed's `status:` frontmatter, not
     in a folder path (see 00-ideas/README.md). If this epic was scaffolded from a doc that has no seeds/
     entry, link that doc instead and migrate it to seeds/ when convenient — don't fabricate a seeds/ file
     that doesn't exist. -->

## Why
A Mexican micro-merchant sells mostly at a stall, a market or in a WhatsApp chat, and Miyagi only sees the online
checkout. This epic gives them a phone **counter** («Vender en persona»): tap products, then take cash (works without
signal), a card by QR the buyer pays on their own phone, or a transfer (SPEI / DiMo). They also get **payment links**
(«Cobrar con un link») for catalog products or any amount with a concept. Every sale is a real Medusa order on the
shop's own rails, so stock, Ganancias and the orders inbox are right. It ports Despacho Bonsai's POS **UX** and
rebuilds its core, which recorded "card" sales with no charge, kept orders outside Medusa and priced in USD.

## Platform-first note
Everything commerce stays in Medusa: in-person and link sales are Medusa orders on the shop's **existing operating
sales channel**, tagged `metadata.source` (`in_person` | `payment_link`). No new sales channel, because channel
membership decides buyability and every channel writer is guarded by the `sales-channel-writers.ts` registry. Payment
links are a Medusa model. Payments reuse the existing providers and webhooks unchanged; walk-in buyers get no Clerk
account (the ML-order precedent).

## Architecture lock — verified decisions (2026-10-29)

Verified against backend `61bb642` (Medusa **2.21.2**), storefront `4486da8`, and live data: the public store API
(the storefront publishable key resolves to the MX operating channel and lists **121** products) and Supabase
(`marketplace_shops`: 59 rows, 17 claimed). VM database reads are refused by the auto-mode classifier, so every
live check of the Medusa DB in this epic is **behavioural** (a route's response), never a direct query.

**Scope the live system corrects (said out loud):**
- **There is no per-shop operating channel.** The operating channel is one per **market**
  (`MEDUSA_MX_OPERATING_CHANNEL_ID`, `lib/market-medusa.ts` `resolveOperatingChannelId`). "Every shop that can sell has
  an operating channel" is therefore one fact, not 59: the MX channel exists and carries the catalog (121 products via
  the storefront key). Every in-person and link cart is created on it.
- **A variant-less custom line cannot be used for «Cobro libre» (S4.2).** The seller's orders inbox finds orders by
  product ownership (`listOrdersForSeller` → `sellerOwnsEveryOrderItem`), and `confirm-payment` refuses an order it
  cannot attribute. A line with no product would make the paid order invisible to its own seller. See D14.
- **"Inventory decremented" means the available quantity** (stocked − reserved), the number every surface reads
  (`getProductAvailableQuantity`). `completeCartWorkflow` reserves stock for online orders today; counter sales use the
  same mechanism. Only the offline-oversell fallback (D12) adjusts stocked quantity directly, as ML sync does.
- **The service worker (`public/sw.js`) has no fetch handler.** It only handles push, so "the queue survives a reload
  while offline" (S3) needs a fetch handler scoped to the counter page. See D11.
- **The kickoff's `scripts/epic-phase.mjs` and `scripts/intent-reader.mjs` do not exist** (not in this repo, not in
  golden-frijoles 1.17.3). The phase is stamped by hand in this frontmatter; the intent reader did not run.

**Found outside scope (owed to Daniel, not fixed here):** `POST /store/carts/:id/start-checkout` takes
`body.offer_amount_cents` from any publishable-key caller and bills it as the item price, with no check against an
accepted offer (`start-checkout/route.ts`, `rawItemsCents`). Anyone can create a cart and pay any amount for any
product. This epic's carts never send it and the route ignores it for `in_person` / `payment_link` carts (D8), but the
hole stays open for normal carts. The offers live in Supabase, so the fix needs its own small design.

**Found at build, outside scope, owed to Daniel (a production money-config write, so asked, not done):** the live
MX region's payment providers are `pp_system_default`, `pp_stripe-connect_stripe-connect`, `pp_mercadopago_mercadopago`,
`pp_spei_spei` and `pp_cash_cash` (`GET /store/payment-providers?region_id=reg_01KSK1HZAWN5ZCSPZ74ER97HD9`). Since
2026-06-01 every «Pago directo» checkout opens its session on `pp_manual_manual`, and Medusa 2.21.2's
`validate-cart-payments` refuses to complete a cart whose provider the region lacks. So live «Pago directo» orders
are expected to fail at `/complete`, and `setup-mexico`'s `MX_PAYMENT_PROVIDERS` does not list the provider. S2.2
(transfer at the counter, D10) needs it too. The fix is to add `pp_manual_manual` to the list and run `setup-mexico`.

1. **D1 — Channel and market.** Counter and link carts are created server-side on the MX operating channel and the MX
   region (`resolveOperatingChannelId('mx')`, `resolveRegionIdForMarket('mx')`). MX sellers only: a seller whose
   `readSellerOperatingMarket` is not `mx` gets 422 `IN_PERSON_MX_ONLY`. No sales-channel writer is added, so the
   `sales-channel-writers` registry spec stays green unchanged.
2. **D2 — Every sale is a cart that completes.** The S1.2 route runs `createCartWorkflow` (no `customer_id`),
   `addToCartWorkflow` (variants at their stored prices), a $0 shipping method on the seeded `pickup` option
   (`resolveShippingOptionIds`, as `start-checkout` does), a payment collection and session, then
   `completeCartWorkflow`. This keeps the availability check and reservation, and emits `order.placed`, so the profit
   ledger subscriber runs unchanged. `createOrdersStep` is used only for D12.
3. **D3 — Ownership is proved on the variant.** Every requested `variant_id` must belong to a product linked to the
   authenticated seller (`resolveSellerProductIds`, then the variant must be in that product's own variant list — the
   admission-proof learning). Support and hidden products are refused. One bad line refuses the whole sale (422).
   Quantities are integers from 1 to 999; at most 50 lines.
4. **D4 — Exactly once is a database constraint.** A new Medusa module `in_person` with model `in_person_sale`
   (`seller_id`, `client_id`, `kind` cash|card|transfer, `status` claimed|completed|cancelled|failed, `cart_id`,
   `order_id`, `payload_hash`, `offline`, `oversold`, `claimed_at`) and a **unique index on (`seller_id`,
   `client_id`)**. Order: validate (pure) → claim (insert; a unique violation means a replay) → apply. A replay of a
   completed sale returns its order with `replayed: true`. The same `client_id` with a different payload returns 409
   `CLIENT_ID_REUSED`. A claim younger than 60 s returns 409 `IN_PROGRESS` and the client retries. An older claim is
   taken over, and the takeover reuses the recorded `cart_id`: `completeCartWorkflow` on a completed cart returns
   that cart's order, so a takeover cannot create a second order. `cart_id` is written to the claim before the cart
   is completed. Redis is not used: Redis-specific behaviour is ungated in CI. `client_id` must be a UUID.
5. **D5 — Cash is captured at once.** Provider **`pp_cash_cash`** (amended at build, 2026-10-30: the live MX region
   enables `pp_cash_cash` but not `pp_manual_manual`, and `completeCartWorkflow` refuses a provider the region lacks;
   same `ManualMxPaymentProvider` class) with data `{ payment_method: 'cash' }`. The order is captured with `capturePaymentWorkflow`, reusing `confirm-payment`'s
   capture code rather than copying it. Order metadata: `source: 'in_person'`, `payment_method: 'cash'`,
   `payment_received: true`, `in_person: { client_id, kind, tendered_cents, change_cents, sold_at, offline }`, so
   `normalizeMedusaOrder` reports it as captured. `tendered_cents` must be at least the total (or absent).
6. **D6 — Buyer.** No account and no Clerk user (amended at build: `createCartWorkflow` makes a Medusa **guest**
   customer from the email, as every guest checkout does — `has_account: false`, no `clerk_user_id`). Email is the buyer's when the merchant types one; otherwise it is
   the constant `mostrador@sin-correo.miyagisanchez.com`, and `metadata.in_person.buyer_email_placeholder: true`
   means nothing is ever sent to it.
7. **D7 — Self-notifications.** Orders that the backend creates in S1, S2.2 and S3 never pass through the
   storefront's webhook or `upsertOrderMirror`, which is the only place that emails a seller about a sale. S2.1's card
   QR does pass through it, so S2.3 makes both webhooks skip the seller email and seller dispatch when the provider
   metadata says `source: in_person`. Buyer email goes only to a typed address.
8. **D8 — `start-checkout` reads the source from the CART, never the body.** When `cart.metadata.source` is
   `in_person` or `payment_link` (written only by our server routes): `offer_amount_cents`, coupons and bundles are
   ignored (the server total is the price); the provider metadata carries `source` (and `payment_link_id`); the
   success and cancel URLs go to the neutral `/pago/listo` page. `in_person` also skips the coordinated-delivery
   guard (the goods are handed over at the counter) and sets a 30-minute session expiry (Stripe `expires_at`, MP
   `expiration_date_to`).
9. **D9 — Card by QR (S2.1).** The counter claims a `card` sale (D4), and the backend builds the cart. The storefront
   server route then calls the backend's `start-checkout` directly with the shop's provider: the backend, never our
   own authed Next route, per the cookie learning. The QR encodes `redirect_url`. Paid means the webhook completed the
   cart into an order with captured payment. The counter polls `GET /store/sellers/me/in-person-orders/:client_id`
   every 3 s, and that status is read from Medusa, never from the client. `POST …/:client_id/cancel` expires the Stripe
   session or the MP preference and marks the claim cancelled. A buyer who pays in the seconds after a cancel gets a
   real paid order, and the status shows it: money taken is never hidden.
10. **D10 — Transfer (S2.2).** Same claim, kind `transfer`. The cart runs `start-checkout` with `provider: 'manual'`
    (the live branch that snapshots CLABE / DiMo; no config gives 422 `SELLER_MANUAL_MISSING`, which the counter
    shows), then it is completed, so the order is `pending_payment`. «Ya me llegó» calls the existing
    `PATCH /store/sellers/me/orders/:id/confirm-payment`. Nothing is confirmed automatically.
11. **D11 — Offline (S3.1).** A pure queue state machine in `lib/in-person/sale-queue.ts` (enqueue, send, ack on a
    returned order id, retry with backoff, never drop) sits behind a thin IndexedDB adapter. `client_id` is minted when
    the sale is made (`crypto.randomUUID`), so a resend is a D4 replay. The sync posts `offline: true` with `sold_at`.
    `public/sw.js` gets a fetch handler that answers **only** for the counter route and for requests made by a page on
    that route (`clients.get(event.clientId)`), network first with a cached fallback. Every other request returns
    without `respondWith`, so navigation everywhere else is untouched.
12. **D12 — Oversell (S3.2).** Only for `offline: true`: when `completeCartWorkflow` fails on stock, the route creates
    the order with `createOrdersStep` (the `ml-order-materialize.ts` composition), decrements stock capped at what is
    available (`safeDecrement`, then `adjustInventory`), writes `metadata.oversold` with the shortfall per variant, and
    calls `appendOrderLedger` directly, because `createOrdersStep` emits no event. The order carries
    `metadata.in_person.client_id`. Before creating, a takeover looks for an existing order with that client id, so the
    fallback is also exactly once. Online sales keep the normal stock check (409 `OUT_OF_STOCK` with the variants).
13. **D13 — `payment_link` model (S4.1)** in the same `in_person` module. Fields: `seller_id`; `token` (32 random
    bytes, base64url, unique); `kind` products|amount; `lines` [{variant_id, quantity}] or `concept` (3–80 chars) plus
    `amount_cents` ($10–$50,000 MXN); `uses` single|multi; `expires_at` (default 7 days, maximum 30); `status`
    pending|paid|cancelled; `paid_order_ids`; `short_url`. **Expired is derived** from `expires_at` when read, with no
    cron. The order's payment drives `paid`: an `order.placed` subscriber appends the order and, for a single-use link,
    sets `paid`. A second payment on a single-use link (two buyers who both opened it before either paid) is recorded,
    not refunded, and shown.
14. **D14 — «Cobro libre» is a line on a per-seller hidden product.** It follows the support-product precedent
    (`support-product-ensure.ts`): one ensure-idempotent product per seller with `hidden_from_catalog: true`,
    `is_payment_link_product: true` and `manage_inventory: false`, created through `createSellerProduct`, so no new
    channel writer. The line is added server-side with `unit_price` = amount and title = concept. The installed
    `addToCartWorkflow` supports a custom price (`isCustomPrice` in core-flows 2.21.2). Providers bill the cart total,
    so no provider needs its own path, and the inbox, `confirm-payment` and Ganancias see the order normally.
15. **D15 — `/pagar/[token]` (S4.2).** `GET /store/payment-links/:token` is public and returns display data only (shop
    name and logo, concept or lines, amount, status, the shop's methods). «Pagar» calls
    `POST /store/payment-links/:token/cart`, which refuses paid single-use, expired and cancelled links, builds a fresh
    cart server-side (D2, `source: payment_link`, `payment_link_id`), and hands it to `start-checkout`. Fulfilment:
    `digital` for amount links and `local_pickup` («Entrega acordada con la tienda») for product links. The page is
    `noindex` with `Cache-Control: private, no-store`.
16. **D16 — Sharing and agents.** The short link comes from `lib/shortlink.ts` (`mschz.org`), the QR from `qrcode`,
    and WhatsApp from `lib/share-link.ts`. The MCP tools (`create_payment_link`, `list_payment_links`,
    `cancel_payment_link`) follow the existing seller-tool pattern: an `ms_agent_` token scoped to one shop, then
    backend `/internal/sellers/:id/payment-links` with the internal secret, sharing the same lib core and validation
    as the Clerk routes. Another shop is never reachable.
17. **D17 — Ganancias source (S2.3).** `appendOrderLedger` maps `metadata.source` to `native | mercadolibre |
    in_person | payment_link` (the column is `text`, so no migration). The inbox badge and filter read
    `metadata.source`.
18. **D18 — Migrations.** The `in_person` module ships its own Medusa migrations: `in_person_sale` in S1 and
    `payment_link` in S4. Medusa migrates **on boot** when `update.sh` starts the new image, and merging deploys
    nothing. So "apply before merge" becomes merge, image build, `update.sh`, then a behavioural check (the new route
    answers, not 500). Both tables are new and empty, so there is no data premise to re-verify.
19. **D19 — Routing.** The orchestrator (Opus 5.5) builds every backend money-path story (S1.2, S2.1, S2.2, S3,
    S4.1, S4.2). UI stories (S1.3, S4.3) and S4.4 go to a Sonnet builder in its own worktree, citing these Ds. Review
    on every PR: `review-route.mjs` (general pass plus the security lens; every PR here touches money paths) and a
    fresh `verifier`.
20. **D20 — Stacking.** One PR per sprint per repo touched. Branches are `feat/in-person-sales` (S1), then `-s2`,
    `-s3`, `-s4` in both app repos, merged in order, backend before storefront in each sprint.

**Amendments at build (S2, 2026-10-30), from review:**
- **D4:** a card or transfer claim settles in `awaiting_payment` once its cart exists. A resend returns the same cart
  (`decideExistingClaim` → `awaiting`).
- **D8:** `cart.metadata.source` is client-writable through Medusa's public cart routes, so `start-checkout` treats
  a cart as a counter cart only when an `in_person_sale` claim records that cart id. It opens a checkout only while
  the claim is `awaiting_payment`, and only once (`CHECKOUT_EXISTS`). Counter carts never use escrow.
- **D9:** a card sale is `paid` only when its order's payment came from `pp_stripe-connect_stripe-connect` or
  `pp_mercadopago_mercadopago`. A buyer can switch a public cart's session to `pp_cash_cash` and complete it; that
  order is reported as `unverified`, never as paid. Cancel refuses with `PAYMENT_IN_PROGRESS` while a Stripe session
  is `complete` or a Mercado Pago payment is approved or in process.

**Amendments at build (S3, 2026-10-30), from review:**
- **D4 / D12 — locking.** The offline-oversell fallback uses Medusa's locking module, not only the database. Its stock
  plan and decrement run under `locking.execute(inventoryItemIds)`, the same keys `reserveInventoryStep` takes, so they
  serialise with online reservations. Its check-then-create runs under a per-claim key. In production this is Redis
  locking; CI runs the in-memory provider, so Redis-specific lock behaviour stays ungated. Exactly once still rests on
  the claim's unique index and a token fence.
- **D12 — resumable.** A claim that reached the fallback (`metadata.oversold_fallback_at`) resumes the fallback on
  takeover. It adopts the order it already created, and the cart path never runs again. Stock is taken from a stored
  plan with per-line `applied` markers.
- **D11 — service-worker scope.** The counter's fetch handler decides scope from the request referrer, not from
  `clients.get(event.clientId)`. `respondWith` must be decided synchronously, and an async lookup would mean
  intercepting every request on the site.

### Sprint 1 — Build contract (locked by the architect before the builder started)
- **Backend:** module `src/modules/in-person` (D4 model + migration); pure `src/lib/in-person-sale.ts` (validate
  payload, payload hash, the claim-outcome decision); `POST /store/sellers/me/in-person-orders` (Clerk `resolveSeller`)
  over a shared core `recordInPersonSale(scope, sellerId, input)`; D1–D6. Unit specs: validation, the claim decision
  (fresh, replay, reuse, in-progress, stale), each observed red under a mutation. Integration spec in
  `integration-tests/http/`: one cash order on the channel, stock reserved, `order.placed` fired; replay returns the
  same order; two concurrent calls give one order; another seller's variant is refused.
- **Storefront:** pure `lib/in-person/counter-cart.ts` (S1.1: integer centavos, change, «falta»), spec'd in the
  Playwright `api` project; `/shop/manage/en-persona` (S1.3); a proxy `app/api/shop/en-persona/sales/route.ts` that
  forwards the Clerk JWT to the backend; a SellerNav entry.

### Sprint 2 — Build contract (locked by the architect before the builder started)
- **Backend:** D8 in `start-checkout` (source from the cart); `kind: card | transfer` in the S1 route; `GET` status and
  `POST cancel` (D9); D10.
- **Storefront:** QR and transfer states on the counter, plus the `/pago/listo` page; webhooks skip the seller email
  for `source: in_person` (D7); inbox badge and filter; Ganancias source (D17); «Mandar recibo».

### Sprint 3 — Build contract (locked by the architect before the builder started)
- **Storefront:** D11 queue, IndexedDB adapter, banner, and the scoped `sw.js` fetch handler.
- **Backend:** D12 fallback for `offline: true`; inbox flag «Vendiste más de lo que tenías en inventario».

### Sprint 4 — Build contract (locked by the architect before the builder started)
- **Backend:** D13 model + migration; D14 ensure-product; Clerk routes for create, list and cancel; public token
  routes (D15); `order.placed` link subscriber; internal routes for agents (D16).
- **Storefront:** `/pagar/[token]`, `/shop/manage/cobros`, and the MCP tools.

## What already exists (reuse, don't rebuild)
- `apps/backend/src/modules/payment-{mercadopago,stripe-connect,spei,manual-mx,cash,manual}`: every counter and link payment
- `api/store/carts/[id]/start-checkout` (MP Preference / Stripe Checkout Session → `checkout_url`): the counter QR and the pay page
- `lib/manual-payment-state.ts` + the backend normalizer + `report-payment`: SPEI / DiMo / cash states
- The owned-shop operating channel and `lib/sales-channel-writers.ts` registry: where these orders live
- `lib/ml-order-materialize.ts` (`createOrdersStep` without the availability check): the offline-sync precedent
- `app/(shell)/shop/manage/orders/*`: source badge and filter
- `modules/profit` + `lib/profit-ledger*.ts`: Ganancias counts every sale
- `lib/shortlink.ts`, `qrcode`, `lib/share-link.ts`: link sharing and receipts
- `app/api/ucp/mcp/route.ts`: payment-link tools
- `despachobonsai/app/dashboard/commerce/pos/PosClient.tsx`: UX reference only (grid, tendered/change, IndexedDB queue, `client_id`)

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 Pure counter cart: lines, totals, change | low |
| 1 | S1.2 In-person order route: idempotent client id, operating channel, `source: in_person`, stock, cash paid | high |
| 1 | S1.3 «Vender en persona» counter screen | low |
| 2 | S2.1 QR card payment through the shop's checkout + wait for the webhook | high |
| 2 | S2.2 SPEI / DiMo at the counter + «Ya me llegó» capture | high |
| 2 | S2.3 Inbox + Ganancias source, no self-notifications, optional buyer receipt | low |
| 3 | S3.1 IndexedDB queue + exactly-once sync | high |
| 3 | S3.2 Oversell on sync: recorded and flagged | high |
| 4 | S4.1 `payment_link` model + create/cancel routes | high |
| 4 | S4.2 `/pagar/[token]` → cart → existing checkout; free amount as a custom line | high |
| 4 | S4.3 «Cobrar con un link» UI + shares + statuses | low |
| 4 | S4.4 MCP payment-link tools for seller agents | low |

**Decisions at plan time (Daniel, 2026-10-27):** card at the counter is a QR the buyer pays on their own phone
(Mercado Pago Point terminals later); payment links charge products or any amount; cash sales work offline; appetite L.

**Flag:** none (WAYS-OF-WORKING default); rollback is `git revert`. The code creates orders and links; it never moves
money itself — the existing providers and webhooks do.

## Deploy order
1. An **architecture-locking pass** before S1: confirm Medusa v2 custom line items through each payment provider, the
   workflow composition for offline sync, the idempotency constraint (a DB constraint, not Redis — Redis is ungated in
   the money-path CI), and that every shop that can sell has an operating channel.
2. **Backend first** each sprint (any new model ships as a Medusa migration with the backend image; how it runs on the
   VM is confirmed at the lock, orchestrator-owned), then the storefront.
3. Each sprint merges to `main`, both arm64 images build, then
   `ssh -i ~/.ssh/panfleto_oci ubuntu@159.54.158.4 /opt/miyagi/infra/oci/update.sh`. Verify on `main` after deploy.

## Definition of Done (epic)
- [ ] All sprints merged to `main` + smoke-tested (gaps stated — `node scripts/owed-ledger.mjs` counts what is still owed)
- [ ] Each `sprint-N.md` has its smoke walkthrough (real URLs)
- [ ] This README marked ✅; every sprint status ticked with commit refs
- [ ] `RETROSPECTIVE.md` written
- [ ] Product poster (`Roadmap/README.md`) updated
- [ ] Team memory + `MEMORY.md` index updated
- [ ] Durable learnings promoted to `Roadmap/LEARNINGS.md` (dedupe — sharpen, don't append)
- [ ] **Kill-switch (only if one was planned at refining — Stage 6b):** the flag slice shipped, the flag
      exists **in Golden Frijoles, in every env**, with the stated polarity, **and its switch is set there** —
      `frijoles flags get <key>` must print `on vN` or `off vN` in its PRODUCTION row (a bare `off` with no version
      means nothing is served there, so the app runs on its own built-in default). A newly synced flag goes live as written in its file; a sync never switches an existing one. *Verify-only — not a new gate; whether a high-risk epic needs one
      is decided at refining, not here.*
- [ ] Feature branch deleted; **this README's frontmatter `status: shipped`** (the SSOT — the board & Notion derive from it; run `node scripts/build-order.mjs`)
