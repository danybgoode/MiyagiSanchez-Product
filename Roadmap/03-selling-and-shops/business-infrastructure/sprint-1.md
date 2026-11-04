---
epic: business-infrastructure
sprint: 1
title: "The door opens, for any business"
risk: high
phase: Shipped
stories_total: 3
stories:
  - id: S1.1
    title: "The keep sheet scrolls and signs up"
    as_a: "a merchant who just saw their shop"
    i_want: "«Quedármela» to open a sign-up I can scroll and finish on phone and desktop"
    so_that: "I can keep the shop without knowing to press Tab"
    risk: high
    status: done
  - id: S1.2
    title: "Any business is recognised"
    as_a: "a cook, tutor, maker, rental or digital seller"
    i_want: "the description to recognise what kind of business I run, and let me change it in one tap"
    so_that: "the shop is built for how I actually sell"
    risk: high
    status: done
  - id: S1.3
    title: "The shop fits the business"
    as_a: "a merchant of any kind"
    i_want: "the right kind of listings, cobros and entregas pre-chosen for my business"
    so_that: "my shop is ready to sell the way I already do"
    risk: high
    status: done
---
# Business infrastructure — Sprint 1: The door opens, for any business

**Status:** ✅ shipped · **Merged:** danybgoode/MiyagiSanchez-Storefront#465 · danybgoode/MiyagiSanchez-Storefront#466

## Build contract (locked by the architect before the builder started)
Cite the epic README's D1–D3. S1.1 ships as its own PR (`fix/p2s-keep-sheet-scroll`) and merges first.
- S1.1: **reproduce first** in a real browser at 390×844 and 1280×800 on `/p2s/<id>` signed out; name the root cause
  in the PR. Known: `KeepSheet.tsx` renders a `fixed inset-0` sheet as a sibling of the sticky keep bar and sets
  `document.body.style.overflow = 'hidden'`. Candidates to test, in order: an ancestor that creates a containing block
  for `fixed` (transform / filter / backdrop-filter / contain); the scroll lock applied to `body` while the scroller is
  another element; Clerk's lazily mounted `<SignUp>` growing the dialog past `92vh` without its own scroll. Fix at the
  cause (a portal to `document.body` is acceptable if the cause is a containing block). A browser spec opens the sheet
  at both sizes and asserts the Clerk submit button is in the viewport after scrolling the dialog; seen red on the
  unfixed code.
- S1.2/1.3: shape enum and maps only in `lib/business-shape.ts`; identity schema + validator gain `shape`; the
  catalog prompt receives the shape; generated rows take `SHAPE_DEFAULTS[shape].listingType`; `CobrosChooser` reads the
  shape's defaults; `p2s_published` gains a `shape` param. Pure specs: shape validation + fallback, per-shape catalog
  fallback, defaults map — each seen red once.

## Stories

### Story 1.1 — The keep sheet scrolls and signs up ✅ danybgoode/MiyagiSanchez-Storefront#465
**As a** merchant who just saw their shop, **I want** «Quedármela» to open a sign-up I can scroll and finish on phone
and desktop, **so that** I can keep the shop without knowing to press Tab.
**Acceptance:** signed out on `/p2s/<id>`, tapping «Quedármela» shows the sign-up over the canvas; the whole form,
including Google and the email continue button, can be reached by scrolling on a phone and on desktop; Escape and
the close button still close it; the root cause is named in the PR.
**Risk:** high (sign-up path)

### Story 1.2 — Any business is recognised ✅ danybgoode/MiyagiSanchez-Storefront#466
**As a** cook, tutor, maker, rental or digital seller, **I want** the description to recognise what kind of business
I run, and let me change it in one tap, **so that** the shop is built for how I actually sell.
**Acceptance:** "doy clases de guitarra", "vendo tamales los domingos", "hago muebles sobre pedido", "rento
inflables", "vendo plantillas de Canva" and "vendo ropa de paca" land on services, food, made_to_order, rentals,
digital and products; the canvas names the shape and changing it regenerates the shop (one version used).
**Risk:** high

### Story 1.3 — The shop fits the business ✅ danybgoode/MiyagiSanchez-Storefront#466
**As a** merchant of any kind, **I want** the right kind of listings, cobros and entregas pre-chosen for my business,
**so that** my shop is ready to sell the way I already do.
**Acceptance:** a services shop's examples are services; a food shop has cash + hand delivery pre-selected and no
Correos; every generated row passes `validateRows`; `p2s_published` carries the shape.
**Risk:** high

## Sprint QA
- **api spec(s):** `e2e/p2s-shape.spec.ts` (shape validation, fallback, defaults, body `shape` parsing); existing
  `p2s-*` specs stay green.
- **browser spec:** `e2e/p2s-keep-sheet.spec.ts` (S1.1, both viewports).
- **browser smoke owed:** yes, to Daniel — a Google sign-up from the sheet on a real phone.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge.

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Signed out, go to https://miyagisanchez.com/mx/vende and describe "vendo tamales y atole los domingos en Coyoacán".
   → The shop takes shape and says it is a food business; the examples are dishes.
2. Scroll to the bottom and tap «Quedármela».
   → The sign-up opens over the canvas; you can scroll to every field and button.
3. (auth — owed to Daniel) Sign up with Google from the sheet.
   → You land on your kept shop.
4. In «Cobros y entregas», look at what is pre-selected.
   → Cash and hand delivery are on; Correos is not offered.
5. In a private window, describe "doy clases de guitarra a domicilio"; under «Tipo de negocio» pick Productos and tap «Otra versión».
   → The shop regenerates as a products shop and one version is used.

If any step fails, note the step number + what you saw — that's the bug report.
