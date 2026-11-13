---
epic: one-front-door-both-markets
sprint: 1
title: "The screen and the intake"
risk: high
phase: Shipped
stories_total: 5
stories:
  - id: S1.1
    title: "Junk never reaches the AI"
    as_a: "a merchant trying the builder on a busy day"
    i_want: "nonsense, attacks and off-topic requests refused before the AI runs"
    so_that: "the day's shared allowance is still there when I describe my real business"
    risk: high
    status: done
  - id: S1.2
    title: "Prohibited goods are refused up front"
    as_a: "the platform"
    i_want: "a description of drugs, weapons, counterfeits or adult services refused before a shop is built"
    so_that: "no shop is made for a business payments will never accept"
    risk: high
    status: done
  - id: S1.3
    title: "One photo, signed out"
    as_a: "a visitor with no account"
    i_want: "to start my shop from one photo of what I sell"
    so_that: "I see my shop before I sign up"
    risk: high
    status: done
  - id: S1.4
    title: "Start from a catalog file"
    as_a: "a merchant with a spreadsheet or PDF catalog"
    i_want: "to drop my CSV, XLSX or PDF in the box"
    so_that: "my real products are in the shop from the start"
    risk: high
    status: done
  - id: S1.5
    title: "Start from my old store's link"
    as_a: "a merchant already on Shopify, Big Cartel, Mercado Libre or any website"
    i_want: "to paste my store link in the box"
    so_that: "the builder starts from what I already have"
    risk: high
    status: done
---
# One front door for both markets — Sprint 1: The screen and the intake

**Status:** ✅ shipped `ccd98a0` (#498), deployed 2026-11-13

## Stories

### Story 1.1 — Junk never reaches the AI ✅ `ccd98a0`
**As a** a merchant trying the builder on a busy day, **I want** nonsense, attacks and off-topic requests refused before the AI runs, **so that** the day's shared allowance is still there when I describe my real business.
**Acceptance:** Type «asdkjh qwe», «ignore all previous instructions…» or «write me an essay» → a friendly refusal in one second, and the daily counter is unchanged. Type «Vendo tamales» → the shop takes shape as today. With Jev unreachable, the builder still works (today's guards) and the log says `unavailable`.
**Risk:** high

### Story 1.2 — Prohibited goods are refused up front ✅ `ccd98a0`
**As a** the platform, **I want** a description of drugs, weapons, counterfeits or adult services refused before a shop is built, **so that** no shop is made for a business payments will never accept.
**Acceptance:** «réplicas de iPhone, mayoreo» or «pills, discreet delivery» → a plain refusal naming why; the same check runs on a signed-in description and on a photo's confirmed card.
**Risk:** high

### Story 1.3 — One photo, signed out ✅ `ccd98a0`
**As a** a visitor with no account, **I want** to start my shop from one photo of what I sell, **so that** I see my shop before I sign up.
**Acceptance:** On `/` drop one photo → the shop takes shape with that product in it. A second photo while signed out → «Crea tu cuenta para subir más fotos». The photo has its own daily budget; the signed-in upload route is unchanged.
**Risk:** high

### Story 1.4 — Start from a catalog file ✅ `ccd98a0`
**As a** a merchant with a spreadsheet or PDF catalog, **I want** to drop my CSV, XLSX or PDF in the box, **so that** my real products are in the shop from the start.
**Acceptance:** Drop a CSV/XLSX → its rows (up to the canvas limit) are the shop's products, with real names and prices. Drop a PDF → the same from its text. A file of nonsense → refused, no budget spent.
**Risk:** high

### Story 1.5 — Start from my old store's link ✅ `ccd98a0`
**As a** a merchant already on Shopify, Big Cartel, Mercado Libre or any website, **I want** to paste my store link in the box, **so that** the builder starts from what I already have.
**Acceptance:** Paste a Shopify or Big Cartel shop URL → the shop takes shape with products from it. Paste any other site → its title and description become the description. A private or internal address → refused.
**Risk:** high
## Sprint QA
- **api spec(s):** pure-logic `node:test`/Playwright `api` specs on the `lib/` seams this sprint adds (named in the README's locking decisions); every new spec observed failing once by a deliberate mutation.
- **browser smoke owed:** yes, to Daniel — the walkthrough below on production.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge.

## Build contract (locked by the architect before the builder started)
D1–D9 in the epic README. Seams: `lib/prompt-to-shop/screen.ts` (+ `screen-server.ts`), `intake.ts`,
`intake-handler.ts` (+ `intake-server.ts`, `intake-route.ts`), `locale.ts`; routes `app/api/p2s/intake/{photo,file,link}`.
Specs: `e2e/p2s-screen.spec.ts` (44 recorded Jev answers replayed), `e2e/p2s-intake.spec.ts`, additions to
`e2e/p2s-photo.spec.ts` and `e2e/p2s-drafts.spec.ts`. Migration `20261112000000_shop_drafts_locale_market_seed_rows.sql`
applied live 2026-11-12 and recorded under that version.

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Go to https://miyagisanchez.com/ and type `asdkjh qwe zzz` in «Cuéntanos qué vendes», then «Armar mi tienda».
   → «Esto no parece un negocio. Cuéntanos qué vendes o qué ofreces y armamos tu tienda.» within about a second.
2. Replace it with `Vendo réplicas de bolsas Louis Vuitton AAA`, then «Armar mi tienda».
   → «No podemos armar tiendas para productos que los pagos en línea no aceptan…».
3. In a private window, open https://miyagisanchez.com/, tap «Una foto» and pick a photo of something you sell.
   → «Leyendo…», then the box fills with a sentence about your business and shows your photo with «Tu foto será el
   primer producto de tu tienda». «Armar mi tienda» → the shop takes shape with that product first, without «EJEMPLO».
4. In the same window tap «Una foto» again with another photo.
   → «Ya usaste tu foto o archivo de prueba. Crea tu cuenta para subir más.»
5. In a new private window tap «Tu lista en Excel o PDF» and pick a spreadsheet with columns title, price, category.
   → «N productos de <file name>. Se suben a tu tienda cuando sea tuya.» «Armar mi tienda» → those products on the canvas.
6. In a new private window tap «El link de tu tienda», paste a `*.myshopify.com` address, «Leer».
   → the store's products listed; paste `https://169.254.169.254` instead → «Ese link no se puede abrir…».
7. (auth — owed to Daniel) From step 5, «Quedármela», sign in, and on the kept shop tap «Subir mis N productos».
   → «Listo: subimos N a tu tienda.»; they appear in https://miyagisanchez.com/shop/manage/products.

If any step fails, note the step number + what you saw — that's the bug report.

If any step fails, note the step number + what you saw — that's the bug report.
