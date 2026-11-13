---
epic: one-front-door-both-markets
sprint: 2
title: "Two languages, two markets"
risk: high
phase: Shipped
stories_total: 4
stories:
  - id: S2.1
    title: "The builder in English, in dollars"
    as_a: "an English-speaking merchant"
    i_want: "the builder, the canvas and its messages in English, with prices in my market's currency"
    so_that: "I understand every step"
    risk: low
    status: done
  - id: S2.2
    title: "I choose where I sell when the shop becomes mine"
    as_a: "a merchant from any country"
    i_want: "to answer «¿Dónde vas a vender?» — Mexico (pesos) or the US (dollars) — at «Quedármela»"
    so_that: "my shop is created in the right market the first time"
    risk: high
    status: done
  - id: S2.3
    title: "The site opens in my language"
    as_a: "a visitor whose browser reads English"
    i_want: "to land on the English builder, and to switch at any time"
    so_that: "I don't have to find the language link"
    risk: low
    status: done
  - id: S2.4
    title: "The US landing in Spanish"
    as_a: "a Spanish-speaking merchant in the US"
    i_want: "`/us/vende`, the US offer told in Spanish"
    so_that: "I read the US terms in my language"
    risk: low
    status: done
---
# One front door for both markets — Sprint 2: Two languages, two markets

**Status:** ✅ shipped `b429945` (#499), deployed 2026-11-13

## Stories

### Story 2.1 — The builder in English, in dollars ✅ `b429945`
**As a** an English-speaking merchant, **I want** the builder, the canvas and its messages in English, with prices in my market's currency, **so that** I understand every step.
**Acceptance:** On `/en` describe «I make soy candles in Austin» → name, words and example products in English, prices in USD. On `/` everything stays in Spanish.
**Risk:** low

### Story 2.2 — I choose where I sell when the shop becomes mine ✅ `b429945`
**As a** a merchant from any country, **I want** to answer «¿Dónde vas a vender?» — Mexico (pesos) or the US (dollars) — at «Quedármela», **so that** my shop is created in the right market the first time.
**Acceptance:** At «Quedármela» the question is shown with one option preselected from my browser; I must tap before the shop is made. Choosing the US → a shop with market `us`, USD; Mexico → `mx`, MXN. No answer → no shop.
**Risk:** high

### Story 2.3 — The site opens in my language ✅ `b429945`
**As a** a visitor whose browser reads English, **I want** to land on the English builder, and to switch at any time, **so that** I don't have to find the language link.
**Acceptance:** An `en-US` browser on `/` is sent once to `/en`; an `en-MX` phone stays on `/`. The ES/EN switch wins from then on. `/en` is the English builder with the México · United States · Español strip at the end; `/` and `/en` name each other as hreflang alternates.
**Risk:** low

### Story 2.4 — The US landing in Spanish ✅ `b429945`
**As a** a Spanish-speaking merchant in the US, **I want** `/us/vende`, the US offer told in Spanish, **so that** I read the US terms in my language.
**Acceptance:** `/us/vende` renders the US landing in Spanish: dollars, Stripe, no SPEI; `/us/sell` links to it and back; the builder there makes US shops.
**Risk:** low
## Sprint QA
- **api spec(s):** pure-logic `node:test`/Playwright `api` specs on the `lib/` seams this sprint adds (named in the README's locking decisions); every new spec observed failing once by a deliberate mutation.
- **browser smoke owed:** yes, to Daniel — the walkthrough below on production.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge.

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. In a browser set to English (US), open https://miyagisanchez.com/
   → you land on https://miyagisanchez.com/en: «Tell us what you sell», «Where you'll sell» (Mexico · United States).
2. On a phone set to English (Mexico), open https://miyagisanchez.com/
   → you stay on the Spanish builder («Cuéntanos qué vendes»).
3. On /en describe «I make soy candles in Austin» → «Build my shop»
   → the shop takes shape in English, example prices in USD, tagged «EXAMPLE».
4. Open https://miyagisanchez.com/us/vende
   → the US offer in Spanish (dólares, Stripe), with the describe box and a link «Read this page in English».
5. (auth — owed to Daniel) From step 3, «Keep my shop» → sign up → «Where will you sell?» → United States → «Keep my shop»
   → a US shop; its public link is https://miyagisanchez.com/us/s/<slug>; Cobros shows «Card payments with Stripe».
6. (money — owed to Daniel) «Connect Stripe» → Stripe's US onboarding (not the Mexican Express form).

If any step fails, note the step number + what you saw — that's the bug report.
