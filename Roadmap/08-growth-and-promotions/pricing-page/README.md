---
status: in-progress  # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Building       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
locked_at: "2026-10-28T21:45:44Z"
slug: pricing-page
title: "Pricing page"
area: 08-growth-and-promotions
risk: low
type: feature
sprints_total: 2
stories_total: 6   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 90   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 20    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 120
quote_basis: "M, n=1, wide"
hypothesis: "We believe that one honest pricing page, with T1 in the comparador, will help merchants comparing platforms choose us, because today our prices are scattered and agents call them TBD. We'll know when every surface reads one price source and pricing-page clicks into the comparador and signup are measured."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: null   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A Mexican merchant comparing T1, Tiendanube, Shopify and Mercado Libre who wants to know what selling on Miyagi will actually cost"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist); funded as E2 of the T1 value-proposition review, beside prompt-to-shop"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 9       # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: Pricing page

> **Area:** 08-growth-and-promotions · **Risk:** low · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/pricing-page.md`](../../00-ideas/seeds/pricing-page.md)
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
A Mexican merchant comparing T1, Tiendanube, Shopify and Mercado Libre gets one honest page at
`miyagisanchez.com/mx/precios`: selling is free with 0% platform commission; what stays free forever; the optional
extras with their real prices; what the payment processor (not us) charges, with the money going straight to the
merchant's account; and one tap into the comparador, which now includes T1. Today our prices are scattered across
`/acerca` and in-portal upsells, typed by hand, partly missing, and agents are told they're "priced TBD".

## Platform-first note
No commerce data moves and no table is added. Every price already has a home: `lib/subdomain-pricing.ts`,
`lib/domain-pricing.ts` and `lib/ml-sync-pricing.ts` (fixed SKUs, also used by the Stripe plan seed), plus
`getPromoterSkuPrices()` for the admin-set print ad and migration. Processor fees are in the comparador dataset. This
epic adds one pure **pricing catalog** that assembles those sources, and points every surface at it.

## What already exists (reuse, don't rebuild)
- `lib/subdomain-pricing.ts` ($199/yr, $25/mo), `lib/domain-pricing.ts` ($499/yr, ~$42/mo), `lib/ml-sync-pricing.ts` ($299/yr, $30/mo): catalog rows
- `getPromoterSkuPrices()` (print ad per tier, migration), as `/mx/vende/migracion` already reads it: live rows, «Precio a cotizar» when unset
- `lib/promoter-skus.ts` (`PROMOTER_SKUS`): the catalog's completeness check
- `lib/cost-comparator-dataset.{json,ts}`, `lib/cost-comparator.ts`, `lib/cost-comparator-url.ts`, `app/api/comparador/analyze`: T1 as a fifth platform; processor fees
- `app/(shell)/comparador/_components/ComparadorTool.tsx`: the T1 picker (follow the Tiendanube addition's shape)
- `lib/about-content.ts` (`pricing` section, es + en) and `lib/about-agent.ts`: re-pointed at the catalog
- `/mx/vende/*` page shell (metadata, `opengraph-image.tsx`, JSON-LD): the `/mx/precios` structure
- `lib/market-sitemap.ts` (`PLATFORM_SITEMAP_ENTRIES`), `app/components/PlatformShell.tsx` (footer): discoverability
- `lib/analytics-events.ts`: funnel clicks
- `e2e/comparador*.spec.ts`, `e2e/seller-acquisition-seo.spec.ts`, `e2e/about-acerca.browser.spec.ts`: extended, not rewritten

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 `lib/pricing-catalog.ts` + the price source-sweep spec | low |
| 1 | S1.2 `/mx/precios` page, OG image, JSON-LD offers, sitemap | low |
| 1 | S1.3 `/acerca`, `about-agent` and `llms.txt` read the catalog | low |
| 1 | S1.4 Footer, `/mx/vende` and comparador links + funnel clicks | low |
| 2 | S2.1 T1 figures in the dataset + `computeT1Cost` + URL codec + analyze route | low |
| 2 | S2.2 T1 picker in the comparador + the prefilled link from `/mx/precios` | low |

**Moved out at plan time (Daniel, 2026-10-27):** the new `/mx/vende` hero line → prompt-to-shop S2.2; the «Con IA»
allowances row on `/mx/precios` → prompt-to-shop S4.2 (it reads this epic's catalog).

**Flag:** none (WAYS-OF-WORKING default); rollback is `git revert`.

## Architecture lock (2026-10-28 — verified against storefront `ec8a2fb` and the live DB)

Builders **cite** these; nothing here is restated elsewhere. Model routing: one orchestrator (Opus 5.5)
builds both sprints in place in the worktree `~/dobby/.worktrees/pp-web`; S1 defines the catalog contract,
S2 is mechanical. Review: `review-route.mjs` per PR (`reviewScope: security-paths-only` — none of these paths
is a security path, so the deterministic gate is the gate unless the router says otherwise).

### Premises the live system corrected (said out loud)
- **P1 — `getPromoterSkuPrices()` is not a public price list.** It reads `marketplace_promoter_sku_prices`,
  the *promoter-discounted* override table (`lib/promoter-pricing.ts` clamps it to ≤ list price). Live rows:
  **one** — `migration = 999`. `print_ad` has none. The print ad's public price lives per tier in
  `print_editions.tiers[].price_cents`; live: 2 editions, **both `draft`**, none `open`. → D2.
- **P2 — `/acerca`, `/agent` and `llms.txt` do NOT render `lib/about-content.ts`.** Every live path goes
  through `getOverriddenAboutSections()` → `locales/{es,en}.json → acerca.sections.pricing` (+ admin
  `platform_copy_overrides`, **0 pricing rows live**). The two copies have already drifted
  (`locales` says `miyagisanchez.com/s/tu-tienda`, `about-content.ts` says `/mx/s/tu-tienda`). → D7.
- **P3 — the type is `CompetitorPlatform`** (`lib/cost-comparator-url.ts`), not `ComparatorPlatform`.
- **P4 — `app/api/comparador/analyze` is the shop-URL analyzer**, so "T1 joins the analyze route" means T1
  detection in `lib/shop-url-analyzer.ts#detectPlatformFromSignals`. → D14.
- **P5 — T1's "+2% on external methods for paid tiers" is not on T1's page** (`https://t1.com/mx/tienda/precios`,
  served HTML read 2026-10-28) nor in October 2026 press. **Descoped from the model** unless S2 finds it on
  t1.com on build day (then it is added with its source). The Gratis tier's 30-order cap is also not in T1's
  served HTML (client-rendered table); it is in press (emprendedor.com, ovaciones.com, Oct 2026). → D11.
- **P6 — no migration.** No table, no column; the kickoff's migration line does not apply.
- **P7 — hand-typed prices exist beyond `/acerca`:** `sellerAcquisition.promotor.glossary[0..1].body`
  (`$499 MXN al año, pago único` — also wrong: it renews yearly — and `$199 MXN al año`) in both locales. → D8.

### Decisions
- **D1 — One pure catalog.** `lib/pricing-catalog.ts`, next-free and DB-free, exports
  `buildPricingCatalog(input)` where `input = { migrationPriceMxn: number | null; printAdTiersCents: number[] | null }`
  and returns `{ free, extras, processors }`. Fixed prices are **imported** from `lib/subdomain-pricing.ts`,
  `lib/domain-pricing.ts`, `lib/ml-sync-pricing.ts` — never restated. Display strings (es + en) are
  **formatted by the catalog from those numbers** (yearly-equivalent `~$n/mes` = `Math.round(yearly/12)`:
  17 · 42 · 25). The existing `*_LABEL` constants stay for their current consumers.
- **D2 — Admin-set rows.** The I/O shell `lib/pricing-catalog-server.ts` reads (a) `getPromoterSkuPrices().migration`
  as the migration price — the same value `/mx/vende/migracion` already shows publicly — and (b) the tier
  prices of every `print_editions` row with `status = 'open'` (same query shape as `app/api/print/editions`).
  Print ad = «desde $min» across open tiers; no open edition ⇒ `null`. Any `null` renders **«Precio a cotizar»
  + «Escríbenos»**, never `$0`. Today that is the print ad (P1).
- **D3 — Completeness.** Every `PROMOTER_SKUS` entry has exactly one `extras` row (`custom_domain`,
  `print_ad`, `subdomain`, `ml_sync`, `migration`); the spec iterates `PROMOTER_SKUS`, not a hand list.
- **D4 — Custom domain is yearly-only.** Shown as `$499/año (~$42/mes)`; no monthly purchase is implied.
- **D5 — Processors from the comparador dataset.** Stripe = existing `miyagi.payment.{pct,fixedMxn}`
  (3.6% + $3, stripe.com/mx/pricing, 2026-07-17). **New** figures `processor.mercadopago.pct = 3.49`,
  `processor.mercadopago.fixedMxn = 4` (source `https://www.mercadopago.com.mx/recibe-al-instante`,
  verifiedAt `2026-10-28`, «+ IVA, dinero al instante»). SPEI is a **direct transfer to the merchant's own
  CLABE**: the row says Miyagi charges nothing and the merchant's bank may — **no invented rate**. Every
  processor row says «+ IVA» where the source does, and that the money lands in the merchant's own account.
- **D6 — Page.** `app/(shell)/mx/precios/page.tsx`, server-rendered es-MX, `export const revalidate = 3600`.
  Copy in `locales/es.json → precios` (read via `getOverriddenDictionary('es')`, like `/mx/vende/migracion`);
  prices enter copy only as `{tokens}` filled from the catalog. Own `opengraph-image.tsx` via
  `createSellerAcquisitionOgImage`. Shared `Card`/`Button`/`badge`, Iconoir, no emoji, no arbitrary
  Tailwind values built by interpolation.
- **D7 — About surfaces read the catalog through one token filler.** Pure `fillPricingTokens(text, catalog, locale)`
  in `lib/pricing-catalog.ts`. `acerca.sections.pricing` (es + en, locales **and** `about-content.ts`
  defaults) becomes token templates that name every extra (incl. ML sync, print ad, migration) and link
  `/mx/precios`; `getOverriddenAboutSections()` builds the catalog via the server shell and fills tokens
  (so an admin override with tokens is filled too). The `/s/` → `/mx/s/` drift is fixed in the locales.
  `lib/about-agent.ts:161` drops «priced TBD» for a catalog-built summary; `llms.txt` gains the summary +
  `/mx/precios` (it already renders through `aboutLlmsTxt`).
- **D8 — Source-sweep spec** `e2e/pricing-source-sweep.spec.ts`. **Enforced paths** (the LEARNINGS rule —
  gate exactly what was swept): `locales/es.json`, `locales/en.json`, `lib/about-content.ts`,
  `app/(shell)/mx/vende/_components/page-config.ts`, `app/(shell)/mx/precios/**`. Fails on an MXN price
  literal (`$n MXN`, `$n/año|/mes|/year|/mo`, `$n al año|al mes`) in any string. **Allowed negations**, each
  pinned by a passing case: `{token}` interpolations; strings containing `USD`; JSON paths under an
  explicit `ALLOWED_PATH_PREFIXES` list, each with its reason (`sellerAcquisition.anchor.benchmark.` —
  competitor figures and the worked `$1,000 MXN` example; `partnersRecruiting.landing.benchmark.`). The
  promotor glossary (P7) becomes tokens filled in `page-config.ts`. Observed red under a mutation.
- **D9 — JSON-LD** `Offer`s only for fixed SKUs (subdomain yearly + monthly, domain yearly, ML sync yearly +
  monthly), `priceCurrency: MXN`. Admin-set rows never get an Offer. Sitemap: `/mx/precios`, weekly, 0.8.
- **D10 — Links + events.** Footer «Precios» in `PlatformShell` **only on the MX market** (the page is
  es-MX; `/us` is out of scope). `/mx/vende`: a pricing link in the sections config, never the hero
  (prompt-to-shop owns it). Comparador: «Ver precios» back-link. Events through `pushAnalyticsEvent`:
  `precios_viewed` (dedupeKey), `precios_comparador_clicked`, `precios_signup_clicked`.
- **D11 — T1 figures** (`t1.*` keys in the dataset, each with source + verifiedAt): plans Gratis 0 /
  Básico 399 / Avanzado 1,499 MXN a month (`https://t1.com/mx/tienda/precios`, JSON-LD offers, 2026-10-28);
  cards 3.5% + $1 MXN (standard, no chargeback cover) and SPEI $3 MXN per transfer (same page's payments
  FAQ, 2026-10-28); Gratis cap 30 online orders a month (press source until t1.com shows it). Public rates
  only — never negotiated freight or fleet.
- **D12 — `computeT1Cost(inputs, tier, rates, appsMonthlyMxn)`** in `lib/cost-comparator.ts`, lines:
  `plan`, `card` (card % + fixed on every order — the same assumption every other platform line makes),
  `spei` (`$0` by default, labelled with its per-transfer rate, editable through the existing line-override
  mechanism), `apps`. The Gratis cap is a note, not a cost; above 30 orders a month the note says the
  volume exceeds the free tier.
- **D13 — Codec.** `'t1'` joins `CompetitorPlatform` / `COMPARADOR_PLATFORMS`; `COMPARADOR_T1_TIERS =
  ['gratis','basico','avanzado']`; the shared `tier` param is platform-gated exactly like Tiendanube's.
- **D14 — Analyzer.** `'t1'` joins `DetectedPlatform` only with markers taken from a real T1 store's HTML;
  if none can be verified on build day, detection is descoped and stated (manual picker is the fallback).
- **D15 — `/mx/precios` compare link** → `/comparador?platform=t1&tier=basico` (S2; S1 links `/comparador`).
- **D16 — Stack.** Storefront `feat/pricing-page` (S1) → `feat/pricing-page-s2` (S2), one PR each, merged
  in order; root docs on root `feat/pricing-page`.
- **D17 — Deploy + verify.** Storefront only: merge → image build → `update.sh` on the VM → verify the
  container revision == merge SHA, then the sprint's anonymous render check on `main`.

### Amendment at S2 build day (2026-10-28 — T1's live page, rendered: `https://t1.com/mx/precios`, «Mostrar tabla comparativa»)
- **A1 — supersedes D11/P5.** Plans: Gratis $0 · Básico $399 · Avanzado $1,499 MXN a month (annual: $332.5 / $1,249.167 a month).
  **Gratis has no online store and cannot transact** («No se puede transaccionar») — the 30-order cap in the press is
  stale. Payments: T1pagos 3.5% + $1 per transaction (Básico, Avanzado) **or** an external provider (PayPal, Mercado
  Pago) with T1's own cut of **2% (Básico) / 1% (Avanzado)** — an alternative, not an add-on.
- **A2 — supersedes D12/D13 lines.** `computeT1Cost(inputs, tier, useT1Pagos, rates, apps)` mirrors Tiendanube:
  `plan`, `payment` (T1pagos % + fixed, or the external cut), `apps`. `COMPARADOR_T1_TIERS = ['basico','avanzado']`;
  the shared `gateway=external` param is reused, platform-gated. Gratis is a note in the T1 picker, not a chip —
  a $0 "plan" that cannot sell would flatter T1. SPEI is not on T1's pricing page, so it is not modelled.
- Deviation from sprint-2.md's smoke steps 3 (Gratis chip) — rewritten to the external-gateway toggle.
- **D14 outcome — analyzer detection descoped.** No real T1 storefront URL or HTML marker could be verified on
  build day; guessing a host pattern would misdetect. The manual T1 picker is the path; `DetectedPlatform` is unchanged.
- **D6 amended (S1 review).** No `revalidate`: every `app/(shell)` route renders per request (the shell reads
  headers and the Clerk session), and `e2e/revalidate-truth.spec.ts` rejects a `revalidate` the route cannot honour.
  The page is served `no-store`, so the year-long CDN pin D6 guarded against cannot happen. The fresh reviewer caught
  this; the lock had assumed a static page.
- **S1 review — `/mx/precios` is a non-buyer subtree.** Like `/mx/vende`, it is named in
  `scripts/derive-buyer-locale-population.ts` `NON_BUYER_SUBTREES`, with its reason (es-MX seller page, MX prices).
- **Follow-up (out of D8's enforced paths, pre-existing):** hand-typed SKU prices remain in
  `app/api/ucp/manifest/route.ts`, `app/api/ucp/mcp/route.ts` (tool descriptions/labels) and `lib/{subdomain,ml-sync}-billing.ts`.
  Move them to the catalog and add those paths to the sweep's enforced list.
- **S1 build found two more hand-typed prices** than P7 named — the promotor sales `scripts` (es + en, one also
  saying «pago único» for a yearly renewal). Tokenized; the source sweep is what found them.

### Build contract — Sprint 1 (locked by the architect before the builder started)
Files: `lib/pricing-catalog.ts` (D1, D3, D4, D5, D7 filler) · `lib/pricing-catalog-server.ts` (D2) ·
`lib/cost-comparator-dataset.json` (+2 MP figures, D5) · `app/(shell)/mx/precios/{page.tsx,opengraph-image.tsx}`
+ client click component (D6, D9, D10) · `locales/{es,en}.json` (`precios`, `acerca.sections.pricing`,
promotor glossary, footer label) · `lib/about-content.ts`, `lib/about-content-overrides.ts`, `lib/about-agent.ts`
(D7) · `app/(shell)/mx/vende/_components/page-config.ts` (D8 glossary tokens, D10 link) · `lib/market-sitemap.ts`
· `app/components/PlatformShell.tsx` · comparador back-link. Specs: `e2e/pricing-catalog.spec.ts`,
`e2e/pricing-source-sweep.spec.ts` (each observed red under a mutation), `e2e/pricing-page-seo.spec.ts`
(raw HTML: four sections, real prices, «Precio a cotizar», OG, JSON-LD, sitemap); existing about/agent/
seller-acquisition specs updated, not weakened.

### Build contract — Sprint 2 (locked by the architect before the builder started)
Files: `lib/cost-comparator-dataset.json` (`t1.*`, D11) · `lib/cost-comparator-dataset.ts` (rates adapter) ·
`lib/cost-comparator.ts` (D12) · `lib/cost-comparator-url.ts` (D13) · `lib/shop-url-analyzer.ts` (D14) ·
`app/(shell)/comparador/{page.tsx,_components/ComparadorTool.tsx}` (Tiendanube's shape) · `/mx/precios`
compare link (D15). Specs: `computeT1Cost` pure (observed red once); `comparador.spec.ts` /
`comparador-prefill.spec.ts` gain a T1 prefill (initial-HTML totals, codec round-trip).

## Deploy order
Storefront only, no backend or migration. Each sprint merges to `main`, the arm64 image builds, then
`ssh -i ~/.ssh/panfleto_oci ubuntu@159.54.158.4 /opt/miyagi/infra/oci/update.sh`. Verify on `main` after deploy.
Builds in parallel with prompt-to-shop: the only shared surface is `/mx/vende`, where E1 changes the hero and this
epic only adds a pricing link in a different component.

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
