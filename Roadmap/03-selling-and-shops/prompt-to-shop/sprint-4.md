---
epic: prompt-to-shop
sprint: 4
title: "Make it yours"
risk: high
phase: Verifying
stories_total: 3
stories:
  - id: S4.1
    title: "Owner canvas + checklist from setup-guide"
    as_a: "a merchant who just kept my shop"
    i_want: "my shop with a short checklist over it: fotos, cobros, entregas, publicar"
    so_that: "I always know the next step"
    risk: low
    status: in-progress
  - id: S4.2
    title: "Photo → product (Gemini vision, 20 a month)"
    as_a: "a merchant with photos on my phone"
    i_want: "to take or pick a photo and get a product card filled with a title, description, category and suggested price"
    so_that: "I add products the way I already think: in photos"
    risk: high
    status: in-progress
  - id: S4.3
    title: "Example → real replacement + «Publicar» disabled reason"
    as_a: "a merchant replacing examples"
    i_want: "each example to turn into my real product when I add its photo and confirm the price"
    so_that: "the shop fills with my things and no example is ever sold"
    risk: low
    status: in-progress
---
# Prompt-to-shop — Sprint 4: Make it yours

**Status:** 🟡 merged + deployed (storefront #441 → `16bcd1f`, live 2026-10-28). The phone walkthrough below is owed to Daniel.

## Stories

### Story 4.1 — Owner canvas + checklist from setup-guide
**As** a merchant who just kept my shop, **I want** my shop with a short checklist over it: fotos, cobros, entregas, publicar, **so that** I always know the next step.
**Acceptance:** The checklist and its % come from `lib/setup-guide.ts` (`computeShopCompletion`, `getSetupSteps`) and match Resumen's; each item opens an overlay on the canvas, never a separate form page.
**Risk:** low

### Story 4.2 — Photo → product (Gemini vision, 20 a month)
**As** a merchant with photos on my phone, **I want** to take or pick a photo and get a product card filled with a title, description, category and suggested price, **so that** I add products the way I already think: in photos.
**Acceptance:** Upload via `/api/sell/upload` → R2; Gemini vision fills a `CatalogImportRow` validated by `validateRows`; the card fills visibly; confirming creates **one Medusa draft product** owned by the shop; the allowance spends one `photo` per confirmed suggestion through the S1.1 RPC; the 21st in a calendar month is refused with «Te quedan 0 fotos este mes; vuelven el 1». Rate-limited by `LimitKey`. No AI-generated images. ~~Adds the «Con IA» row to `/mx/precios`~~ — **descoped by D18** (the lock, 2026-10-27): `/mx/precios` does not exist yet, so the row ships with `pricing-page`, reading `P2S_LIMITS` in `lib/prompt-to-shop/allowance.ts`.
**Risk:** high

### Story 4.3 — Example → real replacement + «Publicar» disabled reason
**As** a merchant replacing examples, **I want** each example to turn into my real product when I add its photo and confirm the price, **so that** the shop fills with my things and no example is ever sold.
**Acceptance:** Replacing an example removes it from the draft and creates the real draft listing (S4.2); «Publicar» is disabled with «Agrega al menos un producto tuyo» until ≥1 real product exists; examples never appear in marketplace, search or sitemaps.
**Risk:** low

## Sprint QA
- **api spec(s):** photo → product route spec (one Medusa draft product per confirmation, 21st refused); the checklist-parity pure spec against `setup-guide`
- **browser smoke owed:** yes, to Daniel: the photo steps on a real phone (camera + gallery)
- **review:** S4.2 writes Medusa products: fresh pr-reviewer, codex pass and the security lens
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 4 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. Signed in with the shop from sprint 3, open https://miyagisanchez.com/sell/armar
   → your shop shows with the checklist and its %; the same % shows on Resumen
2. Tap an EJEMPLO product, then «Cambiar por mi foto», and take a photo
   → the card fills with a title, description, category and suggested price
3. Confirm the price
   → the example is gone, your product shows, and Medusa admin has one draft product for the shop
4. Look at «Publicar» before step 3, then after
   → disabled with «Agrega al menos un producto tuyo», then enabled

If any step fails, note the step number + what you saw — that's the bug report.

### Results — 2026-10-28, production (`miyagi-web` at `16bcd1f`)
- **Routes ✅** — `POST /api/p2s/photo` and `/api/p2s/photo/confirm` refuse an anonymous caller (401).
- **Steps 1–4 — OWED to Daniel.** They need a kept shop and a real phone (camera and gallery). Also check:
  - one `ai_allowance` row `user:<id>` / `photo` / this month after a confirm;
  - a `photo_analysis:user:<id>` / `daily_budget` row after an analysis;
  - a `[p2s] photo_model` log line, which confirms Vertex accepts the image inline.
- **Decisions made while building** (see #441):
  - The photo is spent at confirm and fails closed.
  - Analyses have their own fail-closed cap of 40 a day per user, on top of a burst limit.
  - A per-card nonce in `block_status.photo_confirms` is recorded as paid BEFORE the Medusa create, which has a 20 s timeout. A double tap, a stall or a retry therefore makes one product and spends one photo.
  - Photo URLs must be our own storage, in the merchant's own folder.
  - Resumen and `/sell/armar` share one checklist loader.
- **Review:**
  - codex general: Should-fix ×1, then Blocking ×1 (double spend after a stale takeover) plus Should-fix ×1, then clean.
  - codex security lens: Should-fix ×1, then clean.
  - fresh verifier: red gate plus an unbounded analysis spend.
  - All fixed with specs. CodeQL's `xss-through-dom` was cleared by drawing the preview onto a canvas. Dismissing the alert as a false positive was blocked, so the code changed instead.
