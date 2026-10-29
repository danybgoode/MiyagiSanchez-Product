---
epic: share-kit
sprint: 2
title: "The catalog PDF"
risk: high
phase: Shaping
stories_total: 3
stories:
  - id: S2.1
    title: "services/print-pdf on the VM: arm64 image, internal network, origin allow-list, secret, queue"
    as_a: "the platform"
    i_want: "the headless-Chrome PDF renderer running again, beside the app on the VM, safely"
    so_that: "the catalog PDF can be built and the print-edition downloads work again"
    risk: high
    status: done
  - id: S2.2
    title: "Catalog print page: A4, photos, MXN, theme, QR per product"
    as_a: "a merchant forwarding my catalog"
    i_want: "a PDF that looks like my shop: photos, prices in pesos, my colours and a QR on each product"
    so_that: "whoever opens it can order straight from the page"
    risk: low
    status: done
  - id: S2.3
    title: "PDF route + R2 cache + rate limits + Comparte and publish tiles"
    as_a: "a merchant"
    i_want: "to tap «Descargar» and get my catalog PDF in seconds, and send it by WhatsApp"
    so_that: "the PDF is always current without me rebuilding it"
    risk: low
    status: done
---
# Share kit — Sprint 2: The catalog PDF

**Status:** ✅ shipped 2026-10-29 · Storefront #448 → `96b8fe5`, #450 → `9448ab2`, #451 → `ea08414`; root #234 → `a19631c`, #235 → `3de2fe7`. Live: web + print-pdf containers on `ea08414`

## Stories

### Story 2.1 — services/print-pdf on the VM: arm64 image, internal network, origin allow-list, secret, queue
**As** the platform, **I want** the headless-Chrome PDF renderer running again, beside the app on the VM, safely, **so that** the catalog PDF can be built and the print-edition downloads work again.
**Acceptance:** Build `services/print-pdf` for arm64 (Node 24, Debian `chromium`) in `image-arm64.yml`; add it to `infra/oci/docker-compose.yml` on the internal network with no published port; `PRINT_PDF_URL` / `PRINT_PDF_SECRET` in the VM env (orchestrator-owned); `server.js` accepts only our own origins (allow-list), requires `x-internal-secret`, times out, and renders one page at a time with a queue. Memory headroom checked before merge. A spec proves a non-allow-listed URL is refused. Security lens. The print-edition PDF download works on `main` after deploy.
**Risk:** high

### Story 2.2 — Catalog print page: A4, photos, MXN, theme, QR per product
**As** a merchant forwarding my catalog, **I want** a PDF that looks like my shop: photos, prices in pesos, my colours and a QR on each product, **so that** whoever opens it can order straight from the page.
**Acceptance:** `/mx/s/[slug]/catalogo/imprimir`, `noindex`, unlinked, built from the S1.1 model: A4 print CSS, cover with logo and name, a product grid with photo, name, price and a QR to its `mschz.org` link, the shop's WhatsApp and link on the last page. Public data, so no secret.
**Risk:** low

### Story 2.3 — PDF route + R2 cache + rate limits + Comparte and publish tiles
**As** a merchant, **I want** to tap «Descargar» and get my catalog PDF in seconds, and send it by WhatsApp, **so that** the PDF is always current without me rebuilding it.
**Acceptance:** `/api/sell/catalogo/pdf` (and a public per-shop download URL for sharing) renders through `renderPrintPdf` on a cache miss and stores in R2 keyed by shop + latest product `updated_at` + theme; a hit streams from R2 with no render; rate-limited per shop and per IP; errors show «No pudimos preparar tu PDF. Inténtalo en un minuto.». A «Catálogo PDF» tile in Comparte and on prompt-to-shop's publish screen; `share_catalog_pdf` fires once.
**Risk:** low

## Shipped

- **PRs:**
  - Storefront #448: the renderer, print page, PDF route, tiles.
  - #450: renders in time, prints JPEG photos on white, never caches a PDF with a missing photo.
  - #451: a hotfix (an unimported helper).
  - Root #234: a failed image pull fails the deploy.
  - Root #235: the renderer container, the secret-parity check, the per-service health paging.
- **Every PR was reviewed:** the fresh `verifier` (repeat rounds until clean), plus codex general and security on gpt-6-luna @ xhigh on the final tip. agy was out of quota and vibe stalled, so codex ran both passes. CodeQL found an SSRF-shaped navigation, fixed by `allowedPageUrl`.
- **Env (Daniel's one-time approval):** `PRINT_PDF_SECRET` was generated on the VM, never in argv or output. It sits in `web.env` (with `PRINT_PDF_URL`) and in `print.env` (0600, with `PRINT_PDF_ASSET_ORIGINS` = the R2 public origin). `web.env` was backed up first. **Add `print.env` and the two new `web.env` lines to the password manager.**
- **Budget (Daniel: "fit inside"):** print-pdf has 512m / 0.2 CPU. Postgres went from 0.5 to 0.4 CPU, and web from 0.55 to 0.45.

### What went wrong on the way (and what now catches it)
1. **The first S1 deploy redeployed the old image.** `update.sh` swallowed a failed pull. Root #234 now stops the deploy on a failed pull. A containerd ingest stalled at 125 MiB, and Daniel cleared it.
2. **Every catalog PDF timed out at 45 s.** Two causes:
   - The print page loaded the app shell, and two `blob:` requests never let the page reach network idle.
   - WebP photos were stored losslessly: 12.6 MB and 24 s inside `page.pdf()`.

   Fix (#450): page scripts off, wait for `load`, JPEG photos. The renderer refuses a stuck page within its 45 s budget.
3. **#450 shipped a call to an unimported helper.** Every PDF failed for about 30 minutes. The shell had no harness, and `node --check` only parses. Two guards now catch it: an import-coverage test in `guard.test.js`, and `no-undef` on `services/**`. The hotfix was run end to end against the live print pages *before* opening.

### Verified live (agent, production, 2026-10-29)
- `GET /api/catalogo/el-manchon/pdf`: 200 `application/pdf`, 1.59 MB. The first render took 31 s (the renderer logged 27 s, 0 missing images); the second download came from the R2 cache in 4.7 s, byte-identical (smoke step 4 ✅).
- `angela`: 79 KB. The render took 20 s; the cached copy returned in 1.2 s.
- The PDF content was checked page by page on the same build: a cover with the shop name, description and count, then A4 sheets of 6 products, each with photo, MXN price and QR (smoke step 2's content ✅).
- The renderer peaks at 87 MiB of its 512 MiB. Containers on the VM: `web` and `print-pdf` on `ea08414`. `print-pdf` has no published port and is on the `miyagi` network only.
- **Owed to Daniel:**
  - Step 1: admin «Descargar PDF» on a print edition. It needs an admin session; the same renderer path is proven.
  - Step 2: the signed-in Comparte tile.
  - Step 3: a phone scan of a QR.
  - Step 5: edit a price and check that a new PDF renders.
- **Follow-ups:**
  - A cold render is 17–31 s on 0.2 CPU, of which Chromium's launch is 5–7 s.
  - Cloudflare-only origin ingress: the rate-limit IP can be chosen by a client that bypasses Cloudflare. Daniel's call.
  - Orphaned R2 PDFs for paused shops.
  - `/api/sell/*` picks the user's oldest shop.
  - Security-path globs for `lib/image-variant.ts` and `services/print-pdf/**` in `scripts/review-config.json`.
  - `document` scoped to the evaluate callback in the lint globals.

## Sprint QA
- **api specs:** renderer allow-list refusal; PDF route cache hit (no render) vs miss; rate limit; two-shop scoping on the print page
- **browser smoke owed:** yes, to Daniel: the walkthrough below
- **review:** S2.1 is shared infra: fresh pr-reviewer + codex cross-family pass + the security lens
- **infra:** the renderer verified on the VM after deploy (one real render in the logs)
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. (admin) Open a print edition in https://miyagisanchez.com/admin/print and tap «Descargar PDF»
   → a PDF downloads again (it returned 503 since 10-16)
2. On a phone, open https://miyagisanchez.com/shop/manage/comparte and tap «Descargar» on «Catálogo PDF»
   → «Preparando tu PDF…», then an A4 PDF with your photos, prices in MXN and colours
3. Scan a product's QR in the PDF
   → it opens that product
4. Download it again without changing anything
   → it arrives at once (served from the cache)
5. Edit a product's price, then download again
   → the new price is in the PDF

If any step fails, note the step number + what you saw — that's the bug report.
