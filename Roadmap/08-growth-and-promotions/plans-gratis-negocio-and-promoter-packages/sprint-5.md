---
epic: plans-gratis-negocio-and-promoter-packages
sprint: 5
title: "The promoter fills the shop from photos"
risk: high
phase: Shaping
stories_total: 1
stories:
  - id: S5.1
    title: "The promoter fills the shop from photos"
    as_a: "a promoter at the counter"
    i_want: "to photograph the merchant's products and get ready-to-publish cards"
    so_that: "the shop is full in minutes and stays linked to me"
    risk: high
    status: planned
---
# Two plans (Gratis + Negocio), a 30-day trial, and three promoter packages — Sprint 5: The promoter fills the shop from photos

**Status:** ⬜ not started

## Stories

### Story 5.1 — The promoter fills the shop from photos
**As** a promoter at the counter, **I want** to photograph the merchant's products and get ready-to-publish cards, **so that** the shop is full in minutes and stays linked to me.
**Acceptance:** In `/promotor/cerrar`, after «Abrir la tienda», a photo step proposes product cards (name, price, category) for the unclaimed shop; confirming one creates it through the existing promoter listing route; the shop appears in the promoter's relationships; the promoter's daily photo allowance applies.
**Risk:** high

## Build contract (locked by the architect before the builder started)

Cite the epic README's locked decisions: D14. Writes only to the unclaimed shop the promoter just opened (the existing ownership checks of `/api/promoter/close/listing`); never to a claimed shop.

## Sprint QA
- **api spec(s):** `e2e/promoter-photo-step.spec.ts` (pure card → listing mapping, ownership refusal).
- **browser smoke owed:** yes, to Daniel: on his phone, three real photos into a test shop.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 5 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Go to https://miyagisanchez.com/promotor/cerrar
   → open a test shop, take a photo of a product → a card with a name and price appears; «Publicar» → it is on the shop
2. Go to https://miyagisanchez.com/promotor/relaciones
   → the test shop is listed

If any step fails, note the step number + what you saw — that's the bug report.
