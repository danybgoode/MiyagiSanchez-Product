---
status: in-progress  # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Building       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
locked_at: "2026-10-28T23:09:50Z"
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

## Architecture lock (2026-10-28, against storefront `origin/main` 78e73d2 and live data)

Builders **cite** these by number. Where a decision corrects the sprint docs, the correction is the contract.

**Corrections the live system made to the scope (said out loud)**
- **The data seam stops at 20 products.** `getShopListings` calls `/store/sellers/:slug/products` with no `limit`; the
  backend defaults to 20 (cap 50). Live today the largest shop has 16 published products (`el-manchon`), so nobody is
  truncated yet — the 21st product would silently vanish from `/tienda`, the sitemap, the story image and every
  surface of this epic. Fixed in S1.1 (D2).
- **"Paused, draft, deleted and private products excluded" is already true upstream**, and the model adds no second
  rule (D1). "Private" in the scope means a preview-private *shop*, which 404s as a whole.
- **The publish screen is not `/sell/armar/listo`.** prompt-to-shop S5.2 shipped it as
  `app/(shell)/p2s/_components/PublishedMoment.tsx` (rendered by `KeptShop.tsx`). It is merged, so S1.3 and S2.3 add
  their tiles there.
- **There is no product `updated_at` to key the PDF cache on.** The backend's field list for the seller-products route
  omits it, and adding it would be a backend change for a weaker key. The cache key is a hash of the rendered model
  (D15) — any visible change (price, photo, name, colour, number) makes a new PDF.
- **The compose file and `update.sh` live in THIS repo** (`infra/oci/`), not the storefront. S2.1 is two PRs: the
  storefront (service + image) and the root (compose + `update.sh`), merged storefront first.
- **WhatsApp numbers are rare.** None of the seven largest live shops has `whatsapp_cta` on, and all seven are
  unclaimed, so «Comprar» is the common case today, not the fallback.
- **The catalog is Mexico-only** (D5). The order link's `52` prefix and the es-MX copy are wrong for a US shop.

**Data**
- **D1 — One seam, already filtered.** The model is built from `getShopListings(slug)` (the shop's own channel — the
  same read `/tienda` uses on every channel), never `getMarketplaceShopListings`. Visibility is enforced where it
  already lives and is imported, not restated: the backend route returns `status: published` only, drops
  `isHiddenCatalogProduct`, and 404s a seller `sellerRowEnforcement` does not admit; `getShopListings` drops print
  placements; `resolveShopPresentation` refuses a preview-private shop and a market mismatch. Owned-channel-only
  products are included — it is the merchant's own catalog.
- **D2 — `getShopListings` pages.** It requests `limit=50` and follows `offset` until `count` is reached (the backend's
  own `take: 2000` bounds it). Same `unstable_cache` key and tags. A failed page after the first returns what was read
  plus a `console.error`, never a silent partial presented as complete — the caller gets the same array type, so the
  log is the signal.
- **D3 — The merchant's WhatsApp number has one definition.** Pure `shopWhatsAppNumber(metadata)` in
  `lib/share-kit/whatsapp.ts`: `settings.checkout.whatsapp_cta ? (settings.theme.social.whatsapp ||
  settings.checkout.phone || null) : null`. The two existing copies (`ListingRenderer.tsx:303`,
  `lib/trust-inputs.ts:75`) import it. Number normalization (digits only, `52` prefixed unless present) moves out of
  `SellerTrustCard.whatsappUrl` into the same file as `whatsappDigits(raw)`, and `SellerTrustCard` imports it.
- **D4 — The order action.** `isShopClaimed(shop)` **and** a number ⇒ «Pedir por WhatsApp» →
  `https://wa.me/<digits>?text=` «Hola, quiero pedir "<title>" (<price>): <product short link>». Otherwise «Comprar» →
  the product page. An unclaimed shop is always «Comprar» (the PDP already shows it contact-only, `lib/claim.ts`).
- **D5 — Mexico shops only.** `readPublicSellerMarket(shop)?.market_code === 'mx'`, else the catalog, print page, PDF
  and feed 404 and Comparte shows no catalog tiles. US share kit is not in this epic.
- **D6 — The pure model.** `lib/share-kit/catalog.ts` exports `buildCatalogModel({ shop, listings })` → `{ shop: {
  slug, name, logoUrl, description, accent, accentText, whatsapp: digits | null, claimed }, links: { catalog,
  catalogShort, shop, pdf, feed }, items: [{ id, title, description, imageUrl | null, priceCents | null,
  priceLabel, url, shortUrl, order: { kind: 'whatsapp' | 'buy', href } }] }`. No `server-only`, no `next/*` imports,
  so the `api` Playwright project unit-tests it (prompt-to-shop's pure specs live in `e2e/` the same way). URLs are
  absolute on `PLATFORM_ORIGIN`: catalog `…/mx/s/<slug>/catalogo`, product `listingTarget(id)`, short links on
  `SHORTLINK_ORIGIN` (`/s/<slug>/catalogo` and `/l/<id>` — both passthrough prefixes in `lib/shortlink.ts`). Price
  label is `formatPrice(listing, 'es-MX')` («Precio a consultar» when null).
- **D7 — Two-shop proof.** A spec feeds shop A's listings plus a stray listing of shop B and asserts the model
  contains no item whose `shop_id`/`shop.slug` is not A's — the model drops any listing whose `shop.slug` differs
  from the shop it is built for (a defence in depth against a seam regression, and the thing the spec mutates).

**The catalog page (S1.2)**
- **D8 — Routes, mirroring `/tienda`.** `app/(shell)/mx/s/[slug]/catalogo/page.tsx` (`market: 'mx'`),
  `app/(shell)/s/[slug]/catalogo/page.tsx` (unprefixed marketplace host), `app/(shell)/catalogo/page.tsx` (owned host,
  `resolveRequestShopPresentation`, shop from the unspoofable `x-miyagi-shop-slug` header). One body:
  `app/(shell)/_shop-sections/CatalogBody.tsx`. It is a share destination, not a nav section: no `navSections` gate.
  `export const revalidate = 120`. `catalogo` joins `MARKETPLACE_SHOP_TAILS` in `lib/public-read-routing.ts` so the
  edge caches it like `/tienda`.
- **D9 — Weight.** Server component, zero client islands in S1 (plain anchors). Photos through
  `lib/image-loader.ts` (`/api/img`, same origin). OG image from `generateMetadata`: the shop logo, else the first
  photo. Empty state is the seed's: «Esta tienda todavía no tiene productos publicados.» + «Ver la tienda».

**Comparte and publish (S1.3)**
- **D10 — QR.** `shopQrPlan(slug, target)` gains `target: 'shop' | 'catalogo'`; `/api/sell/shop/qr?target=catalogo`
  encodes `mschz.org/s/<slug>/catalogo`. Anything else for `target` is `shop`. Still seller-session scoped.
- **D11 — Tiles.** A «Catálogo» `Card` in `ComparteClient` (copy, WhatsApp via `buildWhatsAppShareLink`, QR download)
  and the same three actions in `PublishedMoment`. Each tap: `pushAnalyticsEvent('share_catalog_link', { channel })`
  (no dedupe key — once per tap) and the existing `guide.share_done` write. Iconoir, no emoji.

**The renderer (S2.1) — shared infra, security lens**
- **D12 — Image.** `services/print-pdf` on `node:24-bookworm-slim` + Debian `chromium`; a second job in the storefront's
  `image-arm64.yml` pushes `ghcr.io/danybgoode/miyagisanchez-print-pdf:<sha>` (+ `:main` on main), path-filtered so a
  web-only merge does not rebuild it.
- **D13 — Placement.** Root `infra/oci/docker-compose.yml` gains `print-pdf` on the `miyagi` network only (never
  `edge`, no `ports:`), `mem_limit: 768m`, `cpus: 0.2` (the CPU caps stay under the box's 2 OCPUs), `env_file:
  [./print.env]`. `update.sh` resolves its digest like the other two (`PRINT_PDF_IMAGE`, pin-able) and waits for its
  `/health`. Web reaches it at `PRINT_PDF_URL=http://print-pdf:8080`.
- **D14 — `server.js` hardening.** (a) `x-internal-secret` compared with `crypto.timingSafeEqual`; empty secret ⇒
  every call 401. (b) The top-level URL's origin must be in `PRINT_PDF_ALLOWED_ORIGINS` (comma list, default
  `https://miyagisanchez.com`), else 403 without launching Chromium. (c) Request interception: every subrequest whose
  origin is not allow-listed is aborted (`data:`/`blob:` allowed), and redirects are re-checked — so a merchant's image
  URL can never make Chromium fetch an internal host. (d) One render at a time; up to 4 waiting; a fifth gets 503
  `busy`. (e) A 45 s hard timeout per render, browser always closed. The allow-list decision is a pure exported
  function with a `node:test` spec beside it (the service has no Playwright). Secrets: `PRINT_PDF_SECRET` in both
  `web.env` and `print.env` — a production secret, so it is one focused question to Daniel before S2.1 merges, with
  the VM memory headroom read (the classifier refuses agent production reads).

**The PDF (S2.2, S2.3)**
- **D15 — Print page.** `app/(shell)/mx/s/[slug]/catalogo/imprimir/page.tsx`: `robots: noindex`, `dynamic =
  'force-dynamic'` (a render must never read a CDN-stale page), unlinked, built from the D6 model. A4 `@page`, cover
  (logo, name, accent), a grid with photo, name, price and a QR to the product short link (server-rendered SVG via
  `qrcode`, no network), last page with the shop link and WhatsApp. Photos via `/api/img`, so every subrequest is the
  allow-listed origin.
- **D16 — PDF routes.** `GET /api/catalogo/[slug]/pdf` (public, the shareable URL) and `GET /api/sell/catalogo/pdf`
  (seller session ⇒ own slug ⇒ the same handler). Key: `catalog-pdf/<slug>/<sha256(JSON(model) + TEMPLATE_VERSION)>.pdf`
  in the public images bucket. Hit ⇒ stream from `R2_PUBLIC_URL`, no render, no rate-limit charge. Miss ⇒ rate limits
  (`catalog_pdf_shop` 6/h per slug, `catalog_pdf_ip` 10/h per IP), `renderPrintPdf`, `uploadToR2`, stream. Any failure
  ⇒ 503 + «No pudimos preparar tu PDF. Inténtalo en un minuto.». `checkRateLimit` fails open without Upstash, so the
  renderer's queue (D14d) is the hard bound; the rate limits are the polite one.
- **D17 — Tiles.** «Catálogo PDF» in Comparte and `PublishedMoment`: «Descargar» (fetch → blob, «Preparando tu PDF…»
  while waiting, the error copy on failure) and «Compartir por WhatsApp» (the public PDF URL).
  `share_catalog_pdf` once per tap.

**The Meta feed and the agent (S3)**
- **D18 — Feed.** Pure `buildMetaFeed(model)` in `lib/share-kit/meta-feed.ts` → `{ csv, included, excluded: { no_photo,
  no_price } }`; columns re-confirmed against Meta's spec page when S3 starts. `id` = Medusa product id (stable).
  Route `app/api/feeds/meta/[slug]/route.ts` accepts `<slug>.csv` only, `Cache-Control: public, s-maxage=3600`, 404
  for an unclaimed or non-MX shop.
- **D19 — Agent.** MCP `get_share_kit` through `resolveToolShop` (seller credentials ignore any slug argument — the
  existing parity rule — so another shop is unreachable by construction), added to `MCP_SELLER_TOOLS` and
  `SELLER_MCP_TOOLS`. One small client island on the catalog page fires `catalog_order_whatsapp` /
  `catalog_order_buy`; `pushAnalyticsEvent` already skips white-label hosts, so owned-host taps are not counted (named,
  accepted).

**Process**
- **D20 — No migration, no flag, no new npm dependency.** `qrcode` and `puppeteer-core` are already in the trees.
- **D21 — Routing.** The orchestrator (Claude Opus) builds all three sprints in place in storefront worktrees
  (`~/dobby/.worktrees/sk-s1…s3`); one PR per sprint, stacked `feat/share-kit` → `-s2` → `-s3`, plus the root infra
  PR for S2.1. Review: `review-route.mjs` external pass(es) **and** the fresh `verifier` on every PR (high-risk epic).

### Build contract — S1 · The catalog link
D1–D11. Files: `lib/share-kit/{catalog,whatsapp}.ts`, `lib/listings.ts` (D2 only), `lib/share-link.ts` (D10),
`SellerTrustCard.tsx` / `ListingRenderer.tsx` / `lib/trust-inputs.ts` (D3 imports only), the three `catalogo` routes +
`CatalogBody.tsx`, `lib/public-read-routing.ts`, `app/api/sell/shop/qr/route.ts`, `ComparteClient.tsx`,
`PublishedMoment.tsx`. Specs: model + two-shop + order link + pagination (pure, `api`), catalog server HTML on a live
fixture shop (`api`), QR plan targets. Each observed red under a mutation.

### Build contract — S2 · The catalog PDF
D12–D17. Storefront: `services/print-pdf/*`, `image-arm64.yml`, the print page, both PDF routes,
`lib/share-kit/catalog-pdf.ts` (pure key + plan), `lib/ratelimit.ts` (two keys), tiles. Root: `infra/oci/{docker-compose.yml,update.sh}`.
Specs: allow-list refusal (`node:test` in the service), cache key changes with the model and not otherwise, hit ⇒ no
render (injected deps), rate-limit ordering, print page scoped to its shop. Gate before merge: Daniel sets the secret.

### Build contract — S3 · Instagram and WhatsApp catalogs
D18–D19. `lib/share-kit/meta-feed.ts`, the feed route, the «Instagram y WhatsApp» tile, `get_share_kit` in
`app/api/ucp/mcp/route.ts` + `lib/ucp/capabilities.ts` + `lib/setup-spec.ts`, the order-tap island. Specs: columns,
price format «199.00 MXN», exclusions by reason, CSV escaping, feed route 404s, MCP unauthenticated refusal.

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
