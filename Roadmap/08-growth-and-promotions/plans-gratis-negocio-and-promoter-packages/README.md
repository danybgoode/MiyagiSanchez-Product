---
status: shipped       # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Shipped        # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: plans-gratis-negocio-and-promoter-packages
title: "Two plans (Gratis + Negocio), a 30-day trial, and three promoter packages"
area: 08-growth-and-promotions
risk: high
type: feature
sprints_total: 5
stories_total: 15   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 89   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 50    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 300
quote_basis: "L, n=1, wide"
hypothesis: "Shops promoters open cannot become paying customers today. Two plans, a 30-day Negocio trial and three promoter packages let a merchant see Negocio work for a month and let a promoter sell it in one sentence. We'll know when the first shops pay for Negocio."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: "Shops paying for Negocio (monthly, yearly or through a promoter package)"   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: 0   # from what, a number
target_to: 5       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A Mexican micro-merchant, often signed up in person by a promoter, deciding whether Miyagi Sánchez is worth paying for after a month of using it"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist); funded because the platform has no way to earn from the shops promoters are about to open, and the per-item add-ons cannot pay a promoter"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 14      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: Two plans (Gratis + Negocio), a 30-day trial, and three promoter packages

> **Area:** 08-growth-and-promotions · **Risk:** high · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/plans-gratis-negocio-and-promoter-packages.md`](../../00-ideas/seeds/plans-gratis-negocio-and-promoter-packages.md)
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
A merchant can buy five small add-ons today, and none of them lets the platform earn from the shops promoters are about
to open. This epic gives Miyagi Sánchez two plans: **Gratis**, free forever, and **Negocio**, $149 a month or $1,490 a
year, with the custom domain, Mercado Libre sync, the monthly check-in and much more AI. Every shop gets a 30-day
Negocio trial. Promoters sell three packages they can explain in one sentence, and fill a shop from photos in minutes.

## Platform-first note
Negocio is a **Medusa Commerce subscription plan** like the three that exist (custom domain, subdomain, ML sync),
told apart by `metadata.kind = 'negocio_plan'`; no Medusa migration. Shop-level grants (the trial, a yearly payment,
a promoter package) live on `marketplace_shops.metadata` in Supabase, exactly where the existing grants live and where
every gate already reads. One Supabase migration (M1) widens two CHECK constraints and seeds three commission rates.

## Locked decisions (architecture lock, 2026-11-04 — verified against live code `origin/main` and live data)

Live data read 2026-11-04: `marketplace_shops` 60 rows, 18 owned (`clerk_user_id` set), 30 with `subdomain_grant`,
3 with `custom_domain_grant`, 2 with `ml_sync_grant`. No shop records when it was claimed.
`ai_allowance.kind` CHECK = version · photo · daily_budget. `marketplace_promoter_transfers.sku` CHECK = custom_domain
· subdomain · ml_sync. Flags (Golden Frijoles project `miyagisanchez`, production): `subdomain.paywall_enabled` OFF
(Daniel, 2026-11-04), `domain.paywall_enabled` ON, `ml.sync_paywall_enabled` ON, `promoter.transfer_enabled` ON.

- **D1 · One pure plan seam.** `lib/plan.ts` exports `derivePlan({ trial, grant, hasActiveSubscription, now })` →
  `{ plan: 'gratis' | 'trial' | 'negocio', reason, endsAt }`. Precedence: Negocio (`comp`, a live `one_time` grant, or
  an active subscription) › a live trial › Gratis. Grants lapse on read, as `deriveDomainEntitlement` does. Every
  gate reads the plan through `lib/plan-server.ts` `resolvePlan(shop)`; nothing else decides a plan.
- **D2 · Prices live in one module.** `lib/negocio-pricing.ts`: monthly 149, yearly 1,490 (MXN). Every surface
  imports them; `e2e/pricing-source-sweep.spec.ts` keeps typed prices out of copy.
- **D3 · Monthly is a subscription, yearly is one payment.** Monthly: `createSubscriptionCheckout` on the Negocio
  plan's Stripe price (the Medusa plan row, seeded by `scripts/seed-negocio-plan.mjs`). Yearly:
  `createOneTimeCheckout` with inline `price_data`, granting 12 months, with card installments
  (`payment_method_options.card.installments.enabled`) — Stripe offers installments only on one-time payments. If
  the account refuses installments, yearly ships without them and the PR says so (never faked).
- **D4 · The trial is a dated grant stamped once.** `metadata.negocio_trial = { started_at, expires_at }`
  (30 days). Stamped by a conditional write (`.is('metadata->negocio_trial', null)`, `.select()` back) the first
  time an **owned** shop's owner loads `/shop/manage`, never on a public read. A shop gets one trial ever; it is never
  re-stamped, and a shop that already holds a Negocio grant is not stamped. **Existing owned shops (decision a)** get
  it from a one-shot backfill, `scripts/backfill-negocio-trial.mjs` (`--dry-run` / `--apply`), planned by a pure
  function in the style of `lib/paywall-grandfather.ts`. A promoter's unclaimed shop has no owner, so its trial
  starts at claim, when the merchant first opens the panel.
- **D5 · What opens what.** The existing composers stay the single choke point and take the plan as one more input:
  custom domain ← Negocio paid only (not trial); ML sync ← Negocio paid or trial. Reasons `negocio` and `trial` join
  the existing ones. **Every existing grant and standalone subscription keeps entitling** (Daniel: keep what they
  paid for).
- **D6 · One webhook kind.** `NEGOCIO_CHECKOUT_KIND = 'negocio'`. Subscription complete → the Medusa subscription
  (clone of the ML-sync handler). One-time complete → `metadata.negocio_grant = { type: 'one_time', granted_at,
  expires_at }` with `months` from session metadata (12 by default, 3 for Arranque). Lapse handlers cloned. A paid
  write that does not land alerts on Telegram for hand repair, as every existing handler does.
- **D7 · The badge.** «Hecho con Miyagi Sánchez» renders in `ChannelLayout` (subdomain) and the embed when the plan is
  `gratis`, linking to `https://miyagisanchez.com/?utm_source=badge&utm_medium=shop&utm_campaign=<slug>`. Trial and
  Negocio shops never show it. A custom domain cannot be Gratis (D5), so it never shows there.
- **D8 · AI allowances in one module.** `lib/plan-allowances.ts`: shop chat answers per month — Gratis 50, trial and
  Negocio 1,000; prompt-to-shop owner versions per month — 10 / 30; photos per month — 20 / 60. The existing daily
  caps (`CHAT_PER_SHOP_PER_DAY` 200, global 3,000) stay as fail-closed bounds. The monthly chat count is a new
  `ai_allowance` kind `chat_month` (M1). **Over the allowance, the chat answers with `answered: false`** and a fixed
  line, so the existing «Déjale tu pregunta a la tienda» form appears; a buyer never sees an error.
- **D9 · The check-in is for Negocio and trial shops.** `checkin-server.ts` filters on `resolvePlan`.
- **D10 · Trial emails.** On the same daily VM timer: «te quedan 5 días» (day 25) and «ya estás en Gratis» (day 31),
  each sent once — claim THEN send, by a conditional write of `negocio_trial.notified_5d_at` / `notified_end_at`.
- **D11 · The subdomain is free and sold nowhere.** Remove it from the catalog's extras, the canal-propio buy UI, the
  promoter close options and rate card. Its routes and MCP tools answer "free now" instead of selling. Existing
  subdomain subscriptions are **cancelled at period end with an email (decision b)** by
  `scripts/cancel-subdomain-subscriptions.mjs` (`--dry-run` lists them, `--apply` cancels), run by the orchestrator
  after the deploy. `subdomain.paywall_enabled` stays OFF; the entitlement code stays, fail-open.
- **D12 · Promoter packages are three new SKUs.** `negocio_anual` $2,000 (55%), `negocio_arranque` $600 (50%),
  `setup_gratis` $250 (80%) in `lib/promoter-packages.ts`, each with **its own list price** (the promoter-price clamp
  in `resolveSkuPromoterPriceCents` would otherwise cut $2,000 to $1,490). Rates are rows in
  `marketplace_promoter_commission_rates`, seeded by M1 and editable in `/admin/promoter`. By transfer, owed = price −
  commission = $900 / $300 / $50. By card, the promoter pays the full price and the commission accrues for the admin
  to settle. Anual grants 12 months, Arranque 3, setup Gratis grants nothing (the shop's own trial still runs).
- **D13 · The 10% renewal.** A Negocio payment (invoice or one-time) for a shop whose first paid Negocio-package
  attribution belongs to promoter P, made 12–24 months after that first payment, records a renewal attribution (sku
  `negocio_renewal`, rate 10, seeded by M1) keyed by the Stripe payment id, so a retried webhook cannot double it. The
  rule lives in the pure `lib/promoter-commission.ts`, never in the webhook.
- **D14 · Photos in the promoter workspace.** A step in `/promotor/cerrar` reuses prompt-to-shop's photo analysis
  (`lib/prompt-to-shop/photo*.ts`) to propose product cards for the **unclaimed** shop the promoter just opened; each
  confirmed card goes through the existing promoter listing route. Its allowance subject is
  `photo_analysis:promoter:<id>` on the existing `photo` kind and daily budget.
- **D15 · Names.** The billing page is «Tu suscripción» at `/shop/manage/negocio`; «Tu plan» stays the business plan.
- **D16 · One price list.** `buildPricingCatalog` gains `plans` (Gratis and Negocio, each with what it includes);
  extras keep only the print ad and the migration. Tokens `{negocioMonthly}` and `{negocioYearly}`.
- **D17 · Agents.** MCP `get_plan` (plan, ends_at, what it includes) and `start_negocio` (`cadence: month | year` →
  a checkout URL), shop-scoped, mirroring `start_subdomain_subscription`.
- **D18 · No new flags** (Daniel, Plan gate c). **One migration, M1**: `ai_allowance.kind` + `chat_month`;
  `marketplace_promoter_transfers.sku` + `negocio_anual`, `negocio_arranque`, `setup_gratis`; commission-rate rows for
  the three packages and `negocio_renewal`. Applied by the orchestrator through MCP **before** the PR that needs it
  merges, then `schema_migrations` realigned and verified live.

### Amendments made while building (2026-11-04/05 — each found against live code or by a reviewer)
- **D4** — the trial stamp uses `merge_shop_metadata` with a guard (`guardFor()`: absent / JSON-null), not a bare
  `.is()` filter: a JSON `null` key passed the filter and a second write could re-stamp. The backfill is
  `scripts/backfill-negocio-trial.ts` (`npm run negocio:trial-backfill`), not `.mjs`.
- **D6** — Stripe API `2026-06-24.dahlia` puts a subscription's period on its **item**
  (`items.data[0].current_period_*`); the handler reads it there. A one-time session grants only when
  `payment_status === 'paid'`. Negocio checkouts carry idempotency keys.
- **D5** — the standalone custom-domain and ML-sync purchases are **retired** (their routes answer 410 «incluido en
  Negocio»); everything already paid keeps entitling. Domain teardown asks `decideDomainRelease`, which knows Negocio.
- **D8** — prompt-to-shop owner versions are enforced nowhere today (`ownerVersionsPerMonth` has no reader), so only
  chat (`chat_month`) and photos are bounded by plan. The version number stays in the module, unused.
- **D11** — the cancel script is `scripts/cancel-subdomain-subscriptions.ts` (`npm run subdomain:cancel-paid`), with a
  Resend preflight and per-subscription markers so a rerun neither cancels nor emails twice.
- **D12** — both close paths **settle at source**: by card the promoter pays only the platform's share (the commission
  never accrues), by transfer they send it. A promoter may not close a package on a shop they **own** (self-close);
  a missing commission rate answers 503, never a 0% fallback. M2 (`20261105010000`) lets package rows with a
  `payment_ref` coexist with the old one-per-SKU unique index.
- **D13** — the renewal rule lives in `lib/promoter-packages.ts` (`isRenewalPayment`, 12–24 months), timed by the
  Stripe payment, not the webhook's processing time.
- **D14** — the promoter's photo budget is `photo_analysis:promoter:<id>` on the `daily_budget` kind, 60 a day, and
  **every model attempt** (the first and its one retry) spends one unit.

## What already exists (reuse, don't rebuild)
- Entitlement seam: `lib/domain-entitlement.ts`, `lib/ml-sync-entitlement.ts` and their `*-entitlement-server.ts`
  composers (the only callers' seam: canal-propio, the domain routes, the ML pages, `lib/ml-channel-toggle.ts`, admin
  tenants, MCP).
- Medusa Commerce plans: Backend `src/api/internal/setup-ml-sync-plan/` and `ml-sync-subscription/` (clone both);
  Storefront `lib/ml-sync-subscription.ts`, `lib/ml-sync-subscription-checkout.ts`, `scripts/seed-ml-sync-plan.mjs`.
- Stripe: `lib/stripe-subscriptions.ts`; `app/api/webhooks/stripe/route.ts` (the ML-sync and subdomain handlers).
- Backfill planner pattern: `lib/paywall-grandfather.ts` + its script.
- White-label shell: `app/(shell)/s/[slug]/ChannelLayout.tsx`; embed `app/(shell)/embed/s/[slug]/page.tsx`.
- AI limits: `lib/prompt-to-shop/allowance.ts`, `lib/shop-chat/handler.ts`, `components/shop-chat/ShopChat.tsx`.
- Check-in: `lib/business-plan/checkin.ts`, `checkin-server.ts`; emails `lib/shop-notify.ts`.
- Prices: `lib/pricing-catalog.ts`, `lib/pricing-catalog-server.ts`, `/mx/precios`, `locales/*.json → acerca`.
- Promoter rails: `lib/promoter-skus.ts`, `lib/promoter-pricing.ts`, `lib/promoter-commission.ts`,
  `lib/promoter-transfer*.ts`, `/api/promoter/close/*`, `/promotor/cerrar`, `/api/promoter/rate-card`,
  `/admin/promoter`.
- MCP seller tools: `app/api/ucp/mcp/route.ts`.

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 The Negocio plan in Medusa Commerce (Backend) | high |
| 1 | S1.2 One plan seam, the prices and the trial | high |
| 1 | S1.3 Buy Negocio: monthly, or yearly in meses sin intereses | high |
| 1 | S1.4 Custom domain and ML sync open for Negocio | high |
| 2 | S2.1 «Hecho con Miyagi Sánchez» on Gratis shops | low |
| 2 | S2.2 AI allowances by plan | high |
| 2 | S2.3 The check-in for Negocio, and the trial emails | low |
| 2 | S2.4 The subdomain is free and sold nowhere | high |
| 3 | S3.1 One price list: Gratis and Negocio | low |
| 3 | S3.2 «Tu suscripción» | low |
| 3 | S3.3 Agents read the plan and start Negocio | high |
| 4 | S4.1 Three packages with their own prices and rates | high |
| 4 | S4.2 Closing a package in the workspace | high |
| 4 | S4.3 10% of the year-2 renewal | high |
| 5 | S5.1 The promoter fills the shop from photos | high |

## Model routing (stated, per WAYS-OF-WORKING → Epic-mode builds)
Orchestrator (Opus 5.5) builds the money, entitlement and migration stories: S1.1–S1.4, S2.2, S2.4, S3.3, S4.1–S4.3,
S5.1. Sonnet-class builders take the low ones with a clear acceptance check: S2.1, S2.3, S3.1, S3.2. Review per
`scripts/review-config.json`: fresh `pr-reviewer`, one cross-family pass (`review-route.mjs`, Codex on gpt-6-luna
xhigh), and the security lens on every PR here that touches Stripe, the webhook, entitlement or a migration.

## Deploy order
1. Backend S1.1 merges and deploys first (the Negocio plan routes), then `scripts/seed-negocio-plan.mjs` creates the
   monthly Stripe price and posts it to the plan. Yearly and promoter packages need no Stripe price (inline).
2. M1 is applied through MCP before the Storefront PR that first uses it (S2) merges.
3. Storefront sprints merge in order (stacked branches), each deployed by the VM `update.sh`; confirm the running
   container's commit equals the merge commit.
4. After S1 deploys: `scripts/backfill-negocio-trial.mjs --apply` (decision a). After S2 deploys:
   `scripts/cancel-subdomain-subscriptions.mjs --apply` (decision b).

## Definition of Done (epic)
- [ ] All sprints merged to `main` (Backend #224; Storefront #471 `cfa58dc`, #472 `bb7e5a3`, #473 `f001016`, #474 `7373268`, #475 `39ae94e`) + smoke-tested (gaps stated — `node scripts/owed-ledger.mjs` counts what is still owed)
- [x] Each `sprint-N.md` has its smoke walkthrough (real URLs)
- [ ] This README marked ✅; every sprint status ticked with commit refs
- [x] `RETROSPECTIVE.md` written (the Intent word is Daniel's)
- [x] Product poster (`Roadmap/README.md`) updated
- [x] Team memory + `MEMORY.md` index updated
- [x] Durable learnings promoted to `Roadmap/LEARNINGS.md` (dedupe — sharpen, don't append)
- [x] *(n/a: no flag, D18)* **Kill-switch (only if one was planned at refining — Stage 6b):** the flag slice shipped, the flag
      exists **in Golden Frijoles, in every env**, with the stated polarity, **and its switch is set there** —
      `frijoles flags get <key>` must print `on vN` or `off vN` in its PRODUCTION row (a bare `off` with no version
      means nothing is served there, so the app runs on its own built-in default). A newly synced flag goes live as written in its file; a sync never switches an existing one. *Verify-only — not a new gate; whether a high-risk epic needs one
      is decided at refining, not here.*
- [x] Deployed 2026-11-05 (Storefront `39ae94e`, Backend `bf79685` confirmed running); plan seeded (`subplan_01M6MQYTQP6ZT6Z64ERV4QMK5G`); trial backfill stamped 18 owned shops (ends 2026-12-05); the subdomain cancel found 0 paid subscriptions in Stripe and Medusa Commerce, so nothing to cancel. Feature branch deleted; **this README's frontmatter `status: shipped`** (the SSOT — the board & Notion derive from it; run `node scripts/build-order.mjs`)
