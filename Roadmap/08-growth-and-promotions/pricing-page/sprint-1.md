---
epic: pricing-page
sprint: 1
title: "One price source + /mx/precios"
risk: low
phase: Building
stories_total: 4
stories:
  - id: S1.1
    title: "lib/pricing-catalog.ts + the price source-sweep spec"
    as_a: "the builder"
    i_want: "one pure module that assembles every price row (free items, fixed extras, admin-set extras, processor fees) from the existing sources"
    so_that: "a price changed in one file reaches every surface, and a hand-typed price can't sneak back in"
    risk: low
    status: planned
  - id: S1.2
    title: "/mx/precios page, OG image, JSON-LD offers, sitemap"
    as_a: "a merchant comparing platforms"
    i_want: "one page that shows what's free, what each extra costs, and what my payment processor charges"
    so_that: "I know what selling here costs before I sign up"
    risk: low
    status: planned
  - id: S1.3
    title: "/acerca, about-agent and llms.txt read the catalog"
    as_a: "an AI agent or a visitor reading about Miyagi"
    i_want: "the same prices everywhere, including Mercado Libre sync, the print ad and the migration"
    so_that: "no surface contradicts the pricing page"
    risk: low
    status: planned
  - id: S1.4
    title: "Footer, /mx/vende and comparador links + funnel clicks"
    as_a: "a visitor anywhere on the site"
    i_want: "to find «Precios» in the footer, from the selling pages and from the comparador"
    so_that: "the page gets found, and we see whether it sends people onward"
    risk: low
    status: planned
---
# Pricing page — Sprint 1: One price source + /mx/precios

**Status:** ⬜ not started

## Stories

### Story 1.1 — lib/pricing-catalog.ts + the price source-sweep spec
**As** the builder, **I want** one pure module that assembles every price row (free items, fixed extras, admin-set extras, processor fees) from the existing sources, **so that** a price changed in one file reaches every surface, and a hand-typed price can't sneak back in.
**Acceptance:** Rows come from `lib/subdomain-pricing.ts`, `lib/domain-pricing.ts`, `lib/ml-sync-pricing.ts`, `getPromoterSkuPrices()` (passed in, so the module stays pure) and the dataset's processor fees; Mercado Pago's MX rates are added to the dataset with source and `verifiedAt`. A spec checks every `PROMOTER_SKUS` entry has a row and each fixed price equals its constant; an unset admin price yields «Precio a cotizar», never 0. A **source-sweep spec** fails on a `$<n> MXN` literal in `locales/*.json`, `lib/about-content.ts` or the `/mx/vende` page config that the catalog doesn't produce, and passes on comparador competitor figures and catalog-interpolated values (allow the negation). Both specs observed failing under a mutation.
**Risk:** low

### Story 1.2 — /mx/precios page, OG image, JSON-LD offers, sitemap
**As** a merchant comparing platforms, **I want** one page that shows what's free, what each extra costs, and what my payment processor charges, **so that** I know what selling here costs before I sign up.
**Acceptance:** Server-rendered es-MX at `/mx/precios` with the four sections of the seed's surface block (Gratis, siempre · Extras opcionales · Lo que cobra tu pasarela (no nosotros) · ¿Y contra T1 y los demás?), «Empieza gratis» → `/mx/vende`, a short FAQ. ~~Explicit `revalidate` of one hour~~ — amended (README D6): the `(shell)` group renders per request, so the page is `no-store` and needs none. Own `opengraph-image.tsx`; JSON-LD `Offer`s only for fixed-price extras; added to `PLATFORM_SITEMAP_ENTRIES`. An `api` spec reads the raw HTML and finds every section and real prices. Shared `Card` / `Button` / `badge`, Iconoir, no emoji. Never implies card fees are free.
**Risk:** low

### Story 1.3 — /acerca, about-agent and llms.txt read the catalog
**As** an AI agent or a visitor reading about Miyagi, **I want** the same prices everywhere, including Mercado Libre sync, the print ad and the migration, **so that** no surface contradicts the pricing page.
**Acceptance:** `lib/about-content.ts`'s `pricing` section (es and en, it's on the bilingual allow-list) is built from the catalog and links to `/mx/precios`; `lib/about-agent.ts` drops «priced TBD» and states the real prices; `app/llms.txt` gains the pricing summary and the page URL. The `/acerca` browser spec still passes.
**Risk:** low

### Story 1.4 — Footer, /mx/vende and comparador links + funnel clicks
**As** a visitor anywhere on the site, **I want** to find «Precios» in the footer, from the selling pages and from the comparador, **so that** the page gets found, and we see whether it sends people onward.
**Acceptance:** «Precios» in the `PlatformShell` footer; a pricing link in the `/mx/vende` page sections (not the hero, which prompt-to-shop owns); a «Ver precios» back-link on the comparador. `precios_viewed`, `precios_comparador_clicked` and `precios_signup_clicked` fire once each through `lib/analytics-events.ts`.
**Risk:** low

## Sprint QA
- **api spec(s):** the catalog pure spec and the source-sweep spec (each observed red under a mutation); an `api` spec for `/mx/precios` server HTML (sections, prices, sitemap entry); `/acerca` browser spec stays green
- **browser smoke owed:** yes, to Daniel: the phone walkthrough below (no money or auth steps)
- **rails:** no-JS SEO spec pattern, Tailwind JIT arbitrary-value guard, emoji guard, es-MX copy completeness
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. On a phone, open https://miyagisanchez.com/mx/precios
   → four sections: Gratis, siempre · Extras opcionales · Lo que cobra tu pasarela · ¿Y contra T1?, with real prices
2. Check the Subdominio, Dominio propio and Mercado Libre cards
   → $199/año or $25/mes · $499/año · $299/año or $30/mes
3. Check the Anuncio impreso and Migración cards
   → a price if one is set in admin, otherwise «Precio a cotizar», never $0
4. Read the processor block
   → Stripe, Mercado Pago and SPEI with their rates and a source date; it says the money goes to your own account
5. Open https://miyagisanchez.com/acerca and scroll to Precios
   → the same prices, plus a link to /mx/precios
6. Open https://miyagisanchez.com/llms.txt
   → a pricing summary with the /mx/precios link; no «TBD»
7. Scroll to the footer on any page
   → «Precios» is there and opens the page

If any step fails, note the step number + what you saw — that's the bug report.
