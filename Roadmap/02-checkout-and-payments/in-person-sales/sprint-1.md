---
epic: in-person-sales
sprint: 1
title: "Counter and cash"
risk: high
phase: Shipped
stories_total: 3
stories:
  - id: S1.1
    title: "Pure counter cart: lines, totals, change"
    as_a: "the builder"
    i_want: "a pure counter cart that adds, removes and totals lines and computes change"
    so_that: "the counter's money math is tested without a phone or a network"
    risk: low
    status: done
  - id: S1.2
    title: "In-person order route: idempotent client id, operating channel, source in_person, stock, cash paid"
    as_a: "a merchant at my stall"
    i_want: "each cash sale saved as a real order exactly once, even if I tap twice or the signal flickers"
    so_that: "my stock, orders and Ganancias are right"
    risk: high
    status: done
  - id: S1.3
    title: "«Vender en persona» counter screen"
    as_a: "a merchant"
    i_want: "a counter on my phone: search or tap products, see the total, take cash and see the change"
    so_that: "ringing up a sale is faster than writing it in my notebook"
    risk: low
    status: done
---
# In person — Sprint 1: Counter and cash

**Status:** ✅ shipped 2026-10-30. Backend MiyagiSanchez-Backend#214 → `4a6db92`, storefront
MiyagiSanchez-Storefront#458 → `35e1ba1`, both deployed to the VM.

**Verified:**
- The money-path CI gate runs 8 counter-sale cases against a real Postgres, alongside the 4 existing ones (12 of 12):
  one order on the operating channel, cash captured, stock reserved, a replay, a concurrent replay, a double
  stale-claim takeover, a reused id, a foreign variant, short cash, out of stock, and a typed email that cannot attach
  the order to a registered buyer.
- Pure specs on both sides, each observed red under a mutation.
- `POST /store/sellers/me/in-person-orders` answers 401 without a session (404 for a nonexistent path).

**Owed to Daniel:** the phone walkthrough below. It needs a seller session and is the first real sale through the
counter.

**Review:** a fresh verifier on both PRs, and Codex for three rounds on each. agy's quota was exhausted (about 115 h)
and vibe produced no review, so Codex also ran the security lens. Codex's findings that were fixed: a takeover that
was not exclusive, a replay reporting the wrong change, and a typed receipt email linking the order to a registered
customer's account. The verifier's findings that were fixed: Medusa's duplicate error was not recognised, two
integration runners clashed, a provider was missing from the region, and the client dropped the sale id after an
uncertain answer.

## Stories

### Story 1.1 — Pure counter cart: lines, totals, change
**As** the builder, **I want** a pure counter cart that adds, removes and totals lines and computes change, **so that** the counter's money math is tested without a phone or a network.
**Acceptance:** `lib/in-person/counter-cart.ts`: integer centavos only, quantities, line and cart totals, cash change and the «falta» amount when tendered is short. Spec-covered and observed red under a mutation.
**Risk:** low

### Story 1.2 — In-person order route: idempotent client id, operating channel, source in_person, stock, cash paid
**As** a merchant at my stall, **I want** each cash sale saved as a real order exactly once, even if I tap twice or the signal flickers, **so that** my stock, orders and Ganancias are right.
**Acceptance:** `POST /store/sellers/me/in-person-orders` with a device `client_id`: a **database constraint** makes it exactly once (validate → claim → apply); a replay, including concurrent, returns the first order. The order is on the shop's operating sales channel with `metadata.source: in_person`, no `customer_id`, the cash payment captured, inventory decremented and a profit-ledger row written. Only the authenticated seller's own variants are accepted (another seller's product is refused, spec). Covered by the backend money-path CI gate.
**Risk:** high

### Story 1.3 — «Vender en persona» counter screen
**As** a merchant, **I want** a counter on my phone: search or tap products, see the total, take cash and see the change, **so that** ringing up a sale is faster than writing it in my notebook.
**Acceptance:** `/shop/manage/en-persona` from the seed's surface blocks: search + product grid with stock left, cart sheet with − / +, «Efectivo» with an amount pad and «Cambio», «Venta registrada» confirmation; large touch targets at 375 px; shared `Card` / `Button`, Iconoir, no emoji; a SellerNav entry; the client-JS budget justified.
**Risk:** low

## Sprint QA
- **pure specs:** counter cart math; idempotency decision (each observed red under a mutation)
- **backend integration:** in-person cash order through the money-path CI gate (one order, stock down, ledger row; concurrent replay → one order)
- **browser smoke owed:** yes, to Daniel: the phone walkthrough below
- **review:** S1.2 is money path: fresh pr-reviewer + codex cross-family pass + the security lens
- **deterministic gate:** backend `npm test` + money-path CI gate; frontend `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. On a phone, open https://miyagisanchez.com/shop/manage/en-persona
   → the counter with your products and their stock
2. Tap two products, then «Efectivo», enter $500
   → the change shows correctly
3. Tap «Listo»
   → «Venta registrada»
4. Open https://miyagisanchez.com/shop/manage/orders
   → the sale shows as an order; the two products' stock dropped by one each
5. Open https://miyagisanchez.com/shop/manage/profit
   → the sale counts in Ganancias

If any step fails, note the step number + what you saw — that's the bug report.
