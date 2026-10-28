---
status: scaffolded   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Shaping       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
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
build_order: 12      # integer position in the ONE global build sequence — the SSOT once the epic
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
