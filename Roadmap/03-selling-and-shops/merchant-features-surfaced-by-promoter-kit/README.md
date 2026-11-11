---
status: scaffolded   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Locking architecture       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: merchant-features-surfaced-by-promoter-kit
title: "Merchant panel gaps: seats, one Evento, Comparte into Canales, the field loop"
area: 03-selling-and-shops
risk: high
type: feature
sprints_total: 3
stories_total: 4   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 92   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 27    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 40
quote_basis: "M, n=3, p25–p75"
hypothesis: "Events can oversell and the share tools sit on an unlinked page. Seat limits, one Evento in the wizard, share tools in Canales and a counted field report let a promoter set up an event business in one visit. We'll know when an event sells out instead of overselling and promoter reports reach the admin feedback page."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: "Event listings with a seat limit; promoter reports in platform_feedback"   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: 0   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A merchant selling dated experiences (a play, a workshop, a class) or sharing their catalog on WhatsApp; and the field promoter who sets them up and reports what they hear"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist). Funded because the gaps were confirmed in code on 2026-11-11 and promoters met these businesses in their first zones"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 17      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: Merchant panel gaps: seats, one Evento, Comparte into Canales, the field loop

> **Area:** 03-selling-and-shops · **Risk:** high · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/merchant-features-surfaced-by-promoter-kit.md`](../../00-ideas/seeds/merchant-features-surfaced-by-promoter-kit.md)
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
Promoters now sell to plays, workshops and service businesses. Today an event listing can oversell because the wizard never asks for seats, the free RSVP Eventos page is a second system with zero rows, and the share tools sit on a page no menu links to. This epic gives events a seat limit, makes «Evento» one wizard choice (free or paid), moves the share tools into Canales, and gives promoters a counted place to report what merchants ask for. See the [pitch](../../00-ideas/seeds/merchant-features-surfaced-by-promoter-kit.md).

## Platform-first note
Medusa owns inventory: seats are tracked variant inventory (`manage_inventory`), the same primitive physical products use; the cap read (`available_quantity` → `ticketQuantityCap`) already exists on the PDP, `/checkout` and UCP. Free registrations stay on the Supabase RSVP machinery (no $0 Medusa checkout), re-keyed to the listing. Field reports reuse `platform_feedback`.

## Architecture lock (2026-11-11, against storefront `b7a4862`, backend `origin/main`, live DB)

- **D1 · Seats are Medusa inventory, written by the backend.** `isStockableListingType` (backend
  `src/api/store/_utils/inventory.ts`) returns true only for `product`. It gains an event case: a `service` or
  `digital` listing whose `attrs` carry the event block (`event_date` or `venue_name`) AND a `quantity` is stockable.
  Create (`seller-product-create.ts`) and update (`seller-product-update.ts:980–1013`, today 422 «Only physical products
  can have a stock quantity») share that one predicate. Update flips `manage_inventory` on and provisions the level
  when an existing event listing first gets seats (`provisionVariantInventory`).
- **D2 · The field is «Lugares disponibles», not total seats.** `setVariantAvailableQuantity` sets *available*
  (stocked = available + reserved), the same semantics as product stock. Corrects the pitch: "lowering below tickets
  sold" cannot happen by construction; the edit refuses negatives only. Daniel's "refuse" call (2026-11-11) holds.
- **D3 · No change to the buyer cap.** PDP, `/checkout` and UCP already read `available_quantity` via
  `ticketQuantityCap`; once tracked, the cap is the seats. Medusa's `reserveInventoryStep` blocks the oversell at
  cart completion. The money-path spec proves it end to end.
- **D4 · Storefront sends quantity for events.** `SellWizard.tsx:1461` sends `quantity` only for `product`; it also
  sends it when the event block is filled. The listing edit form and the MCP listing tools (`capacity` → `quantity`)
  follow the same rule.
- **D5 · «Evento» is a wizard preset, not a new `listing_type`.** It sets `listing_type: 'service'` with the event block
  required and «Lugares disponibles» required. A new type value would ripple through every renderer, filter and UCP
  schema.
- **D6 · A $0 Evento reuses the RSVP system unchanged.** The create route also writes a `marketplace_events` row
  (capacity = seats, same title/venue/start) and stores its slug in the listing's `metadata.rsvp_event_slug`. The PDP
  for a $0 event renders the existing registration form instead of the buy box. Verification, QR tickets, the roster and
  Wall references (by slug) work as they do today. **No re-keying migration** (corrects the pitch). Live rows:
  0 events, 0 registrations.
- **D7 · Eventos leaves the nav, the roster stays.** Remove `eventos` from `SELLER_NAV`. `/shop/manage/eventos` keeps
  the per-event roster and check-in, reached from the event listing's row in the catalog; its create form goes, and
  its «Nuevo evento» sends to `/sell?tipo=evento`. Bare `/shop/manage/eventos` with no events redirects to the catalog.
- **D8 · Comparte moves into Canales.** The three tiles from `ComparteClient.tsx` render inside
  `/shop/manage/canal-propio`. `/shop/manage/comparte` redirects there (target asserted by spec). The engine
  hrefs (`lib/business-plan/engine.ts:216,223,226`) and `e2e/business-plan-engine.spec.ts:50` move with it.
  `ConnectAgentPanel` is dropped from Comparte; it stays in Agentes and `/sell/setup`.
- **D9 · Promoter reports.** Migration: `platform_feedback_author_kind_check` gains `'promoter'` (live CHECK today:
  seller, partner, agent). The orchestrator applies it before S3 merges. The form lives in `/promotor/cerrar`
  and writes `author_kind='promoter'`, `author_id` = the promoter's id, `category` from the existing CHECK
  (feature, bug).
- **D10 · Repos and order.** S1 is backend (D1, D2) and then storefront (D4); the backend deploys first. S2 and S3 are
  storefront-only, plus the D9 migration. No new flags.

## What already exists (reuse, don't rebuild)
<!-- Concrete files / routes / primitives the platform-first reframe surfaced. -->
-

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 A seat limit on every event listing | high |
| 2 | S2.1 «Evento» is one choice in the wizard, free or paid | high |
| 3 | S3.1 Share tools live in Canales | low |
| 3 | S3.2 Promoter field reports are counted | low |

## Deploy order
Storefront only, except two Supabase migrations the orchestrator applies before the code that needs them deploys: S2's RSVP re-key (`marketplace_event_registrations` → listing; re-verify 0 rows at apply time) and S3's `platform_feedback.author_kind` CHECK adding `promoter`. Merge builds the image; deploy with the VM `update.sh`; prove the running container's SHA equals the merge SHA.

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
