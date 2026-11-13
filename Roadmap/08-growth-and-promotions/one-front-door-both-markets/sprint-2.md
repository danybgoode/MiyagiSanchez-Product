---
epic: one-front-door-both-markets
sprint: 2
title: "Two languages, two markets"
risk: high
phase: Locking architecture
stories_total: 4
stories:
  - id: S2.1
    title: "The builder in English, in dollars"
    as_a: "an English-speaking merchant"
    i_want: "the builder, the canvas and its messages in English, with prices in my market's currency"
    so_that: "I understand every step"
    risk: low
    status: planned
  - id: S2.2
    title: "I choose where I sell when the shop becomes mine"
    as_a: "a merchant from any country"
    i_want: "to answer «¿Dónde vas a vender?» — Mexico (pesos) or the US (dollars) — at «Quedármela»"
    so_that: "my shop is created in the right market the first time"
    risk: high
    status: planned
  - id: S2.3
    title: "The site opens in my language"
    as_a: "a visitor whose browser reads English"
    i_want: "to land on the English builder, and to switch at any time"
    so_that: "I don't have to find the language link"
    risk: low
    status: planned
  - id: S2.4
    title: "The US landing in Spanish"
    as_a: "a Spanish-speaking merchant in the US"
    i_want: "`/us/vende`, the US offer told in Spanish"
    so_that: "I read the US terms in my language"
    risk: low
    status: planned
---
# One front door for both markets — Sprint 2: Two languages, two markets

**Status:** ⬜ not started

## Stories

### Story 2.1 — The builder in English, in dollars
**As a** an English-speaking merchant, **I want** the builder, the canvas and its messages in English, with prices in my market's currency, **so that** I understand every step.
**Acceptance:** On `/en` describe «I make soy candles in Austin» → name, words and example products in English, prices in USD. On `/` everything stays in Spanish.
**Risk:** low

### Story 2.2 — I choose where I sell when the shop becomes mine
**As a** a merchant from any country, **I want** to answer «¿Dónde vas a vender?» — Mexico (pesos) or the US (dollars) — at «Quedármela», **so that** my shop is created in the right market the first time.
**Acceptance:** At «Quedármela» the question is shown with one option preselected from my browser; I must tap before the shop is made. Choosing the US → a shop with market `us`, USD; Mexico → `mx`, MXN. No answer → no shop.
**Risk:** high

### Story 2.3 — The site opens in my language
**As a** a visitor whose browser reads English, **I want** to land on the English builder, and to switch at any time, **so that** I don't have to find the language link.
**Acceptance:** An `en-US` browser on `/` is sent once to `/en`; an `en-MX` phone stays on `/`. The ES/EN switch wins from then on. `/en` is the English builder with the México · United States · Español strip at the end; `/` and `/en` name each other as hreflang alternates.
**Risk:** low

### Story 2.4 — The US landing in Spanish
**As a** a Spanish-speaking merchant in the US, **I want** `/us/vende`, the US offer told in Spanish, **so that** I read the US terms in my language.
**Acceptance:** `/us/vende` renders the US landing in Spanish: dollars, Stripe, no SPEI; `/us/sell` links to it and back; the builder there makes US shops.
**Risk:** low
## Sprint QA
- **api spec(s):** pure-logic `node:test`/Playwright `api` specs on the `lib/` seams this sprint adds (named in the README's locking decisions); every new spec observed failing once by a deliberate mutation.
- **browser smoke owed:** yes, to Daniel — the walkthrough below on production.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge.

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

_(Written at sprint close with the real URLs and results.)_

If any step fails, note the step number + what you saw — that's the bug report.
