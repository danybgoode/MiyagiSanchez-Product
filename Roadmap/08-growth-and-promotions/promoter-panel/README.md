---
status: scaffolded   # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Locking architecture # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: promoter-panel
title: "El panel del promotor: open a shop in one visit, manual-first, in four steps"
area: 08-growth-and-promotions
risk: high
type: feature
sprints_total: 4
stories_total: 10   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 90   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 27    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 40
quote_basis: "M, n=3, p25–p75"
hypothesis: "Promoters type the same data twice and can't import a catalog before the claim. Four steps, choices instead of free text, imports and plain copy let them open a shop in one visit. We'll know when promoter-opened shops reach 3+ products on the day they open."   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: "Share of promoter-opened shops with 3+ products on the day they are opened"   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: "A promoter recruited from a street ad, at a merchant's counter with a phone, opening that merchant's shop in one visit"   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: false   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: "No strategy yet (Roadmap/00-strategy/ does not exist); funded because the promoter workspace is the only way the promoter packages get sold, and Daniel found it hard to use on 2026-11-05"   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null   # the score (1–5) a satisfaction_rated answer needs to count as satisfied · null = 4
build_order: 15      # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
---

# Epic: El panel del promotor: open a shop in one visit, manual-first, in four steps

> **Area:** 08-growth-and-promotions · **Risk:** high · **Class:** Feature · **Scope seed:** [`00-ideas/seeds/promoter-panel.md`](../../00-ideas/seeds/promoter-panel.md)
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
A promoter at a merchant's counter types the same data twice, guesses at free-text fields, can't bring in a catalog
until the merchant claims the shop, and leaves the merchant with no proof of payment. This epic turns
`/promotor/cerrar` into «Tu panel de promotor»: four steps, choosing instead of typing, imports for merchants who
already sell online, a receipt the merchant gets on WhatsApp the moment they pay, and copy written for people
recruited on the street. The packages only get sold here.

## Platform-first note
Nothing new is modelled:
- **Leads:** `merchant_relationships` (`current_channels`, `category`, `preferred_channel` and `qualification` already exist with CHECKs).
- **Shops:** an unclaimed Medusa Commerce seller minted by `/api/promoter/shop/setup`.
- **Products:** `createSellerProductViaInternal`, the internal path the promoter listing route already uses.
- **Shopify:** the supply batch `stageShopifyBatch` → `importApprovedItems` with a `resolveSeller` hook naming the target shop.
- **Receipt status:** read live from `marketplace_promoter_attributions` (paid) and `marketplace_promoter_transfers` (pending/approved).

No migration, no new table, no new flag.

## Locked decisions (architecture lock, 2026-11-05 — read against `origin/main` 67433ec and live data)

Live data: all four promoter flags ON in production (`promoter.enabled`, `promoter.transfer_enabled`,
`promoter.private_preview_enabled`, `promoter.activation_crm_enabled`), plus `migrations.connector_enabled` ON.
`merchant_relationships`: 29 rows, all with a linked shop, `category` never filled. Migration SKU: $999 flat, 50% rate,
0 sold.

- **D1 · One guard for writing to a shop.**
  - What: `lib/promoter-shop-access.ts` gains `promoterMayEditShop({ promoter, shop })`. It is true only when the shop is unclaimed (`clerkUserId == null`) AND this promoter opened it (`promoterOpenedShop(sourceUrl, code)`) or holds a `merchant_relationships` row linking it.
  - Where: it gates `/api/promoter/close/listing`, `/api/promoter/close/photo` and both new import routes.
  - Refusal: 403 with «Esta tienda ya es de su dueño. Pídele que agregue productos desde su panel.» for a claimed shop, and a generic 403 otherwise.
  - Unchanged: `promoterMayCloseShop` keeps gating the package close, and self-close stays refused (Daniel).
- **D2 · Shopify import for promoters.**
  - Routes: `POST /api/promoter/import/shopify/preview { shopId, domain }` stages with `stageShopifyBatch(shop, domain)` and returns `{ batchId, total, sample[≤5] }`. `POST /api/promoter/import/shopify { shopId, batchId }` imports.
  - Import: it uses `importApprovedItems` with `resolveSeller: () => ({ sellerSlug: shop.slug, mirrorId: shop.id })` and `targetStatus` from `shopMustStayPrivate` (private until consent), on at most `MIGRATION_FLAT_LISTING_CAP` (150) items in batch order.
  - Gates: `promoter.enabled` + `migrations.connector_enabled` + D1, with a per-promoter rate limit.
- **D3 · File import for promoters.** `POST /api/promoter/import/file { shopId, fileText, fileName }`:
  - It parses with `parseCatalogFile`, normalises each valid row through `normalizePromoterListingContract`, and creates up to 150 products with `createSellerProductViaInternal` + `syncSupabaseListingMirror`, exactly as a typed product.
  - It returns `{ imported, skipped, overCap }`.
  - `HEADER_ALIASES` gains the documented export columns of Tiendanube, WooCommerce and Big Cartel. The builder confirms each platform's header row from its own docs and pins it in a spec fixture.
  - An unreadable file answers 422 with the copy in the seed, never a guess.
- **D4 · The 150 rule (Daniel, 2026-11-05).**
  - Both imports stop at 150 and report `overCap = total − 150`.
  - The panel then says the migration line and offers «Migración desde otra plataforma» in Cobra.
  - The merchant's own panel import stays free and unlimited.
- **D5 · One «El negocio» form, two existing writes.**
  - «Guardar para después» calls the relationship route (create/update) only.
  - «Abrir su tienda» calls the relationship route, then `/api/promoter/shop/setup`, then links them (the existing link path), with the same fields typed once.
  - The routes stay. The form is a single component that feeds both.
- **D6 · Choices from the platform's own lists.**
  - `BUSINESS_SHAPES` («¿Qué vende?»), stored as `category` = the shape key.
  - The catalog categories («Categoría principal»).
  - `PREFERRED_CHANNEL_LABEL` and `QUALIFICATION_LABEL`.
  - Postal code → colonia, with municipio and estado filled automatically, through the existing `/api/checkout/postal-lookup`.
  - «¿Vende hoy en otra plataforma?» uses a closed list in `lib/promoter-panel.ts` (`none, social, mercadolibre, shopify, tiendanube, woocommerce, bigcartel, other`), stored in `current_channels`.
  - WhatsApp is required (E.164 via the existing normaliser).
- **D7 · No origin fields.** «URL de origen» / «Plataforma de origen» are removed from the panel. Typed products send neither. Imported products keep the real source the importer writes.
- **D8 · Products, manual-first.**
  - The camera control is a visible `<label class="btn">` over `<input type="file" accept="image/*" capture="environment">`, plus «Elegir de la galería» without `capture`. It uploads through the existing upload path.
  - The fields are name, price, stock and category.
  - «Llenar los datos con la foto» stays as an optional small link (the S5 photo route, behind D1).
  - The image-URL box is removed.
- **D9 · Step 2's path follows D6's answer:**
  - `shopify` → D2;
  - `tiendanube` / `woocommerce` / `bigcartel` → D3;
  - `mercadolibre` → cards plus the line «se conecta después» (Daniel's c);
  - everything else → cards.
  - Typed cards are always available below an import.
- **D10 · «El recibo del negocio».**
  - Route: `POST /api/promoter/close/receipt { shopId, sku }` (D1's sibling `promoterMayCloseShop`). It returns `{ receiptUrl, whatsappUrl }`, and sends the email to the shop's `merchant_email` when there is one.
  - Link: `receiptUrl` = `/recibo/{token}`, where the token is an HMAC-signed `{ shopId, sku, promoterId, amountCents, issuedAt }` (the existing claim-token signing helper's pattern, its own `purpose`).
  - WhatsApp: `whatsappUrl` = `https://wa.me/{relationship.whatsapp_e164}?text=…` with the seed's message. The promoter sends it from their own phone, at no API cost.
  - Receipt page `/recibo/[token]`, public and `noindex`: it verifies the token and shows amount, option, promoter name and code, and date.
  - Status, read live: Activo when the package attribution is `paid`; Pendiente when a transfer for that shop+SKU is pending or reported; Listo for `setup_gratis` once paid.
  - A tampered or expired token answers 404.
  - The existing activation email (`notifyMerchantCloseReceipt`) stays, with amounts formatted one way (`$2,000 MXN`).
- **D11 · Copy lives in the locales.** One `promotorPanel` block in `locales/es.json` (mirrored in `en.json`) holds every string in the seed's «The copy». Components carry none. The no-cerrar spec extends to it.
- **D12 · The look.** The panel and `/admin/promoter` use `.btn` / `.btn-primary` / `.btn-secondary`, `.card-panel`, `Banner`, real `<label>`s, and a stepper component «1 El negocio · 2 Sus productos · 3 Cobra · 4 Entrégala». The address `/promotor/cerrar` stays.

## What already exists (reuse, don't rebuild)
- **Workspace:** `app/(shell)/promotor/cerrar/{page,PromoterCloseClient,RelationshipStep,ListingStep,PreviewStep}.tsx`.
- **Lead:** `/api/promoter/relationship*`, `lib/preferred-channels.ts`, `lib/relationship-access.ts`, `lib/merchant-stage.ts`.
- **Shop:** `/api/promoter/shop/setup`, `/api/checkout/postal-lookup`, `lib/mx-locations.ts`, `lib/promoter-server.ts` (`resolveTargetShop`).
- **Products:** `/api/promoter/close/listing`, `lib/seller-products.ts` (`createSellerProductViaInternal`), `lib/provisioning.ts` (`syncSupabaseListingMirror`), `lib/promoter-listing-contract.ts`, `lib/preview-consent.ts` (`shopMustStayPrivate`), `/api/promoter/close/photo`.
- **Imports:** `lib/shopify-import-bridge.ts`, `lib/supply-import.ts`, `lib/catalog-import.ts` (`parseCatalogFile`, `HEADER_ALIASES`, `MAX_IMPORT_ROWS`), `lib/migration-estimate.ts` (`MIGRATION_FLAT_LISTING_CAP`).
- **Lists:** `lib/business-shape.ts`, the catalog categories.
- **Access:** `lib/promoter-shop-access.ts`, `lib/promoter-close.ts`.
- **Receipt:** `lib/promoter-close-notify.ts`, `lib/promoter-close-receipt.ts`, `lib/email.ts#sendMerchantCloseReceipt`, the claim-token signer.
- **Look:** `.btn`, `.card-panel`, `components/feedback/Banner`.

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | S1.1 One guard for writing to a shop | high |
| 1 | S1.2 Shopify import into the shop the promoter opened | high |
| 1 | S1.3 File import (Tiendanube, WooCommerce, Big Cartel) | high |
| 2 | S2.1 «El negocio»: one form for the lead and the shop | high |
| 2 | S2.2 The panel copy and the choice lists | low |
| 3 | S3.1 Camera-first product cards | low |
| 3 | S3.2 The import paths in «Sus productos» | low |
| 4 | S4.1 «El recibo del negocio» | high |
| 4 | S4.2 The panel shell: stepper, «Cobra», «Entrégala» | low |
| 4 | S4.3 /admin/promoter on the site's components | low |

## Model routing (stated, per WAYS-OF-WORKING → Epic-mode builds)
- **The orchestrator (Opus 5.5) builds:** S1.1–S1.3 (authorization, imports), S2.1 (lead + shop sequencing) and S4.1 (a public signed page).
- **Sonnet-class builders take:** S2.2, S3.1, S3.2, S4.2 and S4.3, each with a clear acceptance check.
- **Review:** the fresh pr-reviewer and a cross-family pass (Codex gpt-6-luna xhigh, or agy if Codex is capped). Add the security lens on S1 and S4.1.

## Deploy order
Storefront only, one PR per sprint, merged in order. No backend change, no migration. Each sprint deploys with the VM
`update.sh` (Daniel). S1's routes are invisible until S3's UI calls them, so S1 can ship first safely.

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
