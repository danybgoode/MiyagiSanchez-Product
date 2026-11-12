---
status: shipped   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Shipped       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: checkout-trust-hardening
title: "Checkout trusts nothing the caller names"
area: 02-checkout-and-payments
risk: high
type: bug
sprints_total: 1
stories_total: 4   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: null   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: null    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: null
quote_basis: null
hypothesis: "Checkout still charges amounts the buyer's request names: a shipping price, a $0 line, a reused offer. Making the server re-derive or sign each of them keeps every peso of a sale correct. We'll know when a forged shipping price, a $0 cart and a second checkout on one offer are all refused."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: null   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A merchant whose buyer pays through Miyagi Sánchez checkout, and who must never absorb a forged shipping price or a discount they never agreed to"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet; funded because the holes are live money defects found in review on 2026-11-11 and Daniel said carry on, ship it all"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 19      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: Checkout trusts nothing the caller names

> **Area:** 02-checkout-and-payments · **Risk:** high · **Class:** Bug · **Scope seed:** [`00-ideas/seeds/checkout-trust-hardening.md`](../../00-ideas/seeds/checkout-trust-hardening.md)
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
Checkout still charged amounts the buyer's request named. Backend #231 closed the offer amount on 2026-11-11; this closes shipping price, $0 items, offer reuse, and the review gap that let the charge route skip the security lens. See the [pitch](../../00-ideas/seeds/checkout-trust-hardening.md).

## Architecture lock (2026-11-11)

- **D1 · Signed rates, no new secret.** HMAC-SHA256 under a key DERIVED (HKDF, label `shipping-quote-v1`) from a backend server secret already on the VM; confirm which one `medusa-config` reads. No VM env change.
- **D2 · Deploy together.** The backend requires the signature, so backend and storefront merge back-to-back and go out in ONE `update.sh`. A checkout page opened before the deploy gets «Vuelve a elegir el envío.» once.
- **D3 · The $0 refusal sits on the FINAL amount** start-checkout charges, after offer/support/rental/coupon/bundle resolution. Server-built carts keep their rules.
- **D4 · Offer reservation** uses the existing `checkout_session_id`/`checkout_expires_at` columns if they suffice (no migration), as a conditional update that is read back.

## Platform-first note
<!-- Does the platform's own system of record already model this? Which primitive backs it?
     (This project's AGENTS.md data-ownership rule.) -->

## What already exists (reuse, don't rebuild)
<!-- Concrete files / routes / primitives the platform-first reframe surfaced. -->
-

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | Server-derived amounts | high |

## Deploy order
<!-- Backend-first? Frontend degrade gracefully? Preview vs prod. -->

## Definition of Done (epic)
- [x] All sprints merged to `main` + smoke-tested (gaps stated — `node scripts/owed-ledger.mjs` counts what is still owed)
- [x] Each `sprint-N.md` has its smoke walkthrough (real URLs)
- [x] This README marked ✅; every sprint status ticked with commit refs
- [x] `RETROSPECTIVE.md` written
- [x] Product poster (`Roadmap/README.md`) updated
- [ ] Team memory + `MEMORY.md` index updated
- [x] Durable learnings promoted to `Roadmap/LEARNINGS.md` (dedupe — sharpen, don't append)
- [ ] **Kill-switch (only if one was planned at refining — Stage 6b):** the flag slice shipped, the flag
      exists **in Golden Frijoles, in every env**, with the stated polarity, **and its switch is set there** —
      `frijoles flags get <key>` must print `on vN` or `off vN` in its PRODUCTION row (a bare `off` with no version
      means nothing is served there, so the app runs on its own built-in default). A newly synced flag goes live as written in its file; a sync never switches an existing one. *Verify-only — not a new gate; whether a high-risk epic needs one
      is decided at refining, not here.*
- [x] Feature branch deleted; **this README's frontmatter `status: shipped`** (the SSOT — the board & Notion derive from it; run `node scripts/build-order.mjs`)
