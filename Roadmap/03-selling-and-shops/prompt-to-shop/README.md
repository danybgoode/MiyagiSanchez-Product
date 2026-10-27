---
status: scaffolded   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Shaping       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
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
