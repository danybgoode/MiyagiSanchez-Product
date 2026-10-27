---
status: scaffolded   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Shaping       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: share-kit
title: "Share kit"
area: 03-selling-and-shops
risk: high
type: feature
sprints_total: 3
stories_total: 9   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 92   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 20    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 120
quote_basis: "M, n=1, wide"
hypothesis: "We believe that giving a merchant a catalog link, a catalog PDF and an Instagram and WhatsApp feed will bring them more orders from where they already sell, because micro-merchants sell by WhatsApp and Instagram and today they can only share a shop link. We'll know when shops use each share and those visits order."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: null   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A Mexican micro-merchant who sells mostly through WhatsApp chats, Instagram and in person, and shares their products there by hand"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist); funded as E4 of the T1 review — it fills the share tiles of the prompt-to-shop publish step"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 11      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: Share kit

> **Area:** 03-selling-and-shops · **Risk:** high · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/share-kit.md`](../../00-ideas/seeds/share-kit.md)
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
A Mexican micro-merchant's customers are in WhatsApp chats and on Instagram. This epic gives them three ways to share
their catalog there, each scoped to their shop: a one-scroll **catalog link** with «Pedir por WhatsApp» on every
product, a forwardable **catalog PDF** with photos, MXN prices, their colours and a QR per product, and a **Meta feed**
that fills their Instagram Shopping and WhatsApp Business catalogs. The prompt-to-shop publish screen offers the first
two. Rebuilt from Despacho Bonsai's early versions, whose PDF listed every shop's products.

## Platform-first note
Read-only on Medusa: every surface reads one shop's listings through `getShopListings` and the storefront's own
visibility rules, never a global product list. No new table. The one infra change is running the existing
`services/print-pdf` headless-Chrome renderer (deleted with GCP on 2026-10-16) as a container on the Oracle VM, which
also restores the print-edition and rate-card PDF downloads.

## What already exists (reuse, don't rebuild)
- `lib/listings.ts` (`getShopListings`): the only data source
- `app/(shell)/mx/s/[slug]/*` and `app/(shell)/s/[slug]/ChannelLayout.tsx`: `/catalogo` beside `tienda`, `colecciones`, on every shop channel
- `lib/share-link.ts` (`buildWhatsAppShareLink`) and `SellerTrustCard`'s `whatsappUrl` normalization: share and order links
- `lib/shortlink.ts` (`shopTarget`, `listingTarget`, `mschz.org`): QR targets
- `qrcode` dependency and the `lib/print-qr.ts` pattern: QR codes
- `services/print-pdf` (Dockerfile, `server.js`) and `lib/print-pdf-client.ts` (`renderPrintPdf`): the renderer
- Callers that come back: `api/admin/print/editions/[id]/pdf`, `api/admin/print/rate-card/pdf`, `api/promoter/rate-card`
- `lib/r2.ts` (`uploadToR2`): the PDF cache
- `app/(shell)/shop/manage/comparte/*`: the new tiles
- prompt-to-shop S5.2 publish screen (`/sell/armar/listo`): catalog and PDF tiles
- `infra/oci/docker-compose.yml`, `update.sh`, `.github/workflows/image-arm64.yml`: the renderer service
- `lib/analytics-events.ts`: share and order taps
- Despacho Bonsai's `lib/catalog-pdf.tsx` and `api/commerce/export`: reference only, nothing ported verbatim

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 Pure catalog view model + WhatsApp order link + two-shop scoping spec | low |
| 1 | S1.2 `/mx/s/[slug]/catalogo` on every shop channel | low |
| 1 | S1.3 Comparte «Catálogo» tile + QR + the prompt-to-shop publish tile | low |
| 2 | S2.1 `services/print-pdf` on the VM: arm64 image, internal network, origin allow-list, secret, queue | high |
| 2 | S2.2 Catalog print page: A4, photos, MXN, theme, QR per product | low |
| 2 | S2.3 PDF route + R2 cache + rate limits + Comparte and publish tiles | low |
| 3 | S3.1 Pure Meta feed builder + exclusion reasons | low |
| 3 | S3.2 `/api/feeds/meta/[slug].csv` + the Comparte guide tile | low |
| 3 | S3.3 MCP `get_share_kit` for seller agents + funnel events | low |

**Decisions at plan time (Daniel, 2026-10-27):** revive `services/print-pdf` on the VM; «Pedir por WhatsApp» to the
merchant's number, else «Comprar»; the Meta feed at a public per-shop URL; appetite M.

**Flag:** none (WAYS-OF-WORKING default); rollback is `git revert`, plus removing the renderer from the compose file.

## Deploy order
1. Sprint 1 is storefront-only.
2. **S2.1 before S2.2/S2.3:** the renderer image builds on arm64, joins the VM's compose stack on the internal network
   (no published port), and `PRINT_PDF_URL` / `PRINT_PDF_SECRET` go into the VM env files (orchestrator-owned; infra
   memory headroom checked first). Verify the print-edition PDF download works on `main` after deploy.
3. Each sprint merges to `main`, the arm64 images build, then
   `ssh -i ~/.ssh/panfleto_oci ubuntu@159.54.158.4 /opt/miyagi/infra/oci/update.sh`.
4. The publish-screen tiles (S1.3, S2.3) need prompt-to-shop S5.2 merged; if it isn't yet, those parts wait and the
   sprint says so.

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
