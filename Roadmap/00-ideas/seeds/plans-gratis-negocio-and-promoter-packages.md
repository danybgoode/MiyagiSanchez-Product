---
title: "Two plans (Gratis + Negocio), a 30-day trial, and three promoter packages"
slug: plans-gratis-negocio-and-promoter-packages
status: raw
area: "08"
type: epic
priority: null
risk: high
epic: null
build_order: null
updated: 2026-11-04
---

# Raw seed — Two plans, a trial, and promoter packages

> Captured from a pricing-strategy conversation with Daniel on 2026-11-04. Decisions marked **(Daniel)** are his;
> everything else is a proposal still to be refined (`golden-frijoles:refine`).

## Problem

What a merchant can buy today is a menu, not a ladder: a free shop plus five separate add-ons (subdomain $199/yr,
custom domain $499/yr, Mercado Libre sync $299/yr, print ad, migration). Every price is small. A promoter's
commission is a percentage of those small prices, and in the code every rate defaults to 0%
(`lib/promoter-commission.ts` `DEFAULT_COMMISSION_RATES`). The AI that runs every month (shop chat, check-in) is free
for every shop, with no per-plan limit, so its cost grows with use and earns nothing.

Facts checked on 2026-11-04:

- The subdomain paywall is the flag `subdomain.paywall_enabled` in the Golden Frijoles project for Miyagi Sánchez (`miyagisanchez`), and it is
  **ON** (Daniel, 2026-11-04). Shops that existed at the cutover keep their subdomain for free; every shop created
  since, including every shop a promoter opens, is sent to `/s/<slug>` unless it pays. Switching it off is the first
  step of the free plan. `/mx/precios` lists the subdomain at $199/yr.
- The platform bills its own products only through Stripe (`lib/stripe-subscriptions.ts`). The print ad also takes
  Mercado Pago.
- A promoter's cash sale works one of two ways. The promoter collects cash and pays the platform by card through
  Stripe checkout. Or the promoter keeps their cut and sends the rest by SPEI, DiMo or CoDi. That second path is
  built behind `promoter.transfer_enabled`, which is ON (Daniel, 2026-11-04), so it is available.
  `promoter.enabled` is on: `/promotor/cerrar` asks for sign-in instead of returning a 404.

## Direction

- **Two plans (Daniel).** Gratis and Negocio. No Pro until there is value that only Pro would have.
- **Gratis, forever.** Shop, URL **and subdomain** (Daniel), 0% commission, every payment method, marketplace,
  messages, agents (UCP/MCP). The AI that builds the shop stays free, because it is what brings merchants in.
  Shop chat has a small monthly allowance; past it, the chat falls back to «Deja tu mensaje». A small «Hecho con
  Miyagi Sánchez» badge stays on (proposal).
- **Negocio, about $149/mo or $1,490/yr (Daniel: OK).** Includes the custom domain and Mercado Libre sync
  (Daniel), removes the badge, raises the chat allowance, and adds the monthly check-in and more AI drafts and
  photos.
- **30-day trial of Negocio for every new shop.** No card. On day 31 the shop drops to Gratis and stays live. The
  custom domain is not part of the trial.
- **Existing paid merchants keep what they paid for (Daniel).**
- **AI is limited by amount, not switched off.** Gratis gets some of every AI feature; Negocio gets more. Before
  fixing the numbers, log what each shop's AI actually costs.

## Promoter packages (proposal)

| Package | Merchant pays the promoter | Promoter sends the platform | Promoter keeps |
| --- | --- | --- | --- |
| Anual: setup + 12 months of Negocio (Daniel: OK) | $2,000 | $900 | $1,100 |
| Arranque: setup + 3 months of Negocio | $600 | $300 | $300 |
| Gratis: setup on the free plan (Daniel) | $250 (or $200) | $50 | $200 (or $150) |

- **No bounty on top (Daniel).** The $50 pays for the training, leads and uniforms the platform provides.
- If the shop moves to Negocio within 90 days, the promoter earns the Anual or Arranque split, credited through
  their code.
- The promoter's existing relationship records (consent, history, interactions) become their follow-up list.
- **For the first promoter, settlement is manual (Daniel).** The promoter sends the $50 by SPEI, or pays by card on
  the platform, and messages Daniel. There is no setup-fee item in the system yet.

### Gaps found in the promoter workspace (`/promotor/cerrar`, 2026-11-04)

- **Products are added by hand, one at a time** (`ListingStep`). Prompt-to-shop (build a shop from photos with AI)
  does not know about promoters. Bring its photo-to-products step into the workspace, so the shop the promoter opens
  is filled in minutes.
- **A shop built in prompt-to-shop is not linked to the promoter.** If the promoter builds it signed in as
  themselves, the promoter owns the shop. If it is built on the merchant's phone, the merchant owns it but nothing
  links it to the promoter, so it never appears among their leads or earns them credit when it upgrades. The
  promoter's code is recorded only when one of the paid items is sold.
- **The free-plan setup fee is not something the workspace can record or settle.** The workspace can only sell the
  paid items (custom domain, subdomain, ML sync, print ad, migration). Add the setup fee as an item, with SPEI or card
  settlement, once there is more than one promoter.
- Renewals: whether the promoter earns a share when a merchant renews is still open.

## Open questions for refine

- Meses sin intereses for the yearly plan: Stripe card installments in Mexico, or Mercado Pago as a second processor
  for the platform's own billing.
- Exact AI allowances, measured from real cost.
- How the free subdomain changes `/mx/precios`, the promoter rate card, and the subdomain and ML-sync sale routes.
