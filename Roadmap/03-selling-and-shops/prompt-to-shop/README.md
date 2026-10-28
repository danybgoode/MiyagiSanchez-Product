---
status: shipped      # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Shipped        # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
locked_at: "2026-10-28T01:04:00Z"
slug: prompt-to-shop
title: "Prompt-to-shop"
area: 03-selling-and-shops
risk: high
type: feature
sprints_total: 5
stories_total: 19   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 91   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 50    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 300
quote_basis: "L, n=0, wide"
hypothesis: "We believe that a hosted describe-to-shop flow that shows a Mexican micro-merchant their own shop before asking for anything will turn first visits into published shops, because they see the result before doing any work. We'll know when describe → preview → keep → published is measured end to end and merchants publish without help."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: null   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A Mexican micro-merchant who sells by WhatsApp, Instagram or in person, on a phone, and has never set up an online shop"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist); funded as the answer to T1's prompt-to-shop front door"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 6       # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: Prompt-to-shop

> **Area:** 03-selling-and-shops · **Risk:** high · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/prompt-to-shop.md`](../../00-ideas/seeds/prompt-to-shop.md)
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
A Mexican micro-merchant who sells by WhatsApp, Instagram or in person types one sentence about their business
and watches their own shop take shape on their phone, before signing up for anything. They keep it with one
signup, swap the example products for their own photos, pick how they get paid and how they deliver, and
publish into a marketplace that already has buyers. Today the same merchant answers intake questions, picks a
door and, on the fast path, pastes a JSON file before seeing anything. This epic is our answer to T1's AI shop
builder, and it should beat it on the part T1 lacks: a published shop that buyers can find.

**Locked UX contract:** the seven screens of the v2 strategy review, section 3
(<https://claude.ai/artifact/7cAUeEp16jVNLigE9tkUVj>), and the rules in the seed's *UX contract*. A builder may
change implementation, never the sequence, the copy intent, or those rules.

## Platform-first note
Creating a shop, its config and its catalog from one setup file in one pass already ships (agent-native setup,
three-doors onboarding: `lib/setup-spec.ts` → `lib/setup-apply.ts`). This epic adds the hosted inference in
front of that pipeline and a visual canvas around it. The anonymous **draft** and the **allowance ledger** are
non-commerce staging, so they live in Supabase (AGENTS rule 2, like `supply_batches`). The seller, real
products and publishing stay in Medusa (rule 1), and **no example product is ever written to Medusa**. Clerk
stays the auth (rule 4), es-MX only (rule 5), and agents keep the published setup spec (rule 3, unchanged: no
new MCP generation tool).

## What already exists (reuse, don't rebuild)
- `lib/setup-spec.ts` (`MiyagiSetupFile`, `validateSetup`, `EXAMPLE_SETUP`): the generation target and validator
- `lib/catalog-import.ts` (`CatalogImportRow`, `validateRows`, `CATALOG_CATEGORY_KEYS`): example rows and photo → product rows
- `lib/settings-import.ts` (`StoreConfigManifest`: profile, accent, announcement, hero, `theme_preset`, sections): the identity and words blocks
- `lib/setup-apply.ts` (`planSetupApply`, `aggregateSetupReport`) + `POST /api/sell/shop`, `/api/sell/import`, `/api/sell/settings-import`: draft → shop on keep
- `app/api/sell/import/extract/route.ts`: the Gemini call shape (`GEMINI_API_KEY`, `GEMINI_MODEL` = `gemini-3.5-flash`, REST `generateContent`)
- `app/(shell)/_shop-chrome/*`, `_shop-sections/*` (`ShopThemeShell`), `_wall/*`, the contrast-guarded theme presets: the preview canvas
- `lib/setup-guide.ts` (`computeShopCompletion`, `getSetupSteps`): the canvas checklist and its %, shared with Resumen
- The three-doors cobros mini-wizard (Mercado Pago OAuth, untouched), SPEI, cash/arranged; arranged delivery, Correos económico, manual carrier: screen 6
- `components/SuccessCard.tsx`, `lib/share-link.ts`, `mschz.org` short links: screen 7
- `lib/ratelimit.ts` (`checkRateLimit`, `getClientIp`, `LimitKey`): generate and photo limits
- `/api/sell/upload` → R2: product photos
- `lib/analytics-events.ts` (GTM `dataLayer`): funnel events
- `lib/notifications/*` (preferences, dispatch, email, Telegram, push): day 1/3/7 nudges
- `sendShopCreatedWelcome`: unchanged, must still fire exactly once per new shop

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 `shop_drafts` + `ai_allowance` migration and conditional-increment RPC | high |
| 1 | S1.2 Pure generation planner, prompts and per-block validation | low |
| 1 | S1.3 `POST /api/p2s/drafts` + SSE block stream + device cookie | high |
| 1 | S1.4 Rate limits, Turnstile, daily budget (300/day) | high |
| 2 | S2.1 Draft → view-props adapter + presentational extraction | low |
| 2 | S2.2 Describe box on `/mx/vende` and the `/sell` first run | low |
| 2 | S2.3 Taking-shape screen | low |
| 2 | S2.4 Preview canvas: EJEMPLO cards, inline edits, versions counter | low |
| 2 | S2.5 View-only draft link | high |
| 3 | S3.1 «Quedármela» keep sheet + Clerk fallback redirect | high |
| 3 | S3.2 Conditional draft claim + idempotent draft → shop apply | high |
| 3 | S3.3 Bienvenida and Puertas leave the main path | low |
| 4 | S4.1 Owner canvas + checklist from `setup-guide` | low |
| 4 | S4.2 Photo → product (Gemini vision, 20 a month) creating Medusa draft listings | high |
| 4 | S4.3 Example → real replacement + «Publicar» disabled reason | low |
| 5 | S5.1 Visual cobros / entregas chooser + checkout preview, rails unchanged | high |
| 5 | S5.2 Publish + marketplace-card moment + shares | low |
| 5 | S5.3 Funnel events | low |
| 5 | S5.4 Day 1/3/7 nudges + scheduler check | high |

**Decisions at the Plan gate (Daniel, 2026-10-27):** a. a view-only draft link before signup, yes (S2.5);
b. Cloudflare Turnstile, yes (S1.4, secrets added by the orchestrator); c. a 300/day generation budget to
start (S1.4, env default, retuned from S1's token logs).

**Flag:** none: WAYS-OF-WORKING *Feature flags — OFF by default*; rollback is `git revert`. The runtime safety
valves (daily budget, rate limits) are env and code, not flags.

## Architecture lock (2026-10-27, against storefront `origin/main` 841dd7a)

Builders **cite** these by number. Where a decision corrects the sprint docs, the correction is the contract.

**Storage and spend**
- **D1 — Supabase, service role only.** `shop_drafts` and `ai_allowance` are non-commerce staging (AGENTS rule 2).
  RLS on, `REVOKE ALL … FROM anon, authenticated`, functions `SECURITY DEFINER SET search_path = public`, `EXECUTE`
  granted to `service_role` only, and **`REVOKE ALL ON FUNCTION … FROM PUBLIC, anon, authenticated`**. Supabase grants
  EXECUTE on new functions to anon/authenticated directly, so revoking PUBLIC alone leaves an RPC callable with the
  browser's anon key. The S1 verifier caught that; `20261008170000_shop_created_welcome_deliveries.sql`, the template
  this decision first pointed to, has the same gap (reported, not fixed here).
  Nothing reaches Medusa before a claim (S3.2), and no example product ever does.
- **D2 — `shop_drafts`:** `id uuid pk default gen_random_uuid()`, `device_id uuid not null`, `description text not
  null check (char_length <= 500)`, `identity jsonb`, `words jsonb`, `catalog jsonb` (null = not generated yet),
  `block_status jsonb not null default '{}'` (`{identity|words|catalog: 'ok'|'fallback'}`), `versions_used int not
  null default 0`, `view_token uuid not null unique default gen_random_uuid()`, `claimed_by text`,
  `claimed_seller_id text`, `claimed_at timestamptz`, `created_at`/`updated_at timestamptz default now()`,
  `expires_at timestamptz not null default now() + interval '7 days'`. Index on `device_id`. The **view token is a
  separate column from the device id** so S2.5 never has to derive one from the other.
- **D3 — `ai_allowance`:** `(subject text, kind text check (kind in ('version','photo','daily_budget')), period text,
  count int not null default 0, updated_at)`, primary key `(subject, kind, period)`. Subjects: `device:<uuid>`,
  `user:<clerk id>`, `global`. Periods: `all` (anonymous versions, for the cookie's life), `YYYY-MM` (owner versions,
  photos), `YYYY-MM-DD` in `America/Mexico_City` (the budget).
- **D4 — Spend is one conditional write.** `spend_ai_allowance(p_subject, p_kind, p_period, p_cap) returns int` is a
  single `INSERT … ON CONFLICT (subject, kind, period) DO UPDATE SET count = ai_allowance.count + 1 WHERE
  ai_allowance.count < p_cap RETURNING count`: the new count, or `NULL` at the cap. `p_cap >= 1` is checked.
  Generation uses `spend_p2s_generation(p_device, p_version_cap, p_budget_period, p_budget_cap) returns jsonb` (plus `refund_p2s_generation` when the draft write after a spend fails, and `save_p2s_block`, the atomic,
  version-guarded block write), which in ONE transaction spends the device version, then the global budget, and gives the device version
  back if the budget refuses, returning `{ok, reason: 'allowance'|'budget'|null, versions_used}`. A merchant never
  loses a version to a closed budget. Two concurrent calls at 2 of 3 spend at most one: the row lock in `ON CONFLICT
  DO UPDATE` serialises them.
- **D5 — The budget is NOT on Upstash.** `checkRateLimit` passes everything through when Redis is unconfigured and
  on any Redis error (`lib/ratelimit.ts`, "fail open, never block business logic"). That is right for burst limits
  and wrong for the one control that bounds spend, which must fail **closed**. So: per-IP and per-device burst
  limits are new `LimitKey`s (`p2s_generate_ip`, `p2s_generate_device`; `p2s_photo` in S4) and may fail open; the allowance and the 300/day budget
  are D4 rows and fail closed (an RPC error refuses the generation).
- **D6 — One module owns every number.** `lib/prompt-to-shop/allowance.ts` exports `P2S_LIMITS = { anonVersions: 3,
  ownerVersionsPerMonth: 10, photosPerMonth: 20, dailyBudgetDefault: 300 }` plus the pure decision helpers. Routes,
  copy («Te quedan 2 versiones») and, later, the pricing page import it. `P2S_DAILY_BUDGET` overrides only the budget;
  an unparseable value falls back to 300, never to unlimited.

**Generation**
- **D7 — Request order (validate → protect → claim → apply).** Parse and validate the body (pure) → verify Turnstile
  → burst limit → `spend_p2s_generation` → create or update the draft → Gemini. Nothing that costs money runs before
  the spend has been claimed, and a refusal at any step makes **no** Gemini call. Specs record a trace of effects and
  assert the ORDER, not only the status (LEARNINGS → *assert the ordering*).
- **D8 — Turnstile fails closed.** Server-side verification at `https://challenges.cloudflare.com/turnstile/v0/siteverify`
  with `TURNSTILE_SECRET_KEY` and `remoteip`. A missing secret, missing token, network error or `success: false` all
  refuse with the friendly closed message. The site key is a **runtime** env (`TURNSTILE_SITE_KEY`, passed to the
  client as a prop from a server component), deliberately not `NEXT_PUBLIC_*`, so it needs no Docker build arg.
  Tokens are single use, so every generation, «Otra versión» included, needs a fresh one.
- **D9 — Three structured calls, the validator decides.** Identity → words → catalog, sequentially, each a Gemini REST
  `generateContent` call shaped like `app/api/sell/import/extract/route.ts` (`GEMINI_MODEL`, default
  `gemini-3.5-flash`) with `generationConfig.responseMimeType: 'application/json'` and a `responseSchema`. The
  schema is a hint; `validateConfig` / `validateRows` are the truth. Invalid output or any non-200 response → one
  retry → a deterministic fallback block built from the description, with the event marked `status: 'fallback'`.
  The description is isolated in tags and treated as data, as the extract route does. **Corrected premise:** the
  sprint doc asks the lock to confirm `responseSchema` support and latency on `gemini-3.5-flash`. There is no
  `GEMINI_API_KEY` in this checkout and the VM env read was refused, so neither could be measured here. The design
  above does not depend on schema support (a 400 is just a failed block), and the latency against the 20 s
  narration budget is measured in the **S1 live smoke**, with per-block timings logged.
  **Measured 2026-10-28 (storefront #437):** `gemini-3.5-flash` exists (`GET models/…` → 200) and accepts
  `responseSchema`. Its default thinking spent 980 of identity's 1024 output tokens, stopping at `MAX_TOKENS`
  mid-JSON, so every identity fell back and a run took 24.6 s. Every block now sends `thinkingConfig: {thinkingLevel:
  'minimal'}` with ≥ 2048 tokens; all three blocks come back `ok` first time in 6.6–7.4 s. **Two credentials:**
  `GOOGLE_VERTEX_SA_JSON` (the credited Cloud project, base64 service-account JSON) goes through **Vertex AI** with a
  minted, cached token. The Gemini API refuses service-account tokens. Otherwise `GEMINI_API_KEY` goes through the
  Gemini API as above. Vertex wins when both are set.
- **D10 — Block shapes.** `identity` = `profile` fields `name, tagline, description, state, city, accent_color,
  theme_preset` + `accent_alternates: [hex, hex, hex]`. `words` = `profile.announcement` + a draft-only `headline` + an
  `about` paragraph. No `hero`: its promo mode requires `promo_image_url` (`validateConfig`), and we never invent one. `catalog` = 4–6 `ExampleRow`s, where `ExampleRow = CatalogImportRow &
  { example: true; illustration: IllustrationKey }` is a **draft-only** type: `CatalogImportRow` has no example field,
  and `MiyagiSetupFile` is not widened. `illustration` is a closed enum keyed to `CATALOG_CATEGORY_KEYS`; `images` is
  always empty. A generated colour must still pass the theme contrast guard; a failing one is replaced, not shipped.
- **D11 — SSE contract.** `POST /api/p2s/drafts`, `runtime = 'nodejs'`, `dynamic = 'force-dynamic'`, response
  `text/event-stream` with `Cache-Control: private, no-store`. Events: `block` `{key, status, data}` ×3, then `done`
  `{draft_id, versions_left}`; a refusal is a plain JSON 4xx/503 with no stream. Each block is written to the draft
  (conditional on `id` + `device_id`, `.select()` back) **before** it is enqueued. A re-run sends `{draft_id}` and
  regenerates the same draft. Tokens (`usageMetadata`) and milliseconds per block are logged as `[p2s] block`.
- **D12 — Device cookie.** `p2s_device`: a server-minted uuid, `httpOnly; Secure; SameSite=Lax; Path=/`, 30 days. It
  is an allowance subject and a draft-ownership proof and nothing more. Clearing it resets the anonymous allowance;
  that hole is bounded by Turnstile, the per-IP limit and the global budget, which is why all three exist.

**Surfaces and tests**
- **D13 — Pure specs live in `e2e/*.spec.ts`** (Playwright `api` project), not `lib/prompt-to-shop/*.test.ts` as
  the sprint docs say: this app has no other unit runner, and a spec the gate does not run tests nothing.
- **D14 — The preview is the real shop.** `ShopHeader`, `ShopHero`, `WallFeed` and `ShopThemeShell` are props-only
  already. `ShopIndexBody` fetches (`getShopListings`, `getDictionary`), so S2.1 extracts a `ShopIndexGrid` taking
  listings as props, and the live `ShopIndexBody` keeps calling it. The adapter maps a draft onto
  `ShopPresentationContext` plus example cards.
- **D15 — The view token is read only by construction (S2.5).** `/p2s/v/[token]` reads by `view_token` and renders
  with no controls. Every mutating route resolves its draft by `id` + the device cookie and never accepts a view token.
- **D16 — Claim, then apply, never over HTTP to ourselves (S3.2).** The claim is one conditional `UPDATE … WHERE id
  AND device_id AND claimed_by IS NULL AND expires_at > now() RETURNING` (`.select()` back). Zero rows → re-read:
  same Clerk user → idempotent, return the existing shop; anything else → «Esta tienda se armó en otro teléfono».
  The shop is created by calling the logic behind `POST /api/sell/shop` **in-process** (extracted to a shared
  function if it is not already), never by `fetch()`-ing our own authed route, which drops the cookie (team memory,
  PR 244). Only `profile` + `config` are applied; the examples stay in the draft.
- **D17 — The checklist is `getSetupSteps`, unchanged (S4.1).** **Corrected premise:** its steps are `perfil · catalogo
  · pagos · envios · comparte`; there is no "publicar" or "fotos" step. The canvas labels `catalogo` as Fotos,
  `pagos` as Cobros and `envios` as Entregas, uses the same % as Resumen, and «Publicar» is the canvas's action, not a
  % step. Adding a step would break Resumen parity.
- **D18 — The «Con IA» pricing row leaves S4.2.** **Corrected premise:** `/mx/precios` does not exist and
  `pricing-page` is build #9, after this epic (#6). S4.2 ships the numbers in D6's module; the row ships with
  `pricing-page`, reading that module. The rule "never retyped" holds.
- **D19 — Nudges need a preference group (S5.4).** `EVENT_GROUPS` is `orders · offers · payments · returns · mensajes`.
  S5.4 adds `onboarding`; re-verify at S5 start whether the preferences table constrains `event_group` (a CHECK would
  make it a migration). The VM timer is a new `infra/oci/systemd/miyagi-cron-p2s-nudges.timer` in the root repo,
  enabled on the VM by the orchestrator.
- **D20 — Found while locking, out of scope:** of the ten `app/api/cron/*` routes, five have no VM timer
  (`offer-reminders`, `portfolio-reminders`, `listing-cleanup`, `reconcile-checkouts`, `sweepstakes-draw`); only five
  `miyagi-cron-*.timer` units exist. Reported to Daniel, not fixed here.
- **D21 — Routing.** S1 and S3 (spend, auth, claim) to the strongest model; S2, S4.1, S4.3 and S5.2/S5.3 to the
  workhorse; S4.2, S5.1 and S5.4 strong. Every PR: `review-route.mjs` passes plus the fresh `verifier` (high risk).
- **Waves.** The bet is funded one wave at a time. **Wave 1 = this lock + S1** (the rail); S2–S5 are re-bet at each
  boundary.

### Build contract — S1 · Generation rail
- **1.1** `supabase/migrations/<ts>_prompt_to_shop_drafts.sql` per D1–D4, with a "how this gets applied" header
  (orchestrator, MCP, realign `schema_migrations`). Pure `lib/prompt-to-shop/allowance.ts` per D6. Spec: the decision
  helpers, observed red under a mutation.
- **1.2** `lib/prompt-to-shop/{planner,prompts,blocks,fallback}.ts`, pure (no `next/*`, no fetch): build each call's
  request body and schema; parse and validate a response into a block or a failure; fallback blocks; mark examples
  (D10). Specs: planner, validation, fallback, example marking; each observed red.
- **1.3** `app/api/p2s/drafts/route.ts` per D7, D11, D12, with injected I/O (Gemini, Supabase, Turnstile, clock) so the
  `api` spec drives it with fakes. No Medusa import in the route's module graph.
- **1.4** D5 limit keys, D8 Turnstile, D4 budget. Refusal copy: allowance → «Ya usaste tus 3 versiones. Quédate con
  la que más te guste.»; budget → «Hoy ya armamos muchas tiendas. Vuelve mañana o déjanos tu correo.»; Turnstile or
  config missing → «No pudimos verificar que eres tú. Recarga la página e inténtalo de nuevo.»
- **Gate:** `tsc --noEmit`, `npm run build`, `npm run test:e2e` green; the migration applied and verified live
  **before** merge.

### Build contract — S2 · Describe, shape, preview
D14 extraction with a visual check of one live shop; the describe box and the new hero copy in
`locales/es.json` → `sellerAcquisition.anchor`; the taking-shape screen consumes D11's events; the canvas autosaves
through `PATCH /api/p2s/drafts/[id]` (device-cookie-owned, D15), with versions through D4; `noindex`, `private`; the
forbidden-word spec covers screens 1–3; `/p2s/v/[token]` per D15.

### Build contract — S3 · Keep it
The keep sheet uses `signUpFallbackRedirectUrl` / `signInFallbackRedirectUrl` (fallback, never force); claim + apply
per D16; `sendShopCreatedWelcome` stays on its existing reserve-once path (`reserve_shop_created_welcome`);
`/sell/bienvenida` and `/sell/puertas` redirect to the new first run, and `/sell`'s
`onboarding.three_doors_enabled` branch is removed; a source sweep finds no link to the old routes.

### Build contract — S4 · Make it yours
D17 checklist; photo → product through `/api/sell/upload` → R2, Gemini vision → one `CatalogImportRow` →
`validateRows` → one Medusa **draft** product on confirm, spending `photo` through D4 (20/month); D18 descope;
replacing an example deletes it from the draft's `catalog`; «Publicar» disabled until ≥ 1 real product.

### Build contract — S5 · Pay, deliver, publish, return
The existing rails only (Mercado Pago OAuth, SPEI CLABE, cash/arranged; arranged delivery, Correos económico, manual
carrier); checkout preview pure-derived from the chosen methods; publish + `SuccessCard` + `lib/share-link.ts`; the
seven funnel events through `pushAnalyticsEvent`, once per step; nudges per D19, with the VM timer confirmed by one
fired run.

## Deploy order
1. **S1.1 migration first**, applied by the orchestrator through Supabase MCP `apply_migration` (never
   `supabase db push`), then `schema_migrations` realigned and the tables verified live. Re-verify the premise
   at apply time.
2. **Turnstile keys and `P2S_DAILY_BUDGET`** on the VM env files before S1.4 deploys; a missing key must fail
   closed with the friendly "come back later" message, never open.
3. Storefront only after that: no Medusa backend change is planned. If the locking pass finds one (say, a
   seller field for the draft id), the backend deploys first.
4. Each sprint merges to `main`, the arm64 image builds, then
   `ssh -i ~/.ssh/panfleto_oci ubuntu@159.54.158.4 /opt/miyagi/infra/oci/update.sh`. Verify on `main` after
   deploy, not only on the branch.
5. **S5.4 needs a scheduler entry** for its cron route on the VM (infra, orchestrator-owned), confirmed before
   the story is called done.

## Definition of Done (epic)
- [x] All sprints merged to `main` + smoke-tested (gaps stated — `node scripts/owed-ledger.mjs` counts what is still owed)
- [x] Each `sprint-N.md` has its smoke walkthrough (real URLs)
- [x] This README marked ✅; every sprint status ticked with commit refs
- [x] `RETROSPECTIVE.md` written
- [x] Product poster (`Roadmap/README.md`) updated
- [x] Team memory + `MEMORY.md` index updated
- [x] Durable learnings promoted to `Roadmap/LEARNINGS.md` (dedupe — sharpen, don't append)
- [ ] **Kill-switch (only if one was planned at refining — Stage 6b):** the flag slice shipped, the flag
      exists **in Golden Frijoles, in every env**, with the stated polarity, **and its switch is set there** —
      `frijoles flags get <key>` must print `on vN` or `off vN` in its PRODUCTION row (a bare `off` with no version
      means nothing is served there, so the app runs on its own built-in default). A newly synced flag goes live as written in its file; a sync never switches an existing one. *Verify-only — not a new gate; whether a high-risk epic needs one
      is decided at refining, not here.*
- [ ] Feature branch deleted; **this README's frontmatter `status: shipped`** (the SSOT — the board & Notion derive from it; run `node scripts/build-order.mjs`)
