---
epic: share-kit
sprint: 3
title: "Instagram and WhatsApp catalogs"
risk: low
phase: Shaping
stories_total: 3
stories:
  - id: S3.1
    title: "Pure Meta feed builder + exclusion reasons"
    as_a: "the builder"
    i_want: "a pure function that turns the shop's catalog model into Meta's feed rows and says which products were left out and why"
    so_that: "the feed is always valid and the merchant knows what's missing"
    risk: low
    status: planned
  - id: S3.2
    title: "/api/feeds/meta/[slug].csv + the Comparte guide tile"
    as_a: "a merchant who sells on Instagram and WhatsApp"
    i_want: "a feed address and a short guide to plug my products into Meta"
    so_that: "my Instagram Shopping and WhatsApp Business catalogs fill and stay current on their own"
    risk: low
    status: planned
  - id: S3.3
    title: "MCP get_share_kit for seller agents + funnel events"
    as_a: "a seller's AI agent"
    i_want: "one tool that returns my shop's catalog link, PDF link and feed URL"
    so_that: "I can hand them to my human or post them for them"
    risk: low
    status: planned
---
# Share kit — Sprint 3: Instagram and WhatsApp catalogs

**Status:** ⬜ not started

## Stories

### Story 3.1 — Pure Meta feed builder + exclusion reasons
**As** the builder, **I want** a pure function that turns the shop's catalog model into Meta's feed rows and says which products were left out and why, **so that** the feed is always valid and the merchant knows what's missing.
**Acceptance:** From the S1.1 model: Meta's required columns (`id`, `title`, `description`, `availability`, `condition`, `price` as «199.00 MXN», `link`, `image_link`, `brand`), re-confirmed against Meta's current spec page at the start of the sprint; stable IDs; products without a photo or a price excluded and counted by reason; CSV escaping spec-covered. Observed red under a mutation.
**Risk:** low

### Story 3.2 — /api/feeds/meta/[slug].csv + the Comparte guide tile
**As** a merchant who sells on Instagram and WhatsApp, **I want** a feed address and a short guide to plug my products into Meta, **so that** my Instagram Shopping and WhatsApp Business catalogs fill and stay current on their own.
**Acceptance:** A public per-shop CSV with explicit caching (one hour); an «Instagram y WhatsApp» tile in Comparte with the URL, copy, a four-step Commerce Manager guide and the excluded count («3 productos no aparecen: les falta foto o precio»); none for unclaimed shops. Daniel adds one real feed in Meta Commerce Manager as the acceptance step.
**Risk:** low

### Story 3.3 — MCP get_share_kit for seller agents + funnel events
**As** a seller's AI agent, **I want** one tool that returns my shop's catalog link, PDF link and feed URL, **so that** I can hand them to my human or post them for them.
**Acceptance:** MCP `get_share_kit` scoped to the authenticated seller's own shop (another shop's slug is refused); `share_meta_feed_copied`, `catalog_order_whatsapp` and `catalog_order_buy` fire once per tap. `api` spec for the tool and its scoping.
**Risk:** low

## Sprint QA
- **api specs:** feed builder (columns, price format, exclusions, escaping); feed route scoping; MCP tool scoping
- **browser smoke owed:** yes, to Daniel: the walkthrough below, including the real Meta Commerce Manager step
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. Open https://miyagisanchez.com/shop/manage/comparte
   → an «Instagram y WhatsApp» tile with the feed address, steps and how many products are left out
2. Open the feed address in a browser
   → a CSV of your products with prices like 199.00 MXN
3. (owed to Daniel) In Meta Commerce Manager, add a data source with that URL on a schedule
   → Meta accepts it and lists your products
4. Ask your agent for your share kit
   → it returns the catalog link, the PDF link and the feed URL for your shop only

If any step fails, note the step number + what you saw — that's the bug report.
