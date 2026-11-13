---
title: "Show the product, not a wall of text: real example shops on our templates, and features as they look"
slug: show-the-product-not-a-wall-of-text
status: raw
area: "08-growth-and-promotions"
type: feature
appetite: null
underwritten_by: null
risk: low
epic: null
build_order: null
updated: 2026-11-12
intent_ask: verbatim
hypothesis: null
persona: "A small merchant, in Mexico or the US, deciding whether this is the shop they want"
grounded: false
grounded_reason: "No North Star strategy exists in Roadmap/00-strategy/."
target_metric: null
target_from: null
target_to: null
read_date: null
flag_key: null
target_segment: null
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
satisfied_min_score: null
intent_match: null
---

# Idea — Show the product, not a wall of text

Moves · Tests: not grounded — no strategy yet

Split out of `one-front-door-both-markets` (2026-11-12, product owner: "yes to all" on three epics).

## The ask, as given

> in the landing pages, where we show the example shops, we are showing just something very generic, we must use our own templates, with different colors layouts etc to actually show example shops
> The section Lo que tu tienda ya hace should be renamed Lo que tu tienda hace
> And this section in particular need to show actual features from the product and how they look like instead of a wall of text or marketing visualisations of the features, never a wall of text.
> all of this cascades to the us pages.

(The rename itself ships in `one-front-door-both-markets` S3.3.)

## What we know (verified on storefront `origin/main` b8729e5, 2026-11-12)

- Example shops today: `DemoShopSection` (`SellerAcquisitionSections.tsx:1147`) — a text card with a badge, a name, a tagline and a bullet list.
- Templates that exist: 6 theme presets in `lib/shop-settings/theme-presets.ts` (Clásico, Papel, Pizarra, Lienzo, Terracota, Retro Social) + the Living Shop wall layout (`lib/shop-presentation`).
- «Lo que tu tienda ya hace» (`locales/es.json` `features`): six paragraphs of prose with a «Dónde:» URL list.
- Rule to keep: a real merchant appears only with written consent (`BusinessProofSlot`); a demo shop is labelled as an example, never passed off as real.

## Direction (to refine)

- Seeded demo shops — one per persona, each on a different preset and palette, excluded from the marketplace, clearly «Ejemplo».
- The feature section rendered from the real components with demo data, or captured by a Playwright script that regenerates — never hand-made screenshots.
- Same for the US pages, in English and Spanish.
