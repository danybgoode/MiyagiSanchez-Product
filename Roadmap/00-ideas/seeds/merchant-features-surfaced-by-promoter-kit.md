---
title: "What the promoter kit review surfaced: package the features merchants cannot see, and fix the gaps"
slug: merchant-features-surfaced-by-promoter-kit
status: raw
area: "08"
type: epic
priority: null
risk: low
epic: null
build_order: null
updated: 2026-11-11
---

# Raw seed: what the promoter kit review surfaced

Daniel reviewed the promoter field kit on 2026-11-11. The kit shipped the next morning: the deck, guide, test and
operations plan, plus the founders' price (storefront #488). Many of his notes were about the product, not the kit.
They are kept here so they reach a refine pass. This sits beside the site repositioning, which is already planned
in the decision doc of 2026-11-09.

## Gaps confirmed in the code (2026-11-11, storefront `ef400ae`)

1. **Seat limits for events and services.** The sell wizard asks for «Cantidad disponible» only for a physical product.
   The relevant line is `quantity: listingType === 'product' ? … : undefined` in `app/(shell)/sell/SellWizard.tsx`.
   An event listing (a play, an experience) does have a buyer quantity selector (`lib/ticket-quantity.ts`,
   `events.quantity_enabled` ON), but it is capped by Medusa inventory only when inventory is tracked. The wizard never
   lets the merchant set the number of seats, so an event can oversell up to 20 per order with no total limit.
   Services book through Cal.com (`lib/service-hero.ts`), so Cal.com enforces their capacity, not us.
2. **Eventos duplicates listings.** `/shop/manage/eventos` is a separate system (`marketplace_events`) for free
   RSVP events, with its own `capacity`. The paid event listing is a second system. Daniel's view: an event is just
   another product, free or paid. Decide whether to fold RSVP events into the listing type.
3. **/shop/manage/comparte is unreachable.** It has no sidebar link (`lib/seller-nav.ts`). It holds the WhatsApp
   share, the catalog PDF and the Meta feed, plus a second copy of the agent connection panel (`ConnectAgentPanel`,
   also in Configuración › Agentes). Proposal: move share/PDF/Meta into «Canales» with the right information
   architecture, and keep the agent connection in one home (Configuración › Agentes).

## Undersold today: package and name them

- **Financial intelligence:** «Tu plan», «Analíticas» and «Ganancias» (`ops.profit_enabled` ON) as one story:
  how much you earn, not just how much you sell.
- **Omnichannel, in our own words:** one inventory for every counter. That covers the shop, WhatsApp, the catalog
  PDF, the Meta catalog, Mercado Libre sync and the in-person counter (POS: cash, card or transfer, with an offline
  cash queue). We never say it.
- **Offers and haggling:** the buyer proposes a price; the merchant accepts or counters, and automatic rules can do
  it for them (Configuración › Negociación). It fits Mexican commerce well and nothing on the site explains it.
- **AI:** shop chat, Import (photo, list, Excel, Mercado Libre), and the merchant's own agent through the personal MCP
  URL. The MCP already has `about_miyagi`, `compare_costs` and `send_feedback`. Advertise the merchant's own agent as
  their support channel.
- **Sorteos** (free sweepstakes) for promotions such as Buen Fin and Christmas.
- **«Get your business online»** as the main hook for businesses with no presence beyond Google Maps: the Wall plus
  the shop. The custom static pages idea is a later seed.

## Field loop

The promoters' daily discovery report (guide section 9, ops plan 6b) will produce requests. Decide where they land so
they are counted, not just read in WhatsApp. Options: the MCP `send_feedback` stream, or a small tracker page.

## Owed decisions

- Fold Eventos into listings, or keep two systems.
- Where Comparte's pieces live.
- Whether the merchant's agent is advertised as a support channel on the pricing page.
