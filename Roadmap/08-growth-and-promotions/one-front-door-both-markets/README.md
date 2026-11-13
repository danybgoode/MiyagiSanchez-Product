---
status: scaffolded   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Locking architecture       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: one-front-door-both-markets
title: "One front door for both markets"
area: 08-growth-and-promotions
risk: high
type: feature
sprints_total: 4
stories_total: 14   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 88   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 50    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 300
quote_basis: "L, n=1, wide"
hypothesis: "The shop builder speaks only Spanish, takes only a sentence and makes only Mexican shops. When anyone can start from a sentence, photo, file or store link, in their language, and choose Mexico or the US, the offer reaches the US. We'll know when the first US shop comes from the builder."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: "p2s_describe_submitted, by page path, input kind and market"   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A small merchant, in Mexico or the US, who wants their business online without learning ecommerce"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No North Star strategy exists in Roadmap/00-strategy/; the epic is the product owner's direct call (2026-11-12)."   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 21      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: One front door for both markets

> **Area:** 08-growth-and-promotions · **Risk:** high · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/one-front-door-both-markets.md`](../../00-ideas/seeds/one-front-door-both-markets.md)
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
Anyone, from any country, lands on miyagisanchez.com in their language, starts a shop from what they already
have — a sentence, one photo, a catalog file or their old store's link — and chooses Mexico or the United States
when the shop becomes theirs. Merchants who already have a shop get the same tools from their dashboard. Junk and
abuse are refused before the AI runs, so real merchants never find the day's allowance used up.

## Platform-first note
Commerce stays in Medusa: a draft is not commerce until it is claimed (`lib/prompt-to-shop/handler.ts` header),
the shop create is the existing `ensureShop` with its existing `market` field, and a merchant's real products from a
file or link are imported AFTER the claim through the existing `/api/sell/import` (Medusa products), never written by
new code. Drafts, allowances and the screen's log stay in Supabase (`shop_drafts`, `ai_allowance`) — non-commerce.

## What already exists (reuse, don't rebuild)
- `app/(shell)/mx/vende/_components/DescribeBox.tsx`, `app/(shell)/p2s/_components/TakingShape.tsx` — the box and the stream.
- `lib/prompt-to-shop/handler.ts` `handleCreateDraft` — validate → Turnstile → burst → spend → write → stream (order is spec-pinned).
- `lib/prompt-to-shop/allowance.ts` + Postgres `spend_ai_allowance(subject, kind, period, cap)` (generic, fails closed) and `spend_p2s_generation`.
- `lib/prompt-to-shop/photo.ts` / `photo-server.ts` — Gemini vision → one card; `callModelBody` in `server.ts` (inline image bodies).
- `lib/catalog-import.ts` `parseCatalogFile`, `validateRows` (CSV/JSON) · `xlsx` (already a dependency) · `/api/sell/import` (chunked Medusa import).
- `lib/shopify-import-bridge.ts` `pullShopifyShop(domain)` · `lib/ssrf-fetch.ts` `pinnedFetch` · `lib/ssrf-guard.ts`.
- `lib/prompt-to-shop/claim.ts` `shopInputFrom` + `lib/ensure-shop.ts` `ShopCreateInput.market` · `lib/seller-signup-market.ts` (three-state market read).
- `app/(site)/RootLanguageSwitch.tsx` (the one-time hop, localStorage choice), `MarketRecommendation.tsx` (recommend, never choose), `RootMarketLinks.tsx`.
- `lib/seller-acquisition.ts` `SELLER_LANDING_PATHS` + source guard; `SellerAcquisitionSections.tsx` `LandingHero`; `page-config.ts` builders.
- `lib/prompt-to-shop/funnel.ts` `trackFunnel`.

## Locked decisions (architecture lock, 2026-11-12 — verified against storefront `origin/main` b8729e5 and the live Supabase DB)

**Live data read for this lock:** `shop_drafts` = 3 rows, all claimed, 2 unexpired. `ai_allowance` kinds in use:
`version` (subject = device, period `all`) and `daily_budget` (subject `global`, period = Mexico City day).
`spend_ai_allowance` is generic. A schema change on `shop_drafts` is free now.

- **D1 — The screen is a pure seam.** `lib/prompt-to-shop/screen.ts`: `screenDescription(text, deps) →
  {verdict:'allow'} | {verdict:'refuse', kind:'gibberish'|'off_task'|'attack'|'prohibited'} | {verdict:'unavailable'}`.
  One Jev request, two questions (`intent` Choice: business · off_task · attack · gibberish; `prohibited` Noul) — the
  exact question text measured on 2026-11-12. I/O (`fetch` to `https://api.typesafe.ai/v1/systemone`, `TYPESAFE_API_KEY`,
  2 s timeout) in `screen-server.ts`.
- **D2 — Where it runs.** In `handleCreateDraft` AFTER Turnstile + burst and BEFORE `spend` (a refusal costs no budget;
  Turnstile first so the screen is not a free oracle). On a re-run only when a NEW description arrives. Also before
  `analyzePhoto`'s confirm writes (prohibited only, on the card's title+description), and in every intake (D6–D8).
- **D3 — Thresholds.** Refuse when `intent ≠ business` with confidence ≥ 0.80, or `prohibited` ≥ 0.80. Anything else
  allows. Pinned by a spec over a labelled set (`screen.fixtures.ts`, ≥ 40 cases, es + en) whose expected verdicts
  are the policy — the live model is not called in CI; the fixtures carry recorded Jev answers.
- **D4 — Unavailable is not allow-silently.** No key, timeout, non-200 or a malformed answer → `unavailable`: the
  request proceeds under today's guards (Turnstile, burst, versions, daily budget) and logs `screen_unavailable`
  with the reason. Never collapsed into "allowed by the screen" in logs or funnel.
- **D5 — Refusal copy** lives with the other refusals in `P2S_COPY` (`handler.ts`), localized (D11): gibberish/off_task
  → «Esto no parece un negocio. Cuéntanos qué vendes o qué ofreces y armamos tu tienda.»; attack → same text (never
  tell an attacker which check fired); prohibited → «No podemos armar tiendas para productos que los pagos en línea no
  aceptan (por ejemplo medicamentos controlados, armas o réplicas).» Status 422.
- **D6 — Signed-out photo.** New `POST /api/p2s/intake/photo` (multipart: one image ≤ 8 MB, jpeg/png/webp/heic;
  `turnstile_token`). Order: validate → Turnstile → burst → spend `spend_ai_allowance('device:<id>','anon_photo','all',1)`
  → spend `spend_ai_allowance('global','anon_photo_budget',<MX day>, P2S_ANON_PHOTO_DAILY_BUDGET||100)` → R2 put under
  `p2s/<device>/<uuid>.<ext>` → Gemini vision (`photo.ts` prompt, localized) returns `{description, card}` → the card's
  title+description through the screen's prohibited check → `{description, seed_product}`. The image is sent inline to
  Gemini (no re-fetch). The signed-in `/api/sell/upload` is NOT touched. No refund of the photo allowance on a model
  failure (one photo, one try; the copy says so) — refunding needs a new RPC and is not worth one.
- **D7 — File intake.** New `POST /api/p2s/intake/file` (multipart, ≤ 5 MB): CSV/TSV/JSON → `parseCatalogFile`; XLSX →
  `xlsx` first sheet → CSV → `parseCatalogFile`; PDF → Gemini with the PDF inline + `buildExtractionPrompt()` (spends a
  version + the daily budget FIRST, like a generation). Rows → `validateRows`, capped at `EXAMPLE_ROWS_MAX`×2 for the
  canvas; the text the screen sees is the first rows' titles+descriptions. Returns `{description, rows}` where
  `description` is built in code («<n> productos: <first titles>…»).
- **D8 — Link intake.** New `POST /api/p2s/intake/link`: `isPublicDomainShape` → Shopify (`*.myshopify.com` or a
  storefront that answers the Storefront MCP) via `pullShopifyShop` → rows + shop name; Big Cartel (`*.bigcartel.com`)
  → `pinnedFetch('/products.json')` → rows; anything else → `pinnedFetch` the page (≤ 1 MB, 5 s) → `<title>` + meta
  description → `description`. Every result through the screen. Mercado Libre needs OAuth — a pasted ML link is the
  "anything else" path.
- **D9 — Real products ride the draft, import after the claim.** `shop_drafts.seed_rows jsonb` holds rows from D6–D8
  (validated `StagedRow` shape, ≤ 60). The canvas shows them as «Tus productos», never «EJEMPLO». At «Quedármela» they
  are NOT poured by the claim (the claim's manifest is unchanged); the kept-shop screen offers «Subir mis N productos»,
  which posts them to the existing `/api/sell/import` as the now-signed-in merchant.
- **D10 — Migration** (orchestrator applies via MCP, then realigns `schema_migrations`):
  `alter table shop_drafts add column locale text not null default 'es' check (locale in ('es','en')),
  add column market text check (market in ('mx','us')), add column seed_rows jsonb;` Existing 3 rows keep `es`/null.
- **D11 — Locale.** The box sends `locale` (`es|en`, from the page, never `Accept-Language`); stored on the draft;
  every builder screen reads the draft's locale. Copy: `lib/prompt-to-shop/copy.ts` stays the es source;
  `copy-en.ts` exports the same shapes (`satisfies typeof <ES>` so a missing key fails `tsc`); `p2sCopy(locale)` picks.
  Server refusals pick by the body's locale. Generated text already follows the merchant's own language
  (`SETUP_LANGUAGE_DIRECTIVE`). Nudge emails follow the draft's locale.
- **D12 — Market on the draft is a HINT; the claim's market is the CHOICE.** The box sends `market_hint`
  (`mx|us|null`: the page's market for `/mx/vende/*`, `/us/*`; for `/` and `/en`, the browser hint per
  `MarketRecommendation`'s rule — timezone `America/*` US zones or region `US` → us, region `MX` → mx, else null).
  Stored as `shop_drafts.market`; drives the catalog prompt's currency (pesos / US dollars) and price display.
- **D13 — The claim requires an explicit market.** `POST /api/p2s/claim/[id]` body `{market}` read through
  `resolveSellerSignupMarket`; `undefined` → refuse `market_required` (400) BEFORE `findSeller` — never default to
  `mx`. `shopInputFrom(identity, market)` passes it; the draft row's `market` is updated to the choice. Three states:
  chosen → create; absent/invalid → ask; backend 409/422 (existing named refusals) → shown, not retried.
- **D14 — The question.** In `KeepSheet` before sign-up AND on the signed-in direct claim: two options, preselected
  from the draft's `market`, none preselected when null; the button is disabled until one is picked. Copy per the
  pitch's `claim-market-focus` surface. The choice survives the Clerk round trip in `sessionStorage` keyed by draft id.
- **D15 — US kept shop.** `CobrosChooser` for `market=us` shows one rail: «Conecta Stripe» → the existing
  `/shop/manage/settings/pagos` Connect flow, plus arranged delivery; no SPEI / Mercado Pago / cash (checkout refuses
  them for `us`: `lib/checkout-market-strategy.ts`).
- **D16 — Language at the root.** `/en` renders the English builder (`SellerAcquisitionPage` with an `en` anchor config
  + `DescribeBox locale="en"`), `MarketSelector` moves to the end strip (`RootMarketLinks` gains Español). `/` and `/en`
  declare each other as `hreflang` alternates (`es-MX`, `en`, `x-default` = `/`) — this REVERSES
  root-shop-builder-home D3. The hop: `/` → `/en` once, only when `navigator.languages[0]` starts with `en` AND no entry
  starts with `es` AND no entry ends `-MX` (keeps root-shop-builder-home D5: an `en-MX` phone stays). `/en` → `/` when
  the first language starts with `es`. A stored choice (`RootLanguageSwitch`'s key) always wins. Client island only;
  no server header read (poster: Country markets).
- **D17 — `/us/vende`.** A new route in `(us-site)` rendering the US landing in Spanish (`es` copy for the `us` page
  config, same US money truth: USD, Stripe, no SPEI), `DescribeBox locale="es" market_hint="us"`. `/us/sell` ↔
  `/us/vende` link to each other and declare hreflang. `SELLER_LANDING_PATHS` keeps `us: '/us/sell'`; `/us/vende` is
  added to the guard's population.
- **D18 — Hero.** `LandingHero` drops `TrustLine` and the hero `PromptBlock`; `trustLine`/`trustPrompt` leave the hero
  config. The STEPS section's agent prompt (agent-native setup) stays — it is not the hero. Every landing passes
  `describe` (persona examples from a per-page `examples` list in the page config). The copy guard asserts absence.
- **D19 — Funnel.** `p2s_describe_submitted` props gain `input` (`text|photo|file|url`) and `market` (the hint);
  `p2s_claimed` gains `market` (the choice).
- **D20 — Dashboard card.** `/shop/manage` home gets «Crear con IA»: photo → product (the existing signed-in
  `PhotoSheet` path and monthly allowance), file and link (D7/D8 handlers reused signed-in, rows → the existing
  import staging at `/shop/manage/import`). Every path through the screen.

**Deviations from the pitch:** S1.5 Mercado Libre is the generic-page path (needs OAuth); photo refunds are not
offered (D6); the hero-only removal keeps the steps section's agent prompt (D18).

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 Junk never reaches the AI · S1.2 Prohibited goods refused · S1.3 One photo, signed out · S1.4 Catalog file · S1.5 Store link | high |
| 2 | S2.1 Builder in English, in dollars · S2.2 Market at «Quedármela» · S2.3 Site in my language · S2.4 `/us/vende` | high |
| 3 | S3.1 Builder on every landing · S3.2 Hero is just the input · S3.3 «Lo que tu tienda hace» · S3.4 Funnel props | low |
| 4 | S4.1 «Crear con IA» on the dashboard | high |

**Model routing:** orchestrator (Opus 5.5) builds S1, S2.2, S2.3, S4; Sonnet-class builders may take S2.1's mechanical
copy split and S3. Review: CI gate; fresh `pr-reviewer` on S1, S2 and S4 PRs (signed-out uploads, the market at claim);
cross-family pass per `scripts/review-route.mjs` (codex on gpt-6-luna @ xhigh).

## Deploy order
Migration D10 applied and verified live BEFORE the S1 PR merges (D9 writes `seed_rows`). `TYPESAFE_API_KEY` added to
the VM storefront env BEFORE S1 deploys (without it D4 degrades to today's guards — safe, but the epic is not done).
Storefront only; no backend change. Each sprint PR: merge → image build green → `update.sh` → verify the container
serves the merge SHA → prod smoke.

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
