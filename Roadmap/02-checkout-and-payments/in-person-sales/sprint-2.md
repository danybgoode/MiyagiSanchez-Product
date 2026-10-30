---
epic: in-person-sales
sprint: 2
title: "QR and transfers"
risk: high
phase: Shipped
stories_total: 3
stories:
  - id: S2.1
    title: "QR card payment through the shop's checkout + wait for the webhook"
    as_a: "a merchant whose buyer wants to pay by card"
    i_want: "to show a QR the buyer scans and pays on their own phone, and see the counter turn green when it's paid"
    so_that: "I take cards without a terminal"
    risk: high
    status: done
  - id: S2.2
    title: "SPEI / DiMo at the counter + «Ya me llegó» capture"
    as_a: "a merchant whose buyer pays by transfer"
    i_want: "to show my CLABE or DiMo QR and confirm when the money arrived"
    so_that: "transfers are recorded like any other sale"
    risk: high
    status: done
  - id: S2.3
    title: "Inbox + Ganancias source, no self-notifications, optional buyer receipt"
    as_a: "a merchant"
    i_want: "my counter sales beside my online orders, without emails about sales I rang up myself, and a receipt for the buyer when they want one"
    so_that: "I see everything in one place without noise"
    risk: low
    status: done
---
# In person — Sprint 2: QR and transfers

**Status:** ✅ shipped 2026-10-31: merged and deployed (`update.sh`: Backend `ba22692`, Storefront `8fd0046`). Backend MiyagiSanchez-Backend#218 → `211b8db`, storefront MiyagiSanchez-Storefront#459 → `bae1775`.
Shipped alongside: #217 → `b258f70` (the «Pago directo» region repair route, **deployed**; its production run is owed
to Daniel) and #219 → `397b56d` (Stripe payments verified with Stripe and bound to their checkout; a live hole found
in this sprint's review; deployed 2026-10-31).

**Verified:** the money-path CI gate covers card and transfer counter sales against a real database. It checks one
cart per sale, that a card sale is never paid without a processor-confirmed order, cancelling with a payment in
flight, a cancelled transfer, the cart lock over HTTP, and the swapped-session exploit. Codex ran 10 rounds and the
fresh verifier ran on both PRs.

**Owed to Daniel:** the walkthrough below. Test-mode card QR payment by name. Transfers need the region repair run
first.

## Stories

### Story 2.1 — QR card payment through the shop's checkout + wait for the webhook
**As** a merchant whose buyer wants to pay by card, **I want** to show a QR the buyer scans and pays on their own phone, and see the counter turn green when it's paid, **so that** I take cards without a terminal.
**Acceptance:** The counter creates a cart for the sale, runs `start-checkout` for the shop's Mercado Pago or Stripe provider and shows `checkout_url` as a QR; it turns green only when the existing webhook (MP IPN / Stripe) marks the order paid, never on a client signal. Cancel and session expiry leave no paid order and release nothing that was never reserved. Tested in test mode through the money-path CI gate.
**Risk:** high

### Story 2.2 — SPEI / DiMo at the counter + «Ya me llegó» capture
**As** a merchant whose buyer pays by transfer, **I want** to show my CLABE or DiMo QR and confirm when the money arrived, **so that** transfers are recorded like any other sale.
**Acceptance:** The counter shows the shop's CLABE (copy) or DiMo QR with the amount, creating the order in `pending_payment` via `lib/manual-payment-state.ts`; «Ya me llegó» moves it to `payment_confirmed` and captures. Nothing is auto-confirmed.
**Risk:** high

### Story 2.3 — Inbox + Ganancias source, no self-notifications, optional buyer receipt
**As** a merchant, **I want** my counter sales beside my online orders, without emails about sales I rang up myself, and a receipt for the buyer when they want one, **so that** I see everything in one place without noise.
**Acceptance:** Orders inbox and detail show an «En persona» badge and filter; Ganancias splits by source; the in-person source suppresses seller self-notifications only; an optional «Mandar recibo» by WhatsApp (`lib/share-link.ts`) or email to an address the merchant types. No server `fetch()` to our own authed routes.
**Risk:** low

## Sprint QA
- **backend integration:** QR checkout paid only by webhook; cancel/expiry → no paid order; SPEI/DiMo pending → confirmed
- **api specs:** no seller notification for `in_person`; source filter
- **browser smoke owed:** yes, to Daniel by name: the test-mode card QR payment
- **review:** fresh pr-reviewer + codex cross-family pass + the security lens
- **deterministic gate:** backend `npm test` + money-path CI gate; frontend `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. On the counter at https://miyagisanchez.com/shop/manage/en-persona, add a product and tap «Tarjeta o Mercado Pago»
   → a big QR and «Esperando el pago…»
2. (money, owed to Daniel) Scan it with another phone and pay with a test card
   → the counter turns «Pagado ✓»; the order is paid
3. Start another QR sale and tap «Cancelar»
   → no paid order; the counter is back to the cart
4. Ring up a sale by «Transferencia»
   → your CLABE or DiMo QR with the amount
5. Tap «Ya me llegó»
   → the order is confirmed
6. Check your email
   → no «nueva venta» email for these counter sales
7. Send a receipt by WhatsApp from a sale
   → WhatsApp opens with the receipt text

If any step fails, note the step number + what you saw — that's the bug report.
