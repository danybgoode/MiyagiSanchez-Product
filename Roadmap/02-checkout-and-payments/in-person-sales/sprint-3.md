---
epic: in-person-sales
sprint: 3
title: "Offline cash"
risk: high
phase: Shaping
stories_total: 2
stories:
  - id: S3.1
    title: "IndexedDB queue + exactly-once sync"
    as_a: "a merchant at a market with no signal"
    i_want: "to keep selling for cash and have every sale upload once when the signal comes back"
    so_that: "I never lose a sale and never get duplicates"
    risk: high
    status: planned
  - id: S3.2
    title: "Oversell on sync: recorded and flagged"
    as_a: "a merchant who sold offline what had just sold online"
    i_want: "the sale recorded anyway and a clear flag"
    so_that: "my records match what really happened"
    risk: high
    status: planned
---
# In person — Sprint 3: Offline cash

**Status:** ⬜ not started

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

1. Open https://miyagisanchez.com/shop/manage/en-persona, then turn on airplane mode
   → the «Sin señal» banner; only «Efectivo» is enabled
2. Ring up three cash sales, then reload the page
   → «3 ventas por subir» is still there
3. Turn airplane mode off
   → the count goes to 0 and exactly three orders appear
4. Offline, sell your last unit of a product; online on another device, sell it too; reconnect
   → both orders exist and one is flagged «Vendiste más…»

If any step fails, note the step number + what you saw — that's the bug report.
