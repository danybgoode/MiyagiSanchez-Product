---
epic: own-shop-positioning
sprint: 1
title: "The definition"
risk: low
phase: In review
stories_total: 1
stories:
  - id: S1.1
    title: "Every surface says «your own shop»"
    as_a: "a merchant reading the site or asking my AI about Miyagi Sánchez"
    i_want: "to hear «your own shop, built with you, 0% commission»"
    so_that: "the site backs what the promoter told me"
    risk: low
    status: in-progress
---
# Own-shop positioning: the site says what Miyagi Sánchez is now — Sprint 1: The definition

**Status:** 🟡 in review — storefront #492

## Stories

### Story 1.1 — Every surface says «your own shop»
**As** a merchant reading the site or asking my AI about Miyagi Sánchez, **I want** to hear «your own shop, built with you, 0% commission», **so that** the site backs what the promoter told me.
**Acceptance:** `lib/about-content.ts` (es + en) and its fan-out (`/acerca`, `/agent`, UCP manifest/profile, `llms.txt`, `about_miyagi`) lead with the own-shop definition; no public surface says marketplace-as-identity or P2P; the header CTA, footer and `/mx/vende` CTAs read «Abrir mi tienda»; the marketplace moves from the main navigation to the footer; home and `/mx/vende` keep one Vecindario-as-benefit line; a support block names the promoter (on their WhatsApp) and the merchant's AI agent, no platform number; `/` stays static.
**Risk:** low
## Sprint QA
- **api spec(s):** extend the agent-readability spec to assert the definition and the absence of «P2P»/«marketplace nativo»; CTA copy spec
- **browser smoke owed:** yes, to Daniel — phone walkthrough of header, footer, `/acerca`; ask an AI «¿qué es miyagisanchez.com?»
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge; every new spec seen red once by a mutation

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Open https://miyagisanchez.com/
   → the header CTA reads «Abrir mi tienda»; no «Publicar gratis»
2. Open https://miyagisanchez.com/acerca
   → the first line defines the merchant's own shop, 0% commission
3. Open https://miyagisanchez.com/llms.txt
   → the definition matches /acerca; no «P2P»
4. Ask Claude or ChatGPT «¿qué es miyagisanchez.com?»
   → it answers «your own shop», the Vecindario only as a benefit

If any step fails, note the step number + what you saw — that's the bug report.
