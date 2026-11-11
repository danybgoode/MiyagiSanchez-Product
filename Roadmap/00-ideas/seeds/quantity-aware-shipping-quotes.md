---
title: "Shipping quotes that count units: a 5-unit order is quoted as one package today"
slug: quantity-aware-shipping-quotes
status: raw
area: "04"
type: bug
priority: null
risk: high
epic: null
build_order: null
updated: 2026-11-11
---

# Raw seed: quantity-aware shipping quotes

Found in the checkout-trust-hardening review (2026-11-11). Backend `envia/rates/route.ts` builds one package per
DISTINCT product (`shippable.map`, ~line 269), queries `id IN listingIds` (de-duplicated), and the storefront sends only
product ids (`CheckoutExperience.tsx` ~370). A 5-unit order is quoted, and charged, as one unit: the seller absorbs
the extra packages, and for Correos («priced per piece») (qty − 1) × the per-piece tariff.

Fix: send quantities with the rate request, build packages per unit (or per seller packing rule), and once the quote
counts units, bind quantity into the signed quote (`shipping-quote-signature.ts`).
