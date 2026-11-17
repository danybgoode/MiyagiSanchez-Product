---
status: scaffolded   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Shaping       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: coordinated-sales-readiness
title: "Coordinated sales readiness"
area: 03-selling-and-shops
risk: high
type: bug
sprints_total: 2
stories_total: 5   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: null   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: null    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: null
quote_basis: null
hypothesis: null   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: null   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A merchant selling a service, a rental or a paid Evento, and the buyer paying for it."   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: null   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: null   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 22      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: Coordinated sales readiness

> **Area:** 03-selling-and-shops · **Risk:** high · **Class:** Bug · **Scope seed:** [`00-ideas/seeds/coordinated-sales-readiness.md`](../../00-ideas/seeds/coordinated-sales-readiness.md)
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
A paid event ticket must be buyable by card, and a service or rental must never look buyable on a shop that cannot be
paid for it. Today every `service` (events included, since the 11-11 Evento preset) is a coordinated sale — SPEI or
cash only — so tickets are refused by card, while priced services and rentals publish on card-only shops as if buyable.

## Platform-first note
Medusa owns it: backend `isCoordinatedListing` (`_utils/delivery-catalog.ts`) is the one checkout-side predicate,
called by checkout-options and `start-checkout`; the event predicate `hasEventBlock` (`_utils/inventory.ts`) already
drives seats. No model change, no migration.

## Locked decisions
- **D1 (Daniel, 2026-11-16):** an event ticket takes any rail; a plain service and a rental stay SPEI/cash only.
- **D2 — one event predicate:** the backend's `hasEventBlock` (a date OR a venue). The storefront's readiness rule
  must use the same definition, or publish and checkout disagree.
- **D3 — price shapes:** `price_cents` null («precio a consultar») = contact-only, ungated; 0 (free event) = RSVP, no
  rail needed; > 0 = needs a rail (any for an event, SPEI/cash for a service or rental).
- **D4 — deploy order:** backend first (events become card-payable; nothing else changes), then storefront (the gate).

## What already exists (reuse, don't rebuild)
- Backend: `isCoordinatedListing` + `buildDeliveryCatalog`, `start-checkout` COORD guard (~:690), `hasEventBlock`,
  `listingSaleFacts` (`sellers/me/products/[id]/route.ts`).
- Storefront: `lib/listing-readiness.ts` (`listingReadiness`, `listingCanBePaid`, `COORDINATED_TYPES`,
  `READINESS_COPY`), `lib/shop-collect.ts`, `lib/readiness-view.ts`, `ReadinessPanel`, `lib/evento-preset.ts`,
  `app/api/sell/create/route.ts`, `lib/listing-status.ts`.

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 an event ticket is not a coordinated sale · S1.2 the owner product read says event + priced | high |
| 2 | S2.1 the rule covers services/rentals/events · S2.2 every door and surface follows · S2.3 owed money smokes | high |

## Deploy order
Backend first (D4), then storefront, in one `update.sh` or two. The storefront degrades safely on an older backend:
missing `is_event`/`priced` = unreadable → activation fails open (listing-readiness D3).

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
