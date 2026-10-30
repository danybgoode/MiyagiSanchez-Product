---
epic: in-person-sales
sprint: 4
title: "Payment links"
risk: high
phase: Verifying
stories_total: 4
stories:
  - id: S4.1
    title: "payment_link model + create/cancel routes"
    as_a: "a merchant"
    i_want: "to create a link for products or for any amount with a concept, and cancel it"
    so_that: "I can charge anyone without them browsing my shop"
    risk: high
    status: done
  - id: S4.2
    title: "/pagar/[token] → cart → existing checkout; free amount as a custom line"
    as_a: "a buyer who got a payment link"
    i_want: "to open it and pay with the shop's usual methods"
    so_that: "paying the merchant is as easy as an online purchase"
    risk: high
    status: done
  - id: S4.3
    title: "«Cobrar con un link» UI + shares + statuses"
    as_a: "a merchant"
    i_want: "a screen to make links, share them by WhatsApp, QR or short link, and see which were paid"
    so_that: "I chase fewer payments"
    risk: low
    status: done
  - id: S4.4
    title: "MCP payment-link tools for seller agents"
    as_a: "a seller's AI agent"
    i_want: "to create, list and cancel payment links for my shop"
    so_that: "my agent can charge customers in chat for me"
    risk: low
    status: done
---
# In person — Sprint 4: Payment links

**Status:** merged 2026-10-31, **deploy owed**. Backend MiyagiSanchez-Backend#221 → `ba22692`, storefront
MiyagiSanchez-Storefront#461 → `8fd0046`.

**Verified:** the money-path gate covers a free-amount link priced on the hidden product, a pending transfer that
blocks a second buyer, the seller's confirmation that closes the link, a multi-use link giving a fresh cart per
opener, the single-use hold, the cart lock over HTTP, a changed cart being refused, a closed link being refused, and
a cart that skipped checkout being refused. Pay-page, cobros and MCP specs are mutation-observed. Codex ran 10 rounds
on the backend and 4 on the storefront, and the fresh verifier ran on both.

**Owed to Daniel:** the walkthrough below, the test-mode link payment and **one real low-value link charge**.

## Stories

### Story 4.1 — payment_link model + create/cancel routes
**As** a merchant, **I want** to create a link for products or for any amount with a concept, and cancel it, **so that** I can charge anyone without them browsing my shop.
**Acceptance:** A Medusa `payment_link` model (seller-owned): random unguessable token, kind `products` | `amount`, lines or concept + amount (server-validated min/max), `uses: single | multi` (single default), `expires_at` (7 days default), status `pending | paid | expired | cancelled`; create, list and cancel routes for the authenticated seller only. Medusa migration, orchestrator-run at deploy.
**Risk:** high

### Story 4.2 — /pagar/[token] → cart → existing checkout; free amount as a custom line
**As** a buyer who got a payment link, **I want** to open it and pay with the shop's usual methods, **so that** paying the merchant is as easy as an online purchase.
**Acceptance:** `/pagar/[token]` shows the shop, the concept or products and the amount, then builds a cart on the operating channel (`source: payment_link`) and hands off to the existing checkout. A free amount is a Medusa custom line item (title = concept, unit price = amount, no variant; confirmed at the lock through each provider). Paid single-use → «Este cobro ya se pagó.»; expired → «Este link ya venció…»; cancelled can't be paid; a multi-use product link makes a fresh cart per opener. `noindex`, `private`.
**Risk:** high

### Story 4.3 — «Cobrar con un link» UI + shares + statuses
**As** a merchant, **I want** a screen to make links, share them by WhatsApp, QR or short link, and see which were paid, **so that** I chase fewer payments.
**Acceptance:** `/shop/manage/cobros` from the seed's surface block: toggle «Productos» | «Cobro libre», options, the result with WhatsApp share, QR and `mschz.org` short link; a list with statuses and «Cancelar».
**Risk:** low

### Story 4.4 — MCP payment-link tools for seller agents
**As** a seller's AI agent, **I want** to create, list and cancel payment links for my shop, **so that** my agent can charge customers in chat for me.
**Acceptance:** MCP `create_payment_link`, `list_payment_links`, `cancel_payment_link`, scoped to the authenticated seller's own shop (another shop is refused, spec); returns the link and short link; same validation as the web.
**Risk:** low

## Sprint QA
- **backend integration:** free-amount link paid → one paid order with a custom line + link marked paid; single-use reopen; expired; cancelled; multi-use fresh carts
- **api specs:** token unguessability/format; MCP scoping
- **browser smoke owed:** yes, to Daniel by name: the test-mode link payment and **one real low-value charge**
- **review:** fresh pr-reviewer + codex cross-family pass + the security lens
- **deterministic gate:** backend `npm test` + money-path CI gate; frontend `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 4 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. Open https://miyagisanchez.com/shop/manage/cobros and make a «Cobro libre»: «Anticipo pastel» · $800
   → a link, a QR and «Compartir por WhatsApp»
2. Open the link on another phone
   → the shop, «Anticipo pastel», $800 and the shop's payment methods
3. (money, owed to Daniel) Pay it with a test card
   → one paid order for $800; the link shows «Pagado»
4. Open the link again
   → «Este cobro ya se pagó.»
5. Make a link for two products, «Varios pagos», and open it twice
   → each opener gets a fresh cart with both products
6. Ask your agent to make a $250 link for «Envío especial»
   → it returns a working link for your shop
7. (money, owed to Daniel) Pay one real low-value link
   → the money lands in the shop's own account

If any step fails, note the step number + what you saw — that's the bug report.
