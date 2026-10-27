---
epic: share-kit
sprint: 1
title: "The catalog link"
risk: low
phase: Shaping
stories_total: 3
stories:
  - id: S1.1
    title: "Pure catalog view model + WhatsApp order link + two-shop scoping spec"
    as_a: "the builder"
    i_want: "one pure model of a shop's shareable catalog, built only from that shop's visible listings, plus a WhatsApp order-link builder"
    so_that: "the page, the PDF and the feed share one source and can never leak another shop's products"
    risk: low
    status: planned
  - id: S1.2
    title: "/mx/s/[slug]/catalogo on every shop channel"
    as_a: "a customer who got the link in a WhatsApp chat"
    i_want: "a fast single scroll of the shop's products with one big order button on each"
    so_that: "I can order in one tap without browsing a whole store"
    risk: low
    status: planned
  - id: S1.3
    title: "Comparte «Catálogo» tile + QR + the prompt-to-shop publish tile"
    as_a: "a merchant"
    i_want: "a tile in Comparte to copy, send by WhatsApp or download a QR of my catalog link"
    so_that: "I can put my catalog in chats, my status and on paper"
    risk: low
    status: planned
---
# Share kit — Sprint 1: The catalog link

**Status:** ⬜ not started

## Stories

### Story 1.1 — Pure catalog view model + WhatsApp order link + two-shop scoping spec
**As** the builder, **I want** one pure model of a shop's shareable catalog, built only from that shop's visible listings, plus a WhatsApp order-link builder, **so that** the page, the PDF and the feed share one source and can never leak another shop's products.
**Acceptance:** A pure `lib/share-kit/catalog.ts` from `getShopListings(slug)` output: photo, name, price or «Precio a consultar», product link, short link; the storefront's visibility rules apply (paused, draft, deleted and private products excluded). `buildWhatsAppOrderLink(phone, product, url)` reuses `SellerTrustCard`'s number normalization and names the product and its link. A two-shop spec asserts shop A's model contains none of shop B's products. Specs observed red under a mutation.
**Risk:** low

### Story 1.2 — /mx/s/[slug]/catalogo on every shop channel
**As** a customer who got the link in a WhatsApp chat, **I want** a fast single scroll of the shop's products with one big order button on each, **so that** I can order in one tap without browsing a whole store.
**Acceptance:** Server-rendered, phone-first; header with logo, name and theme colours; each card «Pedir por WhatsApp» when the merchant has a WhatsApp number, else «Comprar» (always «Comprar» for an unclaimed shop); empty state from the seed; reachable on the shop's subdomain and custom domain channel; explicit `revalidate`; OG image; fits the client-JS diet budget. An `api` spec reads the server HTML.
**Risk:** low

### Story 1.3 — Comparte «Catálogo» tile + QR + the prompt-to-shop publish tile
**As** a merchant, **I want** a tile in Comparte to copy, send by WhatsApp or download a QR of my catalog link, **so that** I can put my catalog in chats, my status and on paper.
**Acceptance:** A «Catálogo» tile in Comparte with copy, WhatsApp share (`buildWhatsAppShareLink`) and a QR PNG download; the same tile on prompt-to-shop's publish screen (needs its S5.2 merged); `share_catalog_link` fires once per tap. Shared `Card` / `Button`, Iconoir, no emoji.
**Risk:** low

## Sprint QA
- **api specs:** two-shop scoping on the view model and the page; the WhatsApp order link; catalog page server HTML
- **browser smoke owed:** yes, to Daniel: the phone walkthrough below
- **rails:** no-JS server HTML, Tailwind JIT guard, emoji guard, es-MX completeness, client-JS diet
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. On a phone, open https://miyagisanchez.com/shop/manage/comparte
   → a «Catálogo» tile with copy, WhatsApp and QR
2. Tap «Compartir por WhatsApp» and send it to yourself, then open the link
   → the catalog page loads fast as one scroll of your products
3. Tap «Pedir por WhatsApp» on a product
   → WhatsApp opens to the shop's number with the product name and link
4. Open the catalog of a shop with no WhatsApp number
   → each product shows «Comprar» instead
5. Download the QR and scan it
   → it opens the catalog page

If any step fails, note the step number + what you saw — that's the bug report.
