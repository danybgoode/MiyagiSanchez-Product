---
title: "Business data consolidation — one place for the tools a business already uses"
slug: business-data-consolidation
status: raw
area: "03"
type: epic
priority: null
risk: high
epic: null
build_order: null
updated: 2026-11-03
---

# Raw seed — Business data consolidation + automation

## The ask, as given

Split out of `business-infrastructure-productize-anything` at refine (2026-11-03). The product owner's words:

> data and automation meant allowing them to consolidate data sources used by their business (could be a cms, crm, a
> simple excel, quickbooks or other accounting tools) and automation refered to automate the data flows and
> consolidation of their management from a single point. agree that it could be refined on its own

## Opportunity

A merchant's business data lives in several places: a spreadsheet of costs, a CRM or a WhatsApp contact list, a CMS,
QuickBooks or another accounting tool. Miyagi already holds the shop, the orders and the per-sale ledger. Connecting
the rest, and automating the flows between them, makes Miyagi the one place the business is managed from.

## What exists to build on

- Mercado Libre sync (OAuth, encrypted tokens, two-way stock) — the connector pattern.
- Bulk import / Storefront-as-Code / Shopify connector — file and platform intake.
- Profit Analyzer ledger — the financial spine a consolidation would feed.
- "Tus números" (from `business-infrastructure-productize-anything`) — the first consumer of outside cost data.

## Open questions for refine

- Which source first: a Google Sheet / Excel of costs, a CRM, or an accounting tool (QuickBooks, Contpaqi, Alegra)?
- One-way intake or two-way sync? Who owns the record when both sides change?
- How it relates to `spike-cfdi-autopilot` (accounting tools and CFDI overlap).
- "Automation": rules the merchant writes, or flows Miyagi proposes from the data?
