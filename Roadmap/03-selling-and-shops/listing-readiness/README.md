---
status: in-progress   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Building       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: listing-readiness
title: "Guided listing readiness"
area: 03-selling-and-shops
risk: high
type: feature
sprints_total: 2
stories_total: 5   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: null   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 27    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 40
quote_basis: "M, n=3, p25–p75"
hypothesis: "We believe that telling a merchant, at publish time, exactly what stops a product from being bought (and letting them fix it inline or choose catalog-only on purpose) will end unbuyable listings and dead-end offers, because today 3 of 5 shops with live products cannot take money and nothing told them."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: "share of shops with live products that can take payment or are explicitly catalog-only"   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: 2   # from what, a number
target_to: 5       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A new merchant (often guided by a promoter) publishing their first products."   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No Roadmap/00-strategy yet; funded from a live promoter-training failure (miel-verduras, 2026-11-11)."   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 20      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: Guided listing readiness

> **Area:** 03-selling-and-shops · **Risk:** high · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/listing-readiness.md`](../../00-ideas/seeds/listing-readiness.md)
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
A merchant must never publish a product a buyer can't pay for without knowing it, and a buyer must never be offered a
buy or offer path that dead-ends. Every product either sells online or is deliberately «Solo catálogo» (buyers write to
the merchant). Reported live 2026-11-11 (miel-verduras); 3 of 5 shops with live products could not take money.

## Platform-first note
Payment and delivery readiness are facts of the **Medusa seller** (`metadata.settings`). The Supabase mirror lags
(no bank-transfer config) and is never read for readiness. No new model, no migration, no column: «Solo catálogo» is
derived at read time.

## Locked decisions
- **D1 — the rule.** A `product` sells online iff ≥1 payment method (card, MP, bank transfer, DiMo) AND a delivery path
  (shipping/pickup, or `arranged` + a manual method — SPEI or cash). Otherwise catalog. Non-product types exempt.
  Price/currency/market/claim/pause stay in their existing seams.
- **D2 — two fact readers, one rule.** `ownerShopFacts(meta)` (private settings: CLABE length, DiMo phone, cash) for
  owner doors; `publicShopFacts(meta)` (sanitized projection: `configured` flags) for buyer surfaces.
- **D3 — publish fails open on an unreadable shop (as today); offers fail CLOSED (503).**
- **D4 — catalog is derived, never stored.** `publish_as_catalog: true` only unlocks the publish/activate.
- **D5 — offers need a shop that can collect** (any payment method); accept AND counter are refused, decline allowed.

## What already exists (reuse, don't rebuild)
- `lib/checkout-viability.ts` (rule) · `lib/listing-status.ts` (activate gate) · `lib/seller-products.ts` `listingActivationBlock` (MCP)
- `lib/public-shop-commerce.ts` (public payment reader) · `lib/commerce-readiness.ts` (price/market)
- `app/(shell)/p2s/_components/CobrosChooser.tsx` + `lib/prompt-to-shop/cobros.ts` (inline payments/delivery fix)
- `lib/offer-respond.ts` `respondToOffer` (web + MCP) · `app/api/offers/route.ts`
- `lib/setup-guide.ts` + `SetupGuideCard.tsx` · `app/(shell)/shop/manage/catalogo/CatalogTable.tsx`

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 One readiness rule · S1.2 create/activate gate · S1.3 offer gate | high |
| 2 | S2.1 wizard readiness panel · S2.2 panel banner, badges, guide | low |

## Deploy order
**Backend first** (MiyagiSanchez-Backend #234 — the owner product read returns `listing_type` + `delivery_mode`), then the
storefront (#497), in one `update.sh`. Either order is safe: an older backend reads as "unknown" and activation fails
open (D3). No migration, no flag (operating posture); rollback = revert.

## Recorded scope decisions (from review)
- **Doors left as they were, made visible by S2.2:** CSV/Shopify import publishes by default (a bulk migration — gating it
  would silently draft whole catalogs); promoter preview activation has its own consent checklist; promoter close and
  launchpad create on unclaimed shops / for print editions where the claim gates already stop buying.
- **Bulk activate stays strict** (no catalog acknowledgement); single activate in Catálogo offers «Publicar como catálogo».
- **MCP** keeps its existing strict gate (callers do not pass a delivery mode).

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
