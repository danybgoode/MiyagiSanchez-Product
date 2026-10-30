---
status: scaffolded   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Shaping       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: root-shop-builder-home
title: "The shop builder opens at miyagisanchez.com"
area: 08-growth-and-promotions
risk: low
type: feature
sprints_total: 2
stories_total: 10   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 90   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 27    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 40
quote_basis: "M, n=3, p25–p75"
hypothesis: "A merchant who hears our domain lands on a country picker that never shows the shop builder. Opening the home page on describe-your-business turns the name we can say out loud into the whole pitch. We'll know when more shop-builder starts come from the home page than from the old seller page."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: "share of p2s_describe_submitted started on / (vs /mx/vende)"   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A Mexican micro-merchant who hears 'miyagisanchez.com' by word of mouth, a flyer or a promoter, and types the bare domain on a phone"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist); funded because the product owner's own acquisition channel (saying the domain) dead-ends on a selector"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 10      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: The shop builder opens at miyagisanchez.com

> **Area:** 08-growth-and-promotions · **Risk:** low · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/root-shop-builder-home.md`](../../00-ideas/seeds/root-shop-builder-home.md)
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
A merchant who hears "miyagisanchez.com" — from Daniel, a flyer or a promoter — types the bare domain on a phone and
lands on a country picker that never shows what we sell. The shop builder that shipped on 10-28 lives at `/mx/vende`,
a URL nobody guesses. With few buyer visitors, the marketplace is not yet the draw; the shop is. This epic opens the
root on the Mexico seller page, describe box first, and makes the marketplace one tap away at `/mx`. `/en` is
untouched (product owner, 10-29). No proof section in v1 (product owner, 10-29). Full pitch, rabbit holes and the
decisions taken at refining: the scope seed.
<!-- One paragraph: the outcome this epic delivers and for whom. Plain product language, no tech. -->

## Platform-first note
Storefront-only (`apps/miyagisanchez`): routing, a page move, copy and specs. No commerce data, no Supabase table, no
Medusa change, no migration. Copy stays in the dictionary so `/admin/contenido` keeps editing it.

## What already exists (reuse, don't rebuild)
<!-- Concrete files / routes / primitives the platform-first reframe surfaced. -->
-

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 `/` renders the Mexico seller page, describe box first | low |
| 1 | S1.2 No auto-hop from `/` to `/en`; footer country + language links | low |
| 1 | S1.3 `/mx/vende`, `/vende` → `/`; `/mercado` → `/mx` (308, one hop, tags kept) | low |
| 1 | S1.4 Every seller-landing link, sitemap, `llms.txt`, agent surfaces name `/` | low |
| 1 | S1.5 Old-root specs rewritten for the new contract (each seen red once) | low |
| 1 | S1.6 Deploy, Cloudflare purge, live smoke, TTFB before/after | low |
| 2 | S2.1 Section order: describe → what you get → pricing → marketplace bonus | low |
| 2 | S2.2 Pricing block from the one catalog, links `/mx/precios` | low |
| 2 | S2.3 "¿Vienes a comprar?" link to `/mx` | low |
| 2 | S2.4 Mobile sweep 360/390/414, deploy + purge + smoke | low |

## Deploy order
Storefront only. Merge → arm64 image green → `ssh … /opt/miyagi/infra/oci/update.sh` → verify the VM container
runs the merge SHA → purge Cloudflare for `/`, `/mx/vende` → live smoke. Once per sprint.
<!-- Backend-first? Frontend degrade gracefully? Preview vs prod. -->

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
