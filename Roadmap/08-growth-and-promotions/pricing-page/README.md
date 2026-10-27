---
status: scaffolded   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Shaping       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
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
