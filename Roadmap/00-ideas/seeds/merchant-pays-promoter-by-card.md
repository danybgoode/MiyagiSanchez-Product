---
title: "A merchant pays a promoter's package by card, through Miyagi Sánchez"
slug: merchant-pays-promoter-by-card
status: raw
area: "08-growth-and-promotions"
type: feature
priority: null
risk: high
epic: null
build_order: null
updated: 2026-11-05
---

# Raw seed — the merchant pays by card, not the promoter

## Opportunity
Today a merchant can only pay the promoter directly (cash, a transfer, whatever they agree), and the promoter pays
Miyagi Sánchez only its share, by transfer or with their own card ("settled at source", plans-gratis-negocio D12). A
merchant without cash, or one who wants interest-free installments, has no way to pay. Daniel, 2026-11-05: "save card
option for later".

## The trade-off to decide before shaping
- Miyagi Sánchez would collect the full price, so it would **owe the promoter their commission**: payouts, a ledger
  and a schedule. That is the commission accrual the current design deliberately removed.
- Stripe's fee (about 3.6% + $3 MXN, roughly $75 on $2,000) comes out of someone's share; decide whose.
- Installments (meses sin intereses) on a one-time card payment are possible, and cost more.

## What already exists — do not rebuild
- Package checkout for the platform's share: `lib/promoter-package-server.ts` (`startPackageCardCheckout`), the webhook
  `handlePromoterPackageComplete`.
- One-time checkouts with installments: `lib/stripe-subscriptions.ts` (`createOneTimeCheckout`, `installments`).
- The commission ledger and admin settlement: `marketplace_promoter_attributions`, `/admin/promoter`.
- The merchant receipt page from the promoter-panel epic.

## Signal that would make it worth shaping
Promoters reporting merchants who wanted to buy but had no cash on them.
