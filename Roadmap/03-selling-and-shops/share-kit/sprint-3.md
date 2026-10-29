---
epic: share-kit
sprint: 3
title: "Instagram and WhatsApp catalogs"
risk: low
phase: Shipped
stories_total: 3
stories:
  - id: S3.1
    title: "Pure Meta feed builder + exclusion reasons"
    as_a: "the builder"
    i_want: "a pure function that turns the shop's catalog model into Meta's feed rows and says which products were left out and why"
    so_that: "the feed is always valid and the merchant knows what's missing"
    risk: low
    status: done
  - id: S3.2
    title: "/api/feeds/meta/[slug].csv + the Comparte guide tile"
    as_a: "a merchant who sells on Instagram and WhatsApp"
    i_want: "a feed address and a short guide to plug my products into Meta"
    so_that: "my Instagram Shopping and WhatsApp Business catalogs fill and stay current on their own"
    risk: low
    status: done
  - id: S3.3
    title: "MCP get_share_kit for seller agents + funnel events"
    as_a: "a seller's AI agent"
    i_want: "one tool that returns my shop's catalog link, PDF link and feed URL"
    so_that: "I can hand them to my human or post them for them"
    risk: low
    status: done
---
# Share kit — Sprint 3: Instagram and WhatsApp catalogs

**Status:** ✅ shipped 2026-10-29 · Storefront PR #449 → `100ae4e`, live on the VM (web container revision `100ae4e`)

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

## Shipped

- **PR:** MiyagiSanchez-Storefront #449 → squash `100ae4e`. Reviews:
  - The fresh `verifier`, two rounds. Round 1 found 2 blocking items (a CI-red icon subset and flag inventory) and 2 should-fixes (sold-out shown as `in stock`; a failed read publishing an empty feed). Every one was fixed with a spec observed red. Round 2 was clean.
  - Codex general and security passes on gpt-6-luna @ xhigh: clean, except codex security's CSV formula-injection point. That was answered, not changed (Meta needs the literal text), and the verifier concurred.
- **Beyond the contract, from review:**
  - The feed states availability (`out of stock` and `available for order` too).
  - A partial Medusa read answers 503 + no-store, never a short feed. A Meta replace-feed would delete the missing products.
  - `getShopListings` no longer caches a failed read as an empty shop.
  - `get_share_kit` is a viewer-safe partner read.
- **Meta columns, confirmed 2026-10-28:** id, title, description, availability, condition, price, link, image_link, brand. Prices read "199.00 MXN".

### Verified live (agent, production, 2026-10-29)
- Probing all 22 public shops: exactly 2 claimed Mexico shops answer 200 (`angela`, `bright`), and the rest 404 as unclaimed. Unknown shops and wrong extensions 404 too.
  - `angela`: one row, `182.00 MXN,in stock,new`, with an absolute link and R2 image.
  - `bright`: its one product has no price, so the feed has a header and 0 rows, which is correct.
  - Headers are `text/csv; charset=utf-8` and `s-maxage=3600`. Cloudflare returns HIT.
- `tools/list` includes `get_share_kit`. An unauthenticated call is refused with the seller-token hint.
- The catalog page's order buttons carry `data-product` (16 of 16 on el-manchon) for the tap events.
- `e2e/share-kit-feed.spec.ts` and `share-kit-catalog.spec.ts` against prod: 27/27 green.
- **Owed to Daniel:** step 1 (the signed-in Comparte tile), step 3 (add one real feed in Meta Commerce Manager, the sprint's product-owner acceptance step; `angela` is a claimed shop with a valid row). **"Shipped" here means merged, deployed and agent-verified against Meta's column spec, as for every epic. The product-owner acceptance is tracked as owed, not assumed.**, and step 4 (an agent with a real `ms_agent_` token).
- **Follow-ups:**
  - `get_share_kit` and the Comparte tile read counts from a partial model during a Medusa outage.
  - Meta's title and description length limits.
  - Non-product listing types in a commerce feed.

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
