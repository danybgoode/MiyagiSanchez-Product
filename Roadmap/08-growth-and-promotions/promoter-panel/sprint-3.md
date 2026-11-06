---
epic: promoter-panel
sprint: 3
title: "Sus productos"
risk: low
phase: Locking architecture
stories_total: 2
stories:
  - id: S3.1
    title: "Camera-first product cards"
    as_a: "a promoter at a counter"
    i_want: "to photograph a product, set the price and save it"
    so_that: "three products take a couple of minutes"
    risk: low
    status: planned
  - id: S3.2
    title: "The import paths in «Sus productos»"
    as_a: "a promoter"
    i_want: "step 2 to follow where the merchant already sells"
    so_that: "a Shopify or Tiendanube merchant needs no typing"
    risk: low
    status: planned
---
# El panel del promotor: open a shop in one visit, manual-first, in four steps — Sprint 3: Sus productos

**Status:** ⬜ not started

## Stories

### Story 3.1 — Camera-first product cards
**As** a promoter at a counter, **I want** to photograph a product, set the price and save it, **so that** three products take a couple of minutes.
**Acceptance:** «Tomar foto» is a visible button that opens the phone camera. «Elegir de la galería» opens the gallery. Name, price, stock and category save a product. «Llenar los datos con la foto» is an optional link. The image-URL box and the origin fields are gone. A counter shows «{n} productos en su tienda».
**Risk:** low

### Story 3.2 — The import paths in «Sus productos»
**As** a promoter, **I want** step 2 to follow where the merchant already sells, **so that** a Shopify or Tiendanube merchant needs no typing.
**Acceptance:** Shopify → the address field and «Buscar sus productos». Tiendanube / WooCommerce / Big Cartel → «Subir el archivo» with «Cómo descargarla». Mercado Libre → cards plus «se conecta después». Above 150, the migration line shows. Cards are always available below an import.
**Risk:** low

## Build contract
Cite the epic README's locked decisions (D1–D12). Escalate per WAYS-OF-WORKING → *Escalate, don't guess*.

## Sprint QA
- **api spec:** e2e/promoter-panel-products.spec.ts (the path chosen per platform answer; no origin fields sent)
- **browser smoke owed:** yes, to Daniel: three photos on his phone, and one Shopify import into a test shop
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge; every new spec seen red under a mutation

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. In https://miyagisanchez.com/promotor/cerrar, open a test shop whose «¿Vende hoy en otra plataforma?» is «No»
   → step 2 shows «Tomar foto» as a big button
2. Tap «Tomar foto», take a picture, set a price and «Guardar producto» three times
   → «3 productos en su tienda»
3. Open another test shop with «Shopify» and type a public Shopify store address
   → «Encontramos {n} productos», then «Agregar los {n} a su tienda» adds them (150 at most)

If any step fails, note the step number + what you saw — that's the bug report.
