---
status: in-progress   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Building      # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: plan-tienda-three-free-months
title: "Plan Tienda, three free months, and the promoter packages that follow"
area: 08-growth-and-promotions
risk: high
type: feature
sprints_total: 4
stories_total: 15   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 89   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 27    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 40
quote_basis: "M, n=3, p25–p75"
hypothesis: "A free-forever shop costs AI and gives promoters nothing to sell. Three free months of Plan Negocio, then Plan Tienda at $228 a year or a pause, puts every new shop on a paid plan. We'll know when shops whose three months end choose a plan instead of pausing."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: "Share of shops that are on a paid plan the day after their three free months end"   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A small merchant in Mexico whose shop was opened by a field promoter or by themselves, deciding at the end of three free months whether to pay; and the promoter at the counter selling them a package"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist); funded because Daniel decided the pricing on 2026-11-09 and the promoter field program cannot be trained or given quotas without final prices"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 16      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: Plan Tienda, three free months, and the promoter packages that follow

> **Area:** 08-growth-and-promotions · **Risk:** high · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/plan-tienda-three-free-months.md`](../../00-ideas/seeds/plan-tienda-three-free-months.md)
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
A new shop starts with three months of Plan Negocio and no card. When they end, the merchant is on Plan Tienda
($228 a year, shown as «desde $19 al mes», or $29 month to month) or on Plan Negocio, or the shop is paused with
nothing deleted until someone pays. Shops that existed before the change keep Plan Gratis for good. Promoters sell
three packages, each with the three free months on top, and earn again when the merchant renews or moves up. Prices
include IVA. Decided with Daniel on 2026-11-09.

## Platform-first note
Subscriptions live in Medusa Commerce: the monthly Plan Tienda is a second plan beside `negocio_plan`, created
through an internal route. The seller's status (active, paused) is Medusa's, changed only through
`POST /internal/sellers/:id/status`. The dated grants, the trial and the legacy marker are shop metadata read by the
one plan seam, `lib/plan.ts`. Promoter commissions are non-commerce data in Supabase.

## What already exists (reuse, don't rebuild)
- **The plan seam:** `lib/plan.ts`, `lib/plan-server.ts`, `lib/plan-by-slug-server.ts`, `lib/plan-agent.ts`, `lib/plan-allowances.ts`.
- **Prices and pages:** `lib/negocio-pricing.ts`, `lib/pricing-catalog.ts`, `app/(shell)/mx/precios/page.tsx`, `lib/negocio-page.ts`.
- **Buying:** `lib/negocio-checkout.ts`, `lib/negocio-checkout-rules.ts`, `lib/stripe-subscriptions.ts`, `lib/negocio-subscription.ts`, `POST /api/sell/negocio/manage`.
- **Backend:** `src/api/internal/setup-negocio-plan/route.ts`, `src/api/internal/negocio-subscription/route.ts`, `src/lib/negocio-plan.ts`, `src/api/internal/sellers/[id]/status/route.ts` and its ledger.
- **Pause on the storefront:** `lib/admin/tenant-status.ts`, `lib/admin/tenant-actions.ts`, `lib/seller-status.ts`.
- **Notices:** `lib/negocio-trial-notices.ts` and its server shell, `sendNegocioTrialNotice`, `lib/notifications/catalog.ts`.
- **Promoter:** `lib/promoter-packages.ts`, `lib/promoter-skus.ts`, `lib/promoter-commission.ts`, `lib/promoter-renewal-server.ts`, `lib/promoter-transfer.ts`, `app/api/promoter/close/package/[sku]/route.ts`, `lib/promoter-receipt-read.ts`, the two 2026-11-05 migrations as the pattern.
- **Scripts:** `scripts/backfill-negocio-trial.ts` as the pattern for the legacy marker; the recipe for running a bundled script inside the production web container.

## Rabbit holes (from the pitch — read before building)
- **Legacy first, pause second.** The marker is written and verified on every existing shop before the pause job is deployed.
- **Three states for a shop with no paid plan:** legacy, unpaid, could-not-read. Never two.
- **A payment restores only a `plan_unpaid` pause.** An admin pause stays.
- **Validate, then claim, then apply** on the pause and the restore; each write conditional and read back.
- **Unclaimed shops are never paused by the plan job.**
- **Packages do not use the trial.** They write dated grants from the payment day. `canStartTrial` stays as it is.
- **$600 of $1,100 is not a round percentage.** Check the rate column's precision first; if it cannot give exactly $600, stop and ask.
- **Retired packages stay in the vocabulary;** only their sale is refused.
- **Prices in copy are tokens;** IVA is included and the pages say so.
- **`medusa exec` cannot reach production;** the new plan is created through an internal route.

## No-gos
No change to Plan Negocio. No limited free plan for new shops. No extension of the 18 trials ending 2026-12-05. No
third plan. No home page, navigation or `/acerca` repositioning (its own idea). No deletion of a paused shop. No
United States plans. No feature flag.

## Architecture lock (2026-11-09, against storefront `952f2d9`, backend `16a1a1e` and live data)

**Live data read on 2026-11-09 (Supabase, production):** 61 shops, 18 owned. All 18 owned shops carry a trial and
every trial ends `2026-12-05T02:18:22Z`. 0 shops hold a `negocio_grant`. 0 owned shops lack a trial.
`marketplace_promoter_commission_rates.rate_pct` is an **integer**; rows today: `negocio_anual=55`,
`negocio_arranque=50`, `setup_gratis=80`, `negocio_renewal=10`, `migration=50`, `custom_domain=0`, `print_ad=0`.
1 transfer exists (`negocio_anual`, pending). Attributions: 7, all `custom_domain`. 4 promoters. Re-read every one of
these at apply time.

| # | Decision |
|---|---|
| D1 | **Plan vocabulary.** `PlanName` becomes `gratis · trial · tienda · negocio · unpaid`. `gratis` now means legacy Plan Gratis only. `unpaid` is a shop with no live grant, subscription or trial and no legacy marker. New reasons: `tienda_one_time`, `tienda_subscription`, `legacy`, `unpaid`. `unavailable` keeps its meaning and is never turned into `unpaid`. The one home is `lib/plan.ts`. |
| D2 | **Legacy marker.** `marketplace_shops.metadata.plan_legacy = { marked_at }`, written on every shop whose `created_at` is before the `--cutoff` instant passed to the script (**amended 2026-11-10:** a required argument, never a code constant, and never in the future; the marker runs the moment sprint 2 deploys, because the live pricing page promises «gratis para siempre» until then, and in any case **before 2026-12-05**, when the 18 trials end). All 61 rows today, owned or not: an imported shop claimed later was promised the same page. Script `scripts/mark-plan-legacy.ts`, modelled on `scripts/backfill-negocio-trial.ts`: pure planner, guard `absent`, `.select()` back, `--dry-run` read-only and printing the count. The cutoff stops a rerun from marking a new shop. |
| D3 | **Tienda's records.** `metadata.tienda_grant`, the same shape as `NegocioGrant` with `type: one_time` only. The monthly plan is a Medusa Commerce plan of kind `tienda_plan`. The grant builders in `lib/plan.ts` are made plan-neutral and reused; nothing is copied. |
| D4 | **Precedence.** Negocio (comp, dated grant, subscription) › trial › Tienda (dated grant, subscription) › legacy `gratis` › `unpaid`. **Tienda time under Negocio:** when a dated Negocio grant is written for a shop with a live Tienda grant, the Tienda grant's end moves forward by the Negocio months granted, in the same conditional write. **Deviation from the pitch:** under a MONTHLY Negocio subscription the Tienda clock keeps running; the months are not known in advance. |
| D5 | **Prices.** `lib/tienda-pricing.ts`: `TIENDA_PRICE_YEARLY_MXN = 228`, `TIENDA_PRICE_MONTHLY_MXN = 29`; «desde $19 al mes» is `yearlyAsMonthly(228)`, never typed. Prices include IVA (Daniel, 2026-11-09); the pages say «IVA incluido» for both plans. |
| D6 | **Buying.** `lib/negocio-checkout.ts` and `lib/negocio-webhook.ts` take the plan as a parameter; Tienda gets its own thin route beside Negocio's. Refusals (pure, in the checkout rules): a live Tienda subscription refuses both cadences; any paid Negocio refuses Tienda; `unavailable` refuses both; a trial, legacy, unpaid or a live Tienda year may buy the year (added after the current end and after a live trial). |
| D7 | **Trial.** `NEGOCIO_TRIAL_DAYS` 30 → 90. A stamped trial stores its own `expires_at`, so the 18 live trials are untouched; nothing else is needed for them. `canStartTrial` is unchanged. |
| D8 | **Notices.** Thresholds 15 and 5 days; a new `notified_15d_at` beside `notified_5d_at`. The end notice has two variants chosen by the legacy marker. Claims stay in `merge_shop_metadata` with the `equals` guard. |
| D9 | **Pause.** A pure `decidePlanPause` returns pause · leave · unavailable. The job pauses only an owned shop whose plan resolved (uncached) to `unpaid` with reason `unpaid`. It first claims `metadata.plan_pause = { paused_at }` (guard `absent`, read back), then calls `POST /internal/sellers/:id/status { status: 'paused', reason: 'plan_unpaid' }`. The claim is the record that this pause is the plan's. Exposed as a cron route like the trial notices; Daniel enables the timer by hand. |
| D10 | **Restore.** After a Tienda or Negocio payment or subscription activation is recorded, a shop holding `plan_pause` is set `active` (reason `plan_paid`) and the claim is cleared afterwards, relink first. No `plan_pause`, no restore. The builder verifies in live code that a paused seller's owner can still open `/shop/manage/negocio`; if not, that page and its checkout routes are opened to them and nothing else. |
| D11 | **Packages.** `PACKAGES` gains a `grants` list per package, dated from the payment day: `tienda_anual` $500 → Negocio 3 months, then Tienda 12; `negocio_semestral` $1,100 → Negocio 9; `negocio_anual` $2,000 → Negocio 15. `negocio_arranque` and `setup_gratis` move to `RETIRED_PACKAGE_SKUS`: the sale answers 410, every read still works. The one pending `negocio_anual` transfer grants 15 months if approved after the deploy. |
| D12 | **Rates.** `tienda_anual = 60`, `negocio_anual = 55` (unchanged), `tienda_renewal = 10`, `negocio_upgrade = 20`. **`negocio_semestral = 55`** (Daniel, 2026-11-10): $600 of $1,100 is 54.54% and the column is an integer, so the package is charge $1,100, pass $495, keep $605. No schema change. |
| D12b | **Migration M0 (sprint 1), added at review 2026-11-10.** `merge_shop_metadata_guards`: a new function beside `merge_shop_metadata` that lands a patch only if every listed key is still as read. Needed because a Plan Negocio payment rewrites the Plan Tienda grant in the same statement, and a single guard would let it erase a concurrent Plan Tienda payment (Codex, #484). Additive; service role only. |
| D13 | **Migration M1 (sprint 4).** Widen the transfers `sku` CHECK with the two new packages; insert the four rate rows `on conflict do nothing`; widen any other `sku` CHECK the builder finds by reading `pg_constraint` live. Applied by the orchestrator through MCP before the PR merges; `schema_migrations` realigned. |
| D14 | **Renewal and upgrade.** `tienda_renewal`: a Tienda payment in months [12, 24) after the promoter's first package payment for that shop. `negocio_upgrade`: the first Negocio payment within 12 months of a `tienda_anual` package payment for that shop. Each accrues once, keyed by `payment_ref`. |
| D15 | **AI report.** `scripts/ai-usage-report.ts` reads `ai_allowance` (kinds `chat_month`, `photo`) for a month. Cost is printed only if the builder finds it logged; otherwise «no registrado», and the gap is named in the retro. |
| D16 | **No flag.** Operating posture. The pause job is guarded by D2, D9 and its hand-enabled timer. |
| D17 | **Routing.** Sprint 1 and every money, pause and commission story: the strongest model. S1.3, S1.4, S2.3, S3.2, S4.4: a Sonnet-class builder. Every PR: the fresh verifier, then `review-route.mjs`. |
| D18 | **Where each contract lives.** Plan rules: `lib/plan.ts`. Prices: `lib/tienda-pricing.ts`, `lib/negocio-pricing.ts`. Packages and splits: `lib/promoter-packages.ts` plus the rates table. Seller status: the backend's `seller-status.ts`. Builders import these; nothing restates them. |

**Scope the live system corrected:** the pitch's "check the column's precision" is answered (D12, integer; the six-month split is $495 / $605, not $500 / $600). The
pitch's "keeps its remaining Tienda time" holds for dated Negocio grants only (D4).

**Found while building (2026-11-10), fixed after sprint 2 on Daniel's instruction:** five backend routes call
`updateSubscriptions(id, { status })`, a shape Medusa's generated method does not accept, so their status writes never
land: the custom-domain, subdomain and Mercado Libre sync subscription routes, `store/subscriptions` (replay path) and
the buyer's own cancel. Plan Negocio's lapse write had the same fault and is fixed in Backend #228.

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 The plan seam knows Plan Tienda | high |
| 1 | S1.2 Every existing shop is marked legacy | high |
| 1 | S1.3 Plan Tienda has its AI amounts | low |
| 1 | S1.4 A month of AI use and cost per shop | low |
| 2 | S2.1 Plan Tienda for a year, in one payment | high |
| 2 | S2.2 Plan Tienda month to month | high |
| 2 | S2.3 The price pages show the two paid plans | low |
| 3 | S3.1 Three free months for a new shop | high |
| 3 | S3.2 Two notices before the end | low |
| 3 | S3.3 An unpaid shop is paused | high |
| 3 | S3.4 A payment brings the shop back | high |
| 4 | S4.1 Three packages, three free months on top | high |
| 4 | S4.2 10% of Plan Tienda renewals | high |
| 4 | S4.3 A share when a Tienda shop moves up | high |
| 4 | S4.4 The promoter pages name the three packages | low |

## Deploy order
1. Migrations first, applied by the orchestrator through the Supabase MCP before the code that needs them merges
   (the transfer SKU check, the commission rates, the attribution kind if needed). Never `supabase db push`.
2. Backend before storefront in sprints 2 and 3 (the Plan Tienda plan route; any change to the status route).
3. The legacy marker script runs in production the moment sprint 2 deploys, with `--cutoff` set to that instant, and
   is verified by a live count. Hard deadline: before 2026-12-05. An unmarked shop whose trial ends resolves to
   unpaid, loses its «ya estás en Plan Gratis» notice and reads «no tiene un plan activo» (verifier, #484).
   Between the sprint 1 deploy and the marker, the only visible difference is the agent tool `get_plan` answering
   `unpaid` for unclaimed shops; no gate differs.
4. The pause timer is enabled by Daniel by hand, after a dry run he has read.
5. A merge builds the image; the deploy is `update.sh` on the VM. Prove the running container equals the merge SHA.

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
