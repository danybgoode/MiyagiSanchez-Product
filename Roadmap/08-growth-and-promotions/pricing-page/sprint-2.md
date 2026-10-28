---
epic: pricing-page
sprint: 2
title: "T1 in the comparador"
risk: low
phase: Shaping
stories_total: 2
stories:
  - id: S2.1
    title: "T1 figures in the dataset + computeT1Cost + URL codec + analyze route"
    as_a: "the builder"
    i_want: "T1's public rates in the comparador dataset and a pure cost function for them"
    so_that: "the comparison is computed and cited like the other four platforms"
    risk: low
    status: planned
  - id: S2.2
    title: "T1 picker in the comparador + the prefilled link from /mx/precios"
    as_a: "a merchant who uses or is considering T1"
    i_want: "to pick T1 and its tier in the comparador and see my own numbers against Miyagi"
    so_that: "I can judge the switch with my real volume"
    risk: low
    status: planned
---
# Pricing page — Sprint 2: T1 in the comparador

**Status:** ⬜ not started

## Stories

### Story 2.1 — T1 figures in the dataset + computeT1Cost + URL codec + analyze route
**As** the builder, **I want** T1's public rates in the comparador dataset and a pure cost function for them, **so that** the comparison is computed and cited like the other four platforms.
**Acceptance:** Re-verify on build day against T1's pricing page and record each figure with source URL and `verifiedAt`: tiers Gratis / Básico $399 / Avanzado $1,499 a month, cards 3.5% + $1, SPEI $3, +2% on external methods for paid tiers, the Gratis tier's monthly online-order cap (30 as of 2026-10-27). `computeT1Cost` is pure and spec-covered (observed red once); `'t1'` joins `ComparatorPlatform`, the URL codec and `app/api/comparador/analyze`. Only public rates — never T1's negotiated freight or fleet.
**Risk:** low

### Story 2.2 — T1 picker in the comparador + the prefilled link from /mx/precios
**As** a merchant who uses or is considering T1, **I want** to pick T1 and its tier in the comparador and see my own numbers against Miyagi, **so that** I can judge the switch with my real volume.
**Acceptance:** `ComparadorTool` shows T1 with Gratis · Básico · Avanzado chips; its lines are subscription, card fee, SPEI and the external-methods extra; the Gratis tier notes its order cap; every figure shows its source and date and stays editable. `/comparador?platform=t1&tier=basico&volume=100&aov=500` renders T1's totals in the initial HTML; «Copiar enlace» restores a T1 comparison exactly; `/mx/precios`' compare link opens the comparador on T1. Extend `e2e/comparador*.spec.ts`.
**Risk:** low

## Sprint QA
- **api spec(s):** `computeT1Cost` pure spec; `comparador.spec.ts` / `comparador-prefill.spec.ts` extended with a T1 prefill (initial HTML totals, codec round-trip); `comparador-analyze-route.spec.ts` accepts `t1`
- **browser smoke owed:** yes, to Daniel: the phone walkthrough below (no money or auth steps)
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. On a phone, open https://miyagisanchez.com/mx/precios and tap «Compara con tus números»
   → the comparador opens with T1 selected
2. Pick Básico, set 100 sales a month and a $500 ticket
   → T1's total shows its plan and T1pagos card-fee lines against Miyagi's
3. Switch T1's payment to «Pasarela externa»
   → the payment line becomes T1's 2% cut (1% on Avanzado), and a note says T1's free plan has no online store
4. Hover or tap any T1 figure
   → its source and verified date show
5. Tap «Copiar enlace» and open the link in a private window
   → the same T1 comparison, same numbers

If any step fails, note the step number + what you saw — that's the bug report.
