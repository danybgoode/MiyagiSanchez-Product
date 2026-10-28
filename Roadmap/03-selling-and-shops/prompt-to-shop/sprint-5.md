---
epic: prompt-to-shop
sprint: 5
title: "Pay, deliver, publish, return"
risk: high
phase: Shipped
stories_total: 4
stories:
  - id: S5.1
    title: "Visual cobros / entregas chooser + checkout preview"
    as_a: "a merchant setting up payment and delivery"
    i_want: "logos and plain choices for how I get paid and how I deliver, with a preview of what my buyer will see"
    so_that: "I set it up in minutes without settings jargon"
    risk: high
    status: in-progress
  - id: S5.2
    title: "Publish + marketplace-card moment + shares"
    as_a: "a merchant ready to sell"
    i_want: "to tap «Publicar» and see my shop inside the marketplace, then share it in one tap"
    so_that: "I see that buyers can find me, and I tell my customers"
    risk: low
    status: in-progress
  - id: S5.3
    title: "Funnel events"
    as_a: "Daniel"
    i_want: "each step of the journey counted once"
    so_that: "I can see where merchants stop"
    risk: low
    status: in-progress
  - id: S5.4
    title: "Day 1/3/7 nudges + scheduler check"
    as_a: "a merchant who stopped halfway"
    i_want: "a reminder on the channel I chose, telling me the one step left"
    so_that: "I come back and finish"
    risk: high
    status: in-progress
---
# Prompt-to-shop — Sprint 5: Pay, deliver, publish, return

**Status:** ✅ merged + deployed (storefront #442 → `1b2123c`, live 2026-10-28). The money steps are owed to Daniel; the nudge timer is enabled.

## Stories

### Story 5.1 — Visual cobros / entregas chooser + checkout preview
**As** a merchant setting up payment and delivery, **I want** logos and plain choices for how I get paid and how I deliver, with a preview of what my buyer will see, **so that** I set it up in minutes without settings jargon.
**Acceptance:** Wraps the existing rails only: Mercado Pago OAuth (unchanged), SPEI (saves a CLABE), cash/arranged; arranged delivery, Correos económico, manual carrier. The checkout preview shows exactly the chosen methods. No new payment or shipping rail (BYO Envía is its own epic).
**Risk:** high

### Story 5.2 — Publish + marketplace-card moment + shares
**As** a merchant ready to sell, **I want** to tap «Publicar» and see my shop inside the marketplace, then share it in one tap, **so that** I see that buyers can find me, and I tell my customers.
**Acceptance:** «Publicar» makes the real products public; the screen shows the shop as a marketplace card; WhatsApp, an IG story image, a QR and a short link (`lib/share-link.ts`, `mschz.org`, `SuccessCard`) all work.
**Risk:** low

### Story 5.3 — Funnel events
**As** Daniel, **I want** each step of the journey counted once, **so that** I can see where merchants stop.
**Acceptance:** `p2s_describe_submitted` → `p2s_preview_rendered` → `p2s_version_requested` → `p2s_kept` → `p2s_real_product_added` → `p2s_payments_connected` → `p2s_published`, through `lib/analytics-events.ts`; each fires once per step (spec-guarded).
**Risk:** low

### Story 5.4 — Day 1/3/7 nudges + scheduler check
**As** a merchant who stopped halfway, **I want** a reminder on the channel I chose, telling me the one step left, **so that** I come back and finish.
**Acceptance:** Through `lib/notifications/*` and the merchant's preferences; none after publishing; none for an unclaimed draft without an email. **Before done:** confirm the Oracle VM schedules the cron route (team memory records a reminder cron with no scheduler entry); adding the entry is infra, orchestrator-owned.
**Risk:** high

## Sprint QA
- **api spec(s):** the checkout-preview pure spec (chosen methods only); funnel once-per-step spec; nudge selection pure spec (day 1/3/7, none after publish)
- **browser smoke owed:** yes, to Daniel by name: Mercado Pago OAuth and a real test order on the published shop (money)
- **review:** S5.1 and S5.4: fresh pr-reviewer, codex pass and the security lens
- **infra:** the VM scheduler entry for the nudge cron, verified by one fired run in the logs
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 5 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. Signed in, open https://miyagisanchez.com/sell/armar/cobros
   → logos for Mercado Pago, SPEI and cash, and the delivery options
2. (money, owed to Daniel) Connect Mercado Pago
   → the existing OAuth runs and returns connected
3. Add a CLABE for SPEI and pick «Entrega acordada»
   → the buyer checkout preview shows exactly those methods
4. Tap «Publicar»
   → the shop shows as a marketplace card; your real products are public; examples are not
5. Open https://miyagisanchez.com/mx and search for the shop
   → it appears in the marketplace
6. Tap WhatsApp, IG story, QR and short link
   → each opens or downloads the right thing pointing at your shop
7. (money, owed to Daniel) Buy one real product as a buyer
   → the order completes on the chosen method
8. Leave a second test shop unpublished for a day
   → the day-1 nudge arrives on its chosen channel; the published shop gets none

If any step fails, note the step number + what you saw — that's the bug report.

### Results — 2026-10-28, production (`miyagi-web` at `1b2123c`)
- **Routes ✅** — `/api/p2s/publish` and `/api/sell/shop/qr` refuse an anonymous caller (401). `/api/cron/p2s-nudges` refuses both a missing secret and a `?secret=` query (401; header only). `/sell/armar/cobros` serves.
- **Timer ✅** — enabled on the VM by Daniel on 2026-10-28 (`miyagi-cron-p2s-nudges.timer`, daily at 15:00 UTC). The first manual run returned 200 with zero candidates, as expected.
- **Steps 1–8 — OWED to Daniel.** These include Mercado Pago OAuth from the chooser and a real test order (money).
- **Decisions made while building** (see #442):
  - The checkout preview asks checkout's own endpoint (`/api/checkout/options`) instead of re-deriving the rule, because checkout's decision lives in the backend.
  - «Entrega acordada» maps to `shipping.local_pickup`. Manual carrier is backend-decided and US-only, so it gets no switch.
  - Publish activates only the merchant's own draft products, through the catalog's own activate (viability gate included).
  - Funnel events fire on the transition (keep, publish) or once per draft through localStorage.
  - Nudge milestones are recorded in `block_status.nudges` before the send. Unclaimed drafts get none, because no email is stored.
- **Review:**
  - fresh verifier: lint red, plus a funnel that re-fired across sessions.
  - codex general: 3 Should-fix (a send throw ending the batch, bank «Otro», unbounded concurrency), then clean.
  - codex security: the cron secret was also accepted in the query string, and the QR slug was unvalidated; then clean.
  - All fixed with specs.
