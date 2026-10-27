---
epic: prompt-to-shop
sprint: 3
title: "Keep it"
risk: high
phase: Shaping
stories_total: 3
stories:
  - id: S3.1
    title: "«Quedármela» keep sheet + Clerk fallback redirect"
    as_a: "a merchant who likes what I see"
    i_want: "to tap «Quedármela» and sign up in a sheet over my shop"
    so_that: "signup feels like the reward and I land back on my shop"
    risk: high
    status: planned
  - id: S3.2
    title: "Conditional draft claim + idempotent draft → shop apply"
    as_a: "the platform"
    i_want: "the draft claimed by exactly one signed-in owner, on the device that made it, and turned into one shop"
    so_that: "no second seller, no stolen draft, and no example in Medusa"
    risk: high
    status: planned
  - id: S3.3
    title: "Bienvenida and Puertas leave the main path"
    as_a: "a new merchant"
    i_want: "no intake questions and no choice of doors before I see my shop"
    so_that: "the first thing I see is my shop"
    risk: low
    status: planned
---
# Prompt-to-shop — Sprint 3: Keep it

**Status:** ⬜ not started

## Stories

### Story 3.1 — «Quedármela» keep sheet + Clerk fallback redirect
**As** a merchant who likes what I see, **I want** to tap «Quedármela» and sign up in a sheet over my shop, **so that** signup feels like the reward and I land back on my shop.
**Acceptance:** A bottom sheet over the canvas with Google and email (Clerk); after signup the merchant lands on `/sell/armar` showing their shop as its owner. Uses `signInFallbackRedirectUrl` / `signUpFallbackRedirectUrl` (fallback, never force); `NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL` is dead config in Clerk v7. «Mándame el enlace» emails the draft link instead.
**Risk:** high

### Story 3.2 — Conditional draft claim + idempotent draft → shop apply
**As** the platform, **I want** the draft claimed by exactly one signed-in owner, on the device that made it, and turned into one shop, **so that** no second seller, no stolen draft, and no example in Medusa.
**Acceptance:** Claim is one conditional write (`… WHERE id = ? AND device_id = ? AND claimed_by IS NULL RETURNING`, `.select()` back), then `planSetupApply` for the profile and config only: **examples stay in the draft, never in Medusa**. Reload or a second tab returns the same shop; another device holding the link gets «Esta tienda se armó en otro teléfono». The slug is reserved only now; a conflict offers the next free variant inline. `sendShopCreatedWelcome` fires exactly once. Specs assert the ordering, not only status codes.
**Risk:** high

### Story 3.3 — Bienvenida and Puertas leave the main path
**As** a new merchant, **I want** no intake questions and no choice of doors before I see my shop, **so that** the first thing I see is my shop.
**Acceptance:** `/sell/bienvenida` and `/sell/puertas` redirect to the new first run; the file/agent import stays reachable as «¿Ya tienes tu catálogo en un archivo?»; `SellWizard` stays reachable as «Armar a mano»; a source sweep finds no remaining links to the old routes.
**Risk:** low

## Sprint QA
- **api spec(s):** claim specs (one owner, second tab idempotent, other device refused, zero Medusa example products afterwards, welcome fired once) asserting the ordering; a redirect spec for the two old routes plus a source sweep
- **browser smoke owed:** yes, to Daniel by name: the signup steps (auth)
- **review:** money/auth path: fresh pr-reviewer, codex cross-family pass and the security lens
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. On a phone, make a draft at https://miyagisanchez.com/mx/vende and tap «Quedármela»
   → a sheet opens over the shop with Google and email
2. (auth, owed to Daniel) Sign up with a new Google account
   → you land on your shop as its owner, at /sell/armar
3. Reload, then open the same page in a second tab
   → still one shop; Medusa admin shows one new seller
4. Open the draft link on a second phone
   → it says the shop was made on another phone and offers to start one
5. In Medusa admin, search products for the shop
   → zero products: the examples stayed out of Medusa
6. Open https://miyagisanchez.com/sell/bienvenida
   → it lands on the new first run
7. Check the inbox of the new account
   → exactly one welcome email

If any step fails, note the step number + what you saw — that's the bug report.
