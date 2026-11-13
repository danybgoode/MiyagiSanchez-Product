# Retrospective — One front door for both markets

_Closed: 2026-11-13_

**Shipped 2026-11-13** · 4 sprints, 14 stories · storefront #498 #499 #500 #501 · one migration · no backend change.

## What shipped
Any visitor — from either market or neither — starts a shop on miyagisanchez.com from a sentence, one photo, a catalog
file or a store link, in their own language (`/` Spanish, `/en` English, `/us/vende` Spanish for the US), and chooses
Mexico or the United States when the shop becomes theirs. A Jev (TypeSafe) judgment refuses junk, attacks and
prohibited goods before Gemini runs or any allowance is spent. Every landing opens on the builder, «Compruébalo tú
mismo» is gone, and merchants with a shop get «Crear con IA» on the dashboard.

## What went well
- Recording 44 real Jev answers once and replaying them in CI pinned the thresholds against real model output with no
  network in the suite.
- A local `next start` against prod Supabase with Cloudflare's always-pass Turnstile secret exercised the real Jev,
  Gemini and Shopify paths before any PR — it is where the allowance-kind failure surfaced.

## What we learned

### What the reviews caught that the plan did not
- **The DB is the contract, again.** A new `ai_allowance` kind failed live (closed) against `ai_allowance_kind_check` —
  found by a real local run against the prod DB, not by any spec. Now a spec reads the constraint from the migrations.
- **A US shop's only payment option created a MEXICAN Stripe account.** `/api/stripe/connect` hardcoded
  `country: 'MX'`; the backend's US v2 route had no storefront caller. The fresh `pr-reviewer` found it by following
  the link one hop further than the builder did. D15's premise ("the existing Connect flow") was false.
- **A false alarm, corrected:** a probe of Shopify's UCP endpoint without the agent profile got «Missing profile uri»
  and was reported as "the migration connector is dead". The connector sends the profile and works. A finding from a
  hand-made probe must be re-run with the real call shape before it is reported.
- **Security lens, in rounds:** redirect ports, row-15 screen truncation, out-of-range entities, unbounded request
  bodies, an XLSX zip bomb, CSRF on a GET, a month-boundary refund. Each round found the NEXT door; the last fix put
  the prohibited-goods screen at the one door every import shares (`/api/sell/import`).

### What did not
- agy was quota-capped (~99 h) and vibe produced no review twice, so codex ran both lenses on every high-risk PR.
- Two subagents stopped on the 5-hour usage limit mid-task and were resumed after the reset.

## Gaps / follow-ups
All closed in storefront #502 (2026-11-13) except the R2 lifecycle rule for `p2s/` (owed to Daniel: dashboard, no
API scope). The sibling ideas `show-the-product-not-a-wall-of-text` and `us-commerce-parity` are in the backlog.

## Intent
_Owed to Daniel — one word for how close this landed to the ask._
