---
status: scaffolded   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Shaping       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: envia-byo-connect
title: "BYO Envía connect"
area: 04-shipping-and-delivery
risk: high
type: feature
sprints_total: 3
stories_total: 11   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 90   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 20    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 120
quote_basis: "M, n=1, wide"
hypothesis: "We believe that letting a merchant connect their own Envía account in a few guided steps will let small shops print real labels, because today Envía is off and only hand-picked shops ride ours. We'll know when connected shops print labels and get tracking with no platform money spent."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: null   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A Mexican merchant who ships parcels and wants carrier labels and tracking without the platform in the middle of their shipping money"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist); funded as E3 of the T1 review — it makes «vende, cobra y envía» true without the platform funding shipping"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 12      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: BYO Envía connect

> **Area:** 04-shipping-and-delivery · **Risk:** high · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/envia-byo-connect.md`](../../00-ideas/seeds/envia-byo-connect.md)
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
A Mexican merchant who ships parcels connects their own Envía account in Envíos settings, the way they connect
Mercado Pago: a three-step guide, paste the key, «Probar conexión», «Conectada ✓». From then on their buyers get live
carrier quotes from the merchant's own rates, labels are paid from the merchant's own Envía balance, and tracking
arrives on its own. The platform never holds or fronts shipping money, so «vende, cobra y envía» becomes true without
us funding Envía. This builds the hybrid model Daniel approved in the
[BYO Envía spike](../../00-ideas/seeds/spike-envia-byo.md) on 2026-07-08.

## Platform-first note
Envía is fully integrated in Medusa (client, fulfillment provider, quote/label routes, tracking webhooks, the pure
kill-switch seam) and off. The per-seller credential is commerce data, so it lives in Medusa as an
`envia_connection` model on the seller module, mirroring the Mercado Libre connection, **never** in seller
`metadata` (which reaches API surfaces) and never in Supabase. The one new decision point is a pure credential
resolution seam extending `lib/envia-killswitch.ts`.

## What already exists (reuse, don't rebuild)
- `apps/backend/src/modules/fulfillment-envia/envia-client.ts` (`quoteShipments`, `createShipment`, `mapEnviaError`; `apiKey()` reads `ENVIA_API_KEY`): gains a per-call token + environment
- `apps/backend/src/modules/fulfillment-envia/service.ts`: receives the resolved credential
- `apps/backend/src/lib/envia-killswitch.ts` (`enviaKillGate`, fallback messages): extended into the resolution seam
- Comp-grant: `seller.metadata.envia_grant`, `api/internal/sellers/[id]/grant`, frontend `lib/envia-grant.ts`, admin tenants: unchanged tier; the test-shop toggle follows its pattern
- `apps/backend/src/modules/mercadolibre/_utils.ts` (`encryptToken` / `decryptToken`, AES-256-GCM): hoisted to a shared backend lib
- The Mercado Libre connection model in `modules/mercadolibre/models`: the `envia_connection` shape
- Routes: `store/envia/rates`, `sellers/[slug]/checkout-options`, `carts/[id]/start-checkout`, `sellers/me/orders/[id]/ship`; `lib/ml-fulfillment-apply.ts`; `lib/profit-ledger-write.ts` (`parseEnviaLabelCost`)
- Tracking: frontend `app/api/webhooks/envia` → backend `store/envia/tracking-update` (internal secret)
- `app/(shell)/shop/manage/settings/_sections/Envios.tsx`: hosts the connect card
- prompt-to-shop S5.1 delivery chooser (`/sell/armar/cobros`): gains the Envía option

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 `envia_connection` model + shared AES-GCM lib + Medusa migration | high |
| 1 | S1.2 Validate-then-save and disconnect routes, write-only, rate-limited | high |
| 1 | S1.3 Pure credential resolution seam + truth-table spec | high |
| 1 | S1.4 Admin «Tienda de prueba» toggle + sandbox environment | high |
| 2 | S2.1 `envia-client` per-call token + environment; quote and checkout-options threaded | high |
| 2 | S2.2 Label path, fulfillment provider and profit ledger threaded; legacy frontend path retired | high |
| 2 | S2.3 Webhook registration at connect/disconnect + per-connection receiver auth + surcharge notice | high |
| 2 | S2.4 es-MX error mapping + manual-ship fallback | high |
| 3 | S3.1 Envíos connect card with the three-step guide | low |
| 3 | S3.2 «Paquetería con tu cuenta Envía» in the prompt-to-shop delivery chooser | low |
| 3 | S3.3 Agent parity specs + the connect deep link in the agent setup sheet | low |

**Decisions at plan time (Daniel, 2026-10-27):** no flag (supersedes the spike's `shipping.envia_byo_enabled`;
rollback is `git revert`); Envía sandbox keys only for shops an admin marks as test shops, whose labels say PRUEBA;
appetite M.

**The money rule (one pure function, spec-locked):** connected, decryptable, environment-allowed seller token →
the seller's account; else the platform key only if `shipping.envia_enabled` is ON or the shop is comp-granted; else
no Envía (arranged delivery / Correos / manual). A failing seller token is **never** retried on the platform key.

## Deploy order
1. **Backend first.** S1.1's Medusa migration ships with the backend image; the locking pass confirms how Medusa
   migrations run on the Oracle VM deploy before S1 merges (orchestrator-owned).
2. A Medusa migration is not a Supabase migration: no `supabase db push`, nothing applied from a builder role.
3. Frontend after the backend routes are live (the settings card calls them through a proxy).
4. Each sprint merges to `main`, both arm64 images build, then
   `ssh -i ~/.ssh/panfleto_oci ubuntu@159.54.158.4 /opt/miyagi/infra/oci/update.sh`. Verify on `main` after deploy.
5. S3.2 needs prompt-to-shop S5.1 merged; if it isn't yet, S3.2 waits and the epic says so.

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
