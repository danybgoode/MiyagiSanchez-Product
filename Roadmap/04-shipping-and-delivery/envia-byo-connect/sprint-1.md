---
epic: envia-byo-connect
sprint: 1
title: "The connection"
risk: high
phase: Shaping
stories_total: 4
stories:
  - id: S1.1
    title: "envia_connection model + shared AES-GCM lib + Medusa migration"
    as_a: "the platform"
    i_want: "a per-seller Envía connection stored encrypted in Medusa"
    so_that: "a merchant's key is safe at rest and only the backend can ever read it"
    risk: high
    status: planned
  - id: S1.2
    title: "Validate-then-save and disconnect routes, write-only, rate-limited"
    as_a: "a merchant"
    i_want: "to paste my Envía key, have it checked, and disconnect whenever I want"
    so_that: "a wrong key never gets saved and my key is never shown back to me"
    risk: high
    status: planned
  - id: S1.3
    title: "Pure credential resolution seam + truth-table spec"
    as_a: "the platform"
    i_want: "one pure function that decides whose Envía account pays for every quote and label"
    so_that: "the money decision lives in exactly one tested place"
    risk: high
    status: planned
  - id: S1.4
    title: "Admin «Tienda de prueba» toggle + sandbox environment"
    as_a: "Daniel"
    i_want: "to mark a shop as a test shop so it can connect an Envía sandbox key"
    so_that: "I can test labels and tracking without paying for real labels"
    risk: high
    status: planned
---
# BYO Envía connect — Sprint 1: The connection

**Status:** ⬜ not started

## Stories

### Story 1.1 — envia_connection model + shared AES-GCM lib + Medusa migration
**As** the platform, **I want** a per-seller Envía connection stored encrypted in Medusa, **so that** a merchant's key is safe at rest and only the backend can ever read it.
**Acceptance:** `envia_connection` on the seller module: `seller_id` (unique), `provider` (`envia`), `token_enc`, `environment` (`production` | `sandbox`), `status` (connected / disconnected / invalid), `webhook_ids`, `webhook_bearer_hash`, `connected_at`, `last_validated_at`. `encryptToken`/`decryptToken` hoisted from `modules/mercadolibre/_utils.ts` to a shared backend lib, Mercado Libre re-pointed at it with its specs green. A tampered ciphertext decrypts to `''`. The Medusa migration is generated here; how it runs on the VM is confirmed before merge.
**Risk:** high

### Story 1.2 — Validate-then-save and disconnect routes, write-only, rate-limited
**As** a merchant, **I want** to paste my Envía key, have it checked, and disconnect whenever I want, **so that** a wrong key never gets saved and my key is never shown back to me.
**Acceptance:** `POST /store/sellers/me/envia-connection` makes one cheap authenticated Envía Queries call; failure saves nothing and returns an es-MX error; success stores only ciphertext. `GET` returns status, environment, `last_validated_at` and `••••`, never the token. `DELETE` clears the token and marks disconnected at once. Rate-limited per seller. A spec reads every response and the DB row for the fixture token's plaintext and finds none.
**Risk:** high

### Story 1.3 — Pure credential resolution seam + truth-table spec
**As** the platform, **I want** one pure function that decides whose Envía account pays for every quote and label, **so that** the money decision lives in exactly one tested place.
**Acceptance:** Extends `lib/envia-killswitch.ts`: inputs (connection status, decrypt ok, environment allowed, `shipping.envia_enabled`, comp-grant) → `seller_token` | `platform_key` | `none`. One spec row per combination, each observed red under a mutation; a connected seller whose key fails is never mapped to `platform_key`; an invalid or tampered connection falls to the platform rule, never to a silent seller pass.
**Risk:** high

### Story 1.4 — Admin «Tienda de prueba» toggle + sandbox environment
**As** Daniel, **I want** to mark a shop as a test shop so it can connect an Envía sandbox key, **so that** I can test labels and tracking without paying for real labels.
**Acceptance:** A toggle in admin tenants sets a backend-only test marker (same internal-route pattern as the comp-grant). Validation accepts a sandbox key only for a marked shop, against Envía's sandbox host; a real shop's sandbox key is refused with «Esa clave es de pruebas. Pega una clave de producción.». A test shop's labels, order pages and buyer emails say PRUEBA.
**Risk:** high

## Sprint QA
- **backend unit specs:** shared AES-GCM lib (round-trip, tamper → `''`), resolution truth table, environment rule; each observed red under a mutation
- **api specs:** connection routes (validate fails → nothing saved; token never in any response; disconnect immediate; rate limit)
- **browser smoke owed:** the admin step below, to Daniel
- **review:** fresh pr-reviewer + codex cross-family pass + the security lens (credential storage)
- **deterministic gate:** backend `npm test` + money-path CI gate; frontend `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. (admin) Open https://miyagisanchez.com/admin/tenants, pick the QA test shop and turn on «Tienda de prueba»
   → the shop shows a PRUEBA badge
2. Signed in as that shop, call the connection API with a wrong key (or use the settings card once S3.1 lands)
   → an es-MX error; the connection stays «No conectada»
3. Repeat with a valid Envía sandbox key
   → «Conectada» with environment sandbox and today's date; the key is shown as •••• only
4. (orchestrator) Read the `envia_connection` row
   → only ciphertext; no plaintext anywhere
5. On a shop without the test flag, try the same sandbox key
   → refused: «Esa clave es de pruebas…»
6. Disconnect
   → status «No conectada» at once

If any step fails, note the step number + what you saw — that's the bug report.
