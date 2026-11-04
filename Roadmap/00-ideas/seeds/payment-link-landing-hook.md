---
title: "«Crea tu link de pago» on the landing page — payment links as the way in"
slug: payment-link-landing-hook
status: raw
area: "02"
type: feature
priority: null
risk: high
epic: null
build_order: null
updated: 2026-11-04
---

# Raw seed — Payment links as the way in

## Opportunity

T1's home page leads with a small box: «Monto a cobrar» and «¿Qué quieres cobrar?», then «Crea tu link de pago»,
which opens sign-up. Its FAQ adds «No necesitas una tienda». A micro-merchant who would never "build a shop" will
create a link to get paid for one thing today. (Source: t1.com/mx/pagos, read 2026-11-04.)

## What we already have — do not rebuild

- **Payment links shipped on 2026-10-31** (`02-checkout-and-payments/in-person-sales`, S4): «Cobrar con un link», the
  public page `/pagar/<token>`, links for a product or for any amount with a concept, a short link (`mschz.org`), a QR
  code, WhatsApp sharing, and the MCP tools `create_payment_link` and `list_payment_links`. The money goes to the
  shop's own Stripe or Mercado Pago account.
- **The support widget** («apóyame», similar to Buy Me a Coffee): `/api/embed/support` and its checkout.
- **Prompt-to-shop** already starts before sign-up and saves a draft to the device.

## What is new

The way in, not the link itself. Put the amount-and-concept box on `/` and `/mx/vende`. Typing the amount and
concept starts sign-up, which creates the shop quietly, then the payment method, then the link is ready to share.
That shop is a Gratis shop the merchant can grow later. Promoters can use the same box in person: «Te hago tu
primer link de cobro».

## Open questions for refine

- Can a link exist before the merchant has connected a payment method? (Today the shop needs Stripe or Mercado
  Pago to take card payments; SPEI to their own CLABE works without either.)
- Meses sin intereses on links, through the merchant's own Mercado Pago or Stripe installments.
- What the auto-created shop looks like when it has only a link and no products.
- Owed from in-person sales and still not done: one real low-value link charge.
