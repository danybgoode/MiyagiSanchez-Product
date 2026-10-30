---
epic: in-person-sales
sprint: 3
title: "Offline cash"
risk: high
phase: Verifying
stories_total: 2
stories:
  - id: S3.1
    title: "IndexedDB queue + exactly-once sync"
    as_a: "a merchant at a market with no signal"
    i_want: "to keep selling for cash and have every sale upload once when the signal comes back"
    so_that: "I never lose a sale and never get duplicates"
    risk: high
    status: done
  - id: S3.2
    title: "Oversell on sync: recorded and flagged"
    as_a: "a merchant who sold offline what had just sold online"
    i_want: "the sale recorded anyway and a clear flag"
    so_that: "my records match what really happened"
    risk: high
    status: done
---
# In person — Sprint 3: Offline cash

**Status:** merged 2026-10-31, **deploy owed**. Backend MiyagiSanchez-Backend#220 → `74ed305`, storefront
MiyagiSanchez-Storefront#460 → `2898d47`.

**Verified:** the money-path gate covers an offline oversell that is recorded and flagged (decrement capped,
shortfall recorded), a resend that returns the same order, and a stale-claim takeover after a restock that adopts the
order instead of building a cart. Pure specs cover the queue state machine, the park list, the cross-tab diff, the
service-worker scope and the cache-owner rule, each observed red under a mutation. Codex ran 5 rounds on the backend
and 3 on the storefront, and the fresh verifier ran on both.

**Owed to Daniel:** the airplane-mode walkthrough below, on a phone. It is not headless-testable.

## Stories

### Story 3.1 — IndexedDB queue + exactly-once sync
**As** a merchant at a market with no signal, **I want** to keep selling for cash and have every sale upload once when the signal comes back, **so that** I never lose a sale and never get duplicates.
**Acceptance:** Offline, «Efectivo» stores the sale with its `client_id` in IndexedDB on the counter page; a banner shows «Sin señal: puedes cobrar en efectivo» and the pending count; the queue survives reloads; sync sends each sale to the S1.2 route and removes it only after the backend returns its order; a flaky reconnect can't duplicate (spec). Card, QR and transfer are disabled offline with a reason. The PWA/service-worker scope is checked so navigation doesn't regress.
**Risk:** high

### Story 3.2 — Oversell on sync: recorded and flagged
**As** a merchant who sold offline what had just sold online, **I want** the sale recorded anyway and a clear flag, **so that** my records match what really happened.
**Acceptance:** The sync path records the order even when stock is now short, decrementing without the availability check (composition confirmed at the lock, `ml-order-materialize.ts` precedent), and flags it «Vendiste más de lo que tenías en inventario» in the inbox. Online counter sales keep the normal availability check.
**Risk:** high

## Sprint QA
- **pure specs:** queue state machine (enqueue, retry, ack, never drop) observed red under a mutation
- **backend integration:** oversold sync recorded + flagged; replayed sync → one order
- **browser smoke owed:** yes, to Daniel: the airplane-mode walkthrough below
- **review:** fresh pr-reviewer + codex cross-family pass + the security lens
- **deterministic gate:** backend `npm test` + money-path CI gate; frontend `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. With signal, open https://miyagisanchez.com/shop/manage/en-persona once and wait for it to load fully (the phone saves the screen for offline use)
   → the counter with your products
2. Turn on airplane mode
   → the «Sin señal» banner; only «Efectivo» is enabled
3. Ring up three cash sales, then reload the page
   → «3 ventas por subir» is still there
4. Turn airplane mode off
   → the count goes to 0 and exactly three orders appear
5. Offline, sell your last unit of a product; online on another device, sell it too; reconnect
   → both orders exist and one is flagged «Vendiste más…»

If any step fails, note the step number + what you saw — that's the bug report.
