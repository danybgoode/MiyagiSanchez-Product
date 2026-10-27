---
epic: envia-byo-connect
sprint: 3
title: "Connect like Mercado Pago"
risk: low
phase: Shaping
stories_total: 3
stories:
  - id: S3.1
    title: "Envíos connect card with the three-step guide"
    as_a: "a merchant in Envíos settings"
    i_want: "a card that walks me through creating, funding and copying my Envía key, then tests it"
    so_that: "connecting feels as easy as Mercado Pago, even without OAuth"
    risk: low
    status: planned
  - id: S3.2
    title: "«Paquetería con tu cuenta Envía» in the prompt-to-shop delivery chooser"
    as_a: "a new merchant on the delivery step"
    i_want: "to pick «Paquetería con tu cuenta Envía» and connect right there"
    so_that: "I get real carrier shipping while setting up my shop"
    risk: low
    status: planned
  - id: S3.3
    title: "Agent parity specs + the connect deep link in the agent setup sheet"
    as_a: "a seller's AI agent"
    i_want: "to quote and ship for a connected shop with the same shapes as the web, and to point my human at the connect screen"
    so_that: "agents get BYO Envía without ever handling a key"
    risk: low
    status: planned
---
# BYO Envía connect — Sprint 3: Connect like Mercado Pago

**Status:** ⬜ not started

## Stories

### Story 3.1 — Envíos connect card with the three-step guide
**As** a merchant in Envíos settings, **I want** a card that walks me through creating, funding and copying my Envía key, then tests it, **so that** connecting feels as easy as Mercado Pago, even without OAuth.
**Acceptance:** Its own component in Envíos settings (not more lines in `Envios.tsx`): «Paquetería con tu cuenta Envía», the line «Tú pagas tus guías desde tu saldo en Envía. Nosotros no tocamos ese dinero.», steps 1–3 with deep links (signup, balance, Developer → API Keys), the paste field and «Probar conexión» with idle / validating / error / connected states from the seed's surface blocks; connected shows ••••, the check date, «Cambiar clave» and «Desconectar». Shared `Card` / `Button` / `StatusBadge`, Iconoir, no emoji; 375 px first.
**Risk:** low

### Story 3.2 — «Paquetería con tu cuenta Envía» in the prompt-to-shop delivery chooser
**As** a new merchant on the delivery step, **I want** to pick «Paquetería con tu cuenta Envía» and connect right there, **so that** I get real carrier shipping while setting up my shop.
**Acceptance:** prompt-to-shop's `/sell/armar/cobros` chooser gains the option with carrier logos; it opens the same connect sheet as S3.1; once connected, the buyer-checkout preview shows carrier shipping. Needs prompt-to-shop S5.1 merged; if not, this story waits.
**Risk:** low

### Story 3.3 — Agent parity specs + the connect deep link in the agent setup sheet
**As** a seller's AI agent, **I want** to quote and ship for a connected shop with the same shapes as the web, and to point my human at the connect screen, **so that** agents get BYO Envía without ever handling a key.
**Acceptance:** `api` specs: UCP `checkout-session` and MCP `get_checkout_options` for a connected shop return the seller-rate shapes; MCP ship returns the label as on the web; no MCP tool accepts or returns a token; the agent setup sheet gains a «Conecta tu Envía» link to the settings card.
**Risk:** low

## Sprint QA
- **api specs:** agent parity (UCP + MCP) and no-token-in-any-tool
- **browser smoke owed:** yes, to Daniel: the phone walkthrough below
- **rails:** emoji guard, Tailwind JIT arbitrary-value guard, es-MX copy completeness
- **deterministic gate:** backend `npm test` + money-path CI gate; frontend `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. On a phone, as the test shop, open https://miyagisanchez.com/shop/manage/settings and go to Envíos
   → the «Paquetería con tu cuenta Envía» card with three steps
2. Tap each step's link
   → they open Envía's signup, balance and API-keys pages
3. Paste a wrong key and tap «Probar conexión»
   → «Probando…», then the error; nothing saved
4. Paste the sandbox key
   → «Conectada ✓», ••••, today's date, PRUEBA badge
5. In a new shop's setup, open https://miyagisanchez.com/sell/armar/cobros
   → «Paquetería con tu cuenta Envía» is offered and opens the same connect sheet
6. Ask your agent to quote shipping for a product from the connected shop
   → it returns the shop's carrier rates

If any step fails, note the step number + what you saw — that's the bug report.
