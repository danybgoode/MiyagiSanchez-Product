---
epic: business-infrastructure
sprint: 4
title: "The shop answers"
risk: high
phase: Shipped
stories_total: 3
stories:
  - id: S4.1
    title: "The shop's chat"
    as_a: "a buyer on a shop"
    i_want: "to ask a question in my own words and get the shop's own answer"
    so_that: "I can decide to buy without waiting for the owner"
    risk: high
    status: done
  - id: S4.2
    title: "Everywhere the shop is, and for agents"
    as_a: "a buyer on any of the shop's channels, or a buyer's agent"
    i_want: "the same answers on the shop, the product page, the shop's own domain, the embed and over MCP"
    so_that: "the shop answers wherever I meet it"
    risk: high
    status: done
  - id: S4.3
    title: "FAQ written at describe, editable"
    as_a: "a merchant"
    i_want: "my shop's frequent questions written for me when I describe it, and editable later"
    so_that: "the chat can answer from day one"
    risk: low
    status: done
---
# Business infrastructure — Sprint 4: The shop answers

**Status:** ✅ shipped · **Merged:** danybgoode/MiyagiSanchez-Storefront#469

## Build contract (locked by the architect before the builder started)
Cite D13–D16. Port from `~/dobby/bonsai-chat/server.mjs` (system prompt rules, SSE frames `{t:'text'|'action'|'done'|
'error'}`, tool loop with Gemini thought signatures kept verbatim, history cap) into `lib/shop-chat/` (pure) +
`app/api/shop-chat/[slug]/route.ts` (I/O). Knowledge = the seller's settings `faq`/`about`/`returns_policy` +
cobros/entregas + a catalog snapshot from `getShop` at request time. Shop from the path slug only; preview-private and
unclaimed shops answer 404. Guards: `lib/ratelimit.ts` per IP and per shop, Turnstile at chat start (a short-lived
signed chat token after), `spend_ai_allowance(kind 'shop_chat')` per shop/day and global/day, fail closed. Tenancy
spec: shop A's chat never sees shop B's knowledge. `ask_shop` shares the same core, non-streaming. The FAQ generated at
describe is a draft field on `words` (no new block), applied at keep through the existing claim manifest
(`content.faq`, ≤ 12 items, validator unchanged).

## Stories

### Story 4.1 — The shop's chat ✅ danybgoode/MiyagiSanchez-Storefront#469
**As a** buyer on a shop, **I want** to ask a question in my own words and get the shop's own answer, **so that** I
can decide to buy without waiting for the owner.
**Acceptance:** the chat answers from the shop's FAQ, policies, cobros/entregas and catalog; prices and stock match
the shop page; a question it cannot answer gets «no sé» and the offer to leave a message; a spec proves shop A never
answers from shop B; the rate limit and daily cap refuse politely.
**Risk:** high (public AI endpoint, tenancy)

### Story 4.2 — Everywhere the shop is, and for agents ✅ danybgoode/MiyagiSanchez-Storefront#469
**As a** buyer on any of the shop's channels, or a buyer's agent, **I want** the same answers on the shop, the product
page, the shop's own domain, the embed and over MCP, **so that** the shop answers wherever I meet it.
**Acceptance:** the launcher renders on `/s/<slug>`, a product page, a subdomain and the embed, clear of the tab bar;
`ask_shop` is listed in the MCP tools and the manifest and returns `{ answer, answered }`.
**Risk:** high

### Story 4.3 — FAQ written at describe, editable ✅ danybgoode/MiyagiSanchez-Storefront#469
**As a** merchant, **I want** my shop's frequent questions written for me when I describe it, and editable later,
**so that** the chat can answer from day one.
**Acceptance:** the words block includes 4–6 FAQ items for the shape; they are editable in the canvas; at keep they
become the shop's FAQ at `/s/<slug>/faq`; they remain editable in settings.
**Risk:** low

## Sprint QA
- **api spec(s):** `e2e/shop-chat.spec.ts` (knowledge builder, tenancy, guards order, «no sé» path, tool parsing),
  `e2e/mcp-ask-shop.spec.ts`, `p2s-*` specs green with the FAQ field.
- **browser smoke owed:** yes, to Daniel — a real question on a real shop on a phone.
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green; M2 verified live before merge.

## Sprint 4 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Open a claimed shop, e.g. https://miyagisanchez.com/s/<your-shop>, and tap the chat button.
   → A chat opens in the shop's colours.
2. Ask "¿cuánto cuesta <a product of the shop>?"
   → It answers with the same price as the product page.
3. Ask "¿hacen factura?" on a shop whose FAQ does not say.
   → It says it doesn't know and offers to leave a message.
4. Open a product page of the same shop.
   → The chat is there too.
5. From Claude with the Miyagi connector, ask it to use `ask_shop` for that shop.
   → It returns the same answer.

If any step fails, note the step number + what you saw — that's the bug report.
