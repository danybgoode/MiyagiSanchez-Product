---
status: scaffolded   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Locking architecture       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: own-shop-positioning
title: "Own-shop positioning: the site says what Miyagi Sánchez is now"
area: 08-growth-and-promotions
risk: low
type: feature
sprints_total: 3
stories_total: 3   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 89   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 27    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 40
quote_basis: "M, n=3, p25–p75"
hypothesis: "The site and the agent surfaces still call us a P2P marketplace, contradicting the promoter's pitch. Saying «your own shop, built with you, 0% commission» everywhere, with the hidden features named and a page per business type, makes the site back the sale. We'll know when a merchant's AI repeats that definition."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: "Share of /acerca, /agent, llms.txt and about_miyagi answers that define Miyagi Sánchez as the merchant's own shop (an AI ask-test, read by hand)"   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: 0   # from what, a number
target_to: 1       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A small business in Mexico with no online presence beyond Google Maps, who meets a promoter or finds the site, and asks their own AI what Miyagi Sánchez is"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist). Funded because Daniel decided the positioning on 2026-11-09 (decision 11) and promoters started selling on it on 2026-11-11"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 18      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: Own-shop positioning: the site says what Miyagi Sánchez is now

> **Area:** 08-growth-and-promotions · **Risk:** low · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/own-shop-positioning.md`](../../00-ideas/seeds/own-shop-positioning.md)
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
The site, `/acerca` and every agent surface still call Miyagi Sánchez a P2P marketplace, while promoters sell «your own shop, built with you, 0% commission». This epic rewrites the definition everywhere it renders, moves the marketplace to a benefit, names the six features merchants never see, and gives promoters one page per business type. Decided 2026-11-09 (decision 11) and 2026-11-11. See the [pitch](../../00-ideas/seeds/own-shop-positioning.md).

## Platform-first note
Copy only, on surfaces that already exist: one source (`lib/about-content.ts`) projects onto five agent surfaces; the vertical pages come from `page-config.ts`; prices read `pricing-catalog.ts`. Nothing new in the data model.

## What already exists (reuse, don't rebuild)
<!-- Concrete files / routes / primitives the platform-first reframe surfaced. -->
-

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 Every surface says «your own shop» | low |
| 2 | S2.1 Six features merchants never see, said in our words | low |
| 3 | S3.1 One page per business type | low |

## Deploy order
Storefront only. Merge builds the image; deploy with the VM `update.sh`; prove the container SHA equals the merge SHA; purge the CDN for `/` and `/acerca` and check `x-nextjs-cache`.

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
