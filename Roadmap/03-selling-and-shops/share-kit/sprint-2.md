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
    status: planned
  - id: S2.2
    title: "Catalog print page: A4, photos, MXN, theme, QR per product"
    as_a: "a merchant forwarding my catalog"
    i_want: "a PDF that looks like my shop: photos, prices in pesos, my colours and a QR on each product"
    so_that: "whoever opens it can order straight from the page"
    risk: low
    status: planned
  - id: S2.3
    title: "PDF route + R2 cache + rate limits + Comparte and publish tiles"
    as_a: "a merchant"
    i_want: "to tap «Descargar» and get my catalog PDF in seconds, and send it by WhatsApp"
    so_that: "the PDF is always current without me rebuilding it"
    risk: low
    status: planned
---
# Share kit — Sprint 2: The catalog PDF

**Status:** ⬜ not started

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
