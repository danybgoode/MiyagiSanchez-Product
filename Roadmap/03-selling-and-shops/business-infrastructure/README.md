---
status: in-progress   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Building       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
locked_at: "2026-11-03T22:00:00Z"
slug: business-infrastructure
title: "Business infrastructure — describe any business, we set up everything"
area: 03-selling-and-shops
risk: high
type: feature
sprints_total: 5
stories_total: 14   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 88   # copied from the seed (intent-match); the reader at the lock may update it
quote_low_usd: 50    # ≈ API $ — from the seed's `quote:`; null = not quoted, never 0
quote_high_usd: 300
quote_basis: "L, n=0, wide"
hypothesis: "Any Mexican merchant, new or already selling, prices by gut, can't say what a month must sell to pay them, and has nobody to answer buyers. Describing the business now sets up the right shop, a money plan from its real numbers and a shop that answers. We'll know when shops published from a description grow."
target_metric: "shops published from a description by real merchants (product-owner tests excluded), in the 30 days after ship"
target_from: 0
target_to: 4
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "Any Mexican micro-merchant (products, services, food, made-to-order, rentals), new or already selling on Miyagi, who sells by WhatsApp, Instagram or in person, on a phone, and has never done the maths on what their business must sell to pay them"
grounded: false
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist); funded as the next step of prompt-to-shop for the YC W27 story"
flag_key: null   # no flag: WAYS-OF-WORKING → Feature flags (rollback is git revert)
target_segment: null
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null
build_order: 12
---

# Epic: Business infrastructure — describe any business, we set up everything

> **Area:** 03-selling-and-shops · **Risk:** high · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/business-infrastructure-productize-anything.md`](../../00-ideas/seeds/business-infrastructure-productize-anything.md)

## Why
Any Mexican merchant, new or already selling, prices by gut, can't say what a month must sell to pay them, and has
nobody to answer buyers. Describing the business now sets up the right shop for whatever they sell (products,
services, food, made-to-order, rentals, digital), a money plan built from their real numbers («Tu plan»: what to sell,
what to change, checked every month), and a shop that answers buyers and their agents, handing the owner what it
cannot answer. We'll know when shops published from a description grow (0 → 4 real merchants in 30 days).

## Platform-first note
Commerce stays in Medusa: products, prices and COGS (`unit_cost_cents`, private variant metadata) are read and written
only through the existing seller routes. The shop's FAQ, about and return policy already live in the seller's
settings (`lib/settings-import.ts` → `content.faq` ≤ 12 items, `returns_policy`, `about`) and render at
`/s/[slug]/faq` + `/politicas`: the chat's knowledge is **that**, not a new store. Only non-commerce state is new and
goes to Supabase (AGENTS rule 2): the business model and the chat threads.

## What already exists (reuse, don't rebuild)
- `lib/prompt-to-shop/` — planner (`generateBlock`/`generateDraft`, injected model, ordered save → emit), `blocks.ts`
  (validation through `validateRows`), `prompts.ts` + `RESPONSE_SCHEMAS`, `vertex.ts`, `allowance.ts`
  (`spend_ai_allowance`, `spend_p2s_generation`), `turnstile.ts`, `claim.ts`/`claim-server.ts` (keep →
  `applyStoreConfig` in-process), `photo.ts`/`photo-server.ts` (photo → Medusa draft product), `funnel.ts`,
  `nudges*.ts` + `/api/cron/p2s-nudges` + VM timer `miyagi-cron-p2s-nudges.timer`.
- `lib/catalog-import.ts` (`IMPORT_LISTING_TYPES`, `unit_cost`) and `lib/seller-product-create.ts:51`
  (`unit_cost` → `unit_cost_cents`).
- `lib/profit.ts` — `computeSkuMargins`, `solveForPrice` (line 417), `classifyMarginKillers`, `classifyUnderpriced`;
  backend `GET /store/sellers/me/profit`; `/shop/manage/profit` (the Apply path).
- `lib/settings-import.ts` + `lib/apply-config-manifest.ts` — FAQ/about/policies write path.
- `lib/notifications/dispatch.ts` (`dispatchToSeller`, groups `onboarding` · `mensajes`), `lib/notifications/catalog.ts`
  (every new message registered), `lib/email.ts` (Resend senders), `lib/ratelimit.ts`.
- `app/api/ucp/mcp/route.ts` + `lib/ucp/capabilities.ts` — tool registry and manifest.
- `app/(shell)/s/[slug]/` (shop page, `ChannelLayout.tsx` white-label shell), `app/(shell)/embed/s/[slug]`.
- `~/dobby/bonsai-chat` — `server.mjs` (system prompt, Vertex SSE, tool loop, `notify()`, rate limit, origin check) and
  `public/widget.js` (launcher UX). Ported, not called.

## Architecture lock — D1…D18 (verified against live code and the live DB, 2026-11-03)

- **D1 · Shape rides the identity block.** `identity.shape` ∈ `products | services | food | made_to_order | rentals |
  digital`, returned by the identity call (no extra model call). Validated in `blocks.ts`; a missing/invalid shape is
  `products` (today's behaviour). The one enum and its maps live in `lib/business-shape.ts`.
- **D2 · Shape → defaults is pure data.** `SHAPE_DEFAULTS[shape]` = listing type for generated rows
  (`food/made_to_order/products → product`, `services → service`, `rentals → rental`, `digital → digital`), the
  cobros/entregas the chooser pre-selects and hides (food: cash + hand delivery on, Correos hidden; services and
  digital: no delivery step), and the copy nouns. No new listing type, no new checkout path.
- **D3 · Changing the shape is a re-run.** `parseDraftsBody` accepts an optional `shape` (closed enum, like `tone`);
  it costs one version exactly like «Otra versión». No free re-generation path.
- **D4 · Examples never become products at keep — verified** (`claim.ts:11`: "The catalog examples never leave the
  draft"). The seed's "unit cost lands as COGS on keep" is fiction. **Deviation:** an example carries an estimated
  `unit_cost`; when a photo confirm replaces that example, the card carries it and `seller-product-create.ts:51` writes
  `unit_cost_cents`. Estimated cost reaches COGS through the existing create path, never a new write.
- **D5 · A fourth draft block, `numbers`.** Generated after `catalog`: inputs only — per-offer cost lines and minutes
  per unit, monthly capacity with the resource that limits it, fixed monthly cost lines. Schema-validated; the fallback
  is an *empty* model ("faltan datos"), never invented figures. Stored in a new `shop_drafts.numbers` jsonb column;
  `save_p2s_block`'s key list gains `'numbers'` (migration M1). `coerceBlocks` reads it.
- **D6 · One business model per shop, every input with its source.** Table `business_models` (M1): one row per
  `(clerk_user_id, shop_slug)`; `inputs jsonb` where every value is `{ value, source: 'estimated'|'told'|'measured',
  at }`; `goal_cents`; `explanation jsonb` (text + inputs hash); `last_checkin_period text`. Service role only:
  `REVOKE ALL … FROM PUBLIC, anon, authenticated`. At claim, the draft's `numbers` seed the row (all `estimated`).
  Join on the slug — `getShop()` returns the Medusa seller, whose id is NOT `marketplace_shops.id` (LEARNINGS).
- **D7 · Provenance rules (pure, `lib/business-plan/model.ts`).** `told` is never overwritten by `estimated`;
  `measured` replaces `estimated` once `MEASURED_MIN_UNITS` sales back it (a named constant with its reason) and
  replaces `told` only when the merchant confirms. Missing is a named gap, never 0.
- **D8 · The engine is pure and computes everything (`lib/business-plan/engine.ts`).** Contribution per unit,
  break-even volume, volume needed for the goal, monthly capacity, the binding constraint (`capacity` when needed >
  capacity, `demand` when needed > current sales, `inputs` when the comparison cannot be made, naming the missing
  input), contribution per unit of the bottleneck resource. Prices come from `solveForPrice` in `lib/profit.ts`,
  imported, never re-derived.
- **D9 · Moves are typed and only link.** `{ kind: 'reprice' | 'push' | 'pause' | 'grow_demand' | 'fill_input', … }`,
  ranked by effect on the goal. Each opens an existing surface: reprice → `/shop/manage/profit` (its confirmed Apply),
  push → the share kit for that product, pause → the listing editor, grow_demand → `/shop/manage/comparte`,
  fill_input → inline edit. **No new mutation path; nothing applies itself.**
- **D10 · The model only writes words.** One call over the engine's JSON returns the es-MX explanation; a pure guard
  rejects any text containing a number not in the engine output (digits normalized) and falls back to a deterministic
  template. Cached by inputs hash in `business_models.explanation`; regenerated only when inputs change.
- **D11 · Existing shops are seeded, not asked.** `/shop/manage/plan` reads the seller's catalog with
  `unit_cost_cents` and the ledger (`GET /store/sellers/me/profit`, same call as the profit page) for the last 90 days:
  units, average price and cost per product become `measured`; only gaps are asked.
- **D12 · Monthly check-in.** `GET /api/cron/business-checkin` (header `x-cron-secret`, constant-time, like
  `p2s-nudges`), timer `infra/oci/systemd/miyagi-cron-business-checkin.timer` on the 1st at 15:00 UTC. Claim before
  send (conditional update of `last_checkin_period`, `.select()` back). Delivered via `dispatchToSeller` group
  `onboarding`; registered in `COMMUNICATION_CATALOG`. A failed read answers 503, never an empty 200.
- **D13 · The chat is bonsai-chat, ported.** `lib/shop-chat/` (pure: knowledge from settings `faq`/`about`/
  `returns_policy` + cobros/entregas + a catalog snapshot read from Medusa at request time; system prompt; the
  `leave_message` tool; body validation) and `app/api/shop-chat/[slug]/route.ts` (SSE). The shop is resolved
  server-side from the path slug via `getShop` + the preview-private check — never from the body. Vertex through the
  existing service account.
- **D14 · Chat guards.** bonsai-chat's (rate limit, size caps, history cap) via `lib/ratelimit.ts`, plus Turnstile at
  chat start and a per-shop + global daily cap via `spend_ai_allowance(kind 'shop_chat')`. Over the cap the chat says
  so and offers `leave_message`. The model sees only this shop's knowledge; prices and stock are quoted from the
  snapshot; anything else is «no sé».
- **D15 · Where it renders.** `<ShopChat>` launcher on the marketplace shop page, the product page, the white-label
  shell (`ChannelLayout`: custom domain + subdomain) and the embed, clear of the tab bar and safe area. Not on
  preview-private or unclaimed shops.
- **D16 · Agents.** `ask_shop` (public buyer tool: `{ slug, question }` → `{ answer, answered }`, same knowledge and
  guards, non-streaming) and `get_business_plan` (seller tool, the engine output) in `app/api/ucp/mcp/route.ts` and
  `lib/ucp/capabilities.ts`.
- **D17 · Handoff that learns.** `leave_message` writes `shop_chat_threads` (M2: shop slug, seller clerk id,
  question, transcript, buyer email, status `open|answered`, answered_at; service role only, REVOKE). The seller is
  alerted via `dispatchToSeller` group `mensajes`; `/shop/manage/preguntas` lists threads; a reply emails the buyer
  (new Resend sender, catalogued) and marks `answered` conditionally; «Guardar como pregunta frecuente» appends to
  `content.faq` through `applyStoreConfig` (the 12-item cap is the existing validator's). The monthly cron nulls
  `buyer_email` 90 days after `answered_at`. Only threads with a left message are stored.
- **D18 · No flag; migrations by the orchestrator.** Rollback is `git revert`. M1 (S2) and M2 (S4) are applied via
  Supabase MCP `apply_migration` **before** their PR merges, `schema_migrations` realigned, verified live (4 layers);
  never `db push`.

**Deviations from the seed, named:** D4 (COGS via photo confirm, not keep). The seed's "FAQ block" becomes the
existing settings FAQ (no new FAQ store). Messaging stays stamps-only; the chat is beside it.

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | 1.1 The keep sheet scrolls and signs up (bug) | high |
| 1 | 1.2 Any business is recognised | high |
| 1 | 1.3 The shop fits the business | high |
| 2 | 2.1 The business model and its sources | high |
| 2 | 2.2 «Tus números» in the canvas | high |
| 2 | 2.3 Existing shops are seeded from their sales | high |
| 3 | 3.1 The plan: volume, break-even, bottleneck | high |
| 3 | 3.2 Moves you can act on | high |
| 3 | 3.3 The words, never the maths | high |
| 3 | 3.4 The monthly check-in | high |
| 4 | 4.1 The shop's chat (bonsai-chat ported) | high |
| 4 | 4.2 Everywhere the shop is, and for agents | high |
| 4 | 4.3 FAQ written at describe, editable | low |
| 5 | 5.1 Handoff that learns | high |

## Routing (epic mode)
Orchestrator (Opus 5.5) builds every high story; S4.3 (FAQ editor UI) may go to a Sonnet-class builder. Review per
PR: deterministic gate, fresh `pr-reviewer`, one cross-family pass (`review-route.mjs`; codex on gpt-6-luna @ xhigh),
security lens on S1.1 (sign-up), S2 (migration), S4 and S5 (public AI endpoint, PII). Merges pre-authorized on green.

## Deploy order
Storefront only (no backend change). Stacked branches `fix/p2s-keep-sheet-scroll` (S1.1, merged first) →
`feat/business-infrastructure` (S1) → `-s2` → `-s3` → `-s4` → `-s5`. M1 applied before S2 merges, M2 before S4.
Each merge builds the arm64 image; deploy = `update.sh` on the VM; the check-in timer is installed on the VM after S3.

## Definition of Done (epic)
- [ ] All sprints merged to `main` + smoke-tested (gaps stated — `node scripts/owed-ledger.mjs` counts what is still owed)
- [ ] Each `sprint-N.md` has its smoke walkthrough (real URLs)
- [ ] This README marked ✅; every sprint status ticked with commit refs
- [ ] `RETROSPECTIVE.md` written
- [ ] Product poster (`Roadmap/README.md`) updated
- [ ] Team memory + `MEMORY.md` index updated
- [ ] Durable learnings promoted to `Roadmap/LEARNINGS.md` (dedupe — sharpen, don't append)
- [ ] Feature branch deleted; **this README's frontmatter `status: shipped`** (the SSOT — the board & Notion derive from it; run `node scripts/build-order.mjs`)
