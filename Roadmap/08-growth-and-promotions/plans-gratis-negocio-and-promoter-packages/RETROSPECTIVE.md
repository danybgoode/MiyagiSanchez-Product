# Two plans (Gratis + Negocio), a 30-day trial, and three promoter packages — Retrospective

_Closed: 2026-11-05 (merged; the production deploy and the money smokes are owed to Daniel)_
_Intent: yes | mostly | no_
<!-- Did we build what the product owner meant? One word, THEIR answer: yes, mostly or no. Required by `epic-dod` only
     when the epic's seed or README carries a numeric `intent_match:` (intent-match D17); the calibration learns from
     it. Keep the line and leave exactly one of the three words between `_Intent: ` and the closing underscore. -->
_Quote vs actual: $50–300 (L, n=1, wide) → not stamped yet (run `node scripts/epic-actuals.mjs --epic plans-gratis-negocio-and-promoter-packages --write`)_
<!-- The actual is STAMPED, never typed: `node scripts/epic-actuals.mjs --epic <slug> --write` writes actual_* into
     the README (finops S2.5); copy its numbers here. -->
_Crew (actual): Opus 5.5 built every story, including the low ones planned for Sonnet (one orchestrated run kept the stacked branches coherent) · reviewers: a fresh pr-reviewer and Codex gpt-6-luna xhigh (general + security lens) on every PR; agy overflowed and vibe failed, so Codex carried the security lens · prose: Claude_
<!-- The models are STAMPED, never typed: `node scripts/epic-actuals.mjs --epic <slug> --write` writes actual_models
     into the README (why-as-a-story D6). Codex, agy, Devin and other outside tools are not in the transcripts; name
     them from the PR's review records. -->

## What shipped
- **S1 — the plan underneath.** Backend #224 (`bf79685`): the Negocio plan in Medusa Commerce. Storefront #471
  (`cfa58dc`): one plan seam (`lib/plan.ts`), the prices, the 30-day trial stamped once, monthly Negocio by
  subscription and yearly by one payment with card installments, and the custom domain and Mercado Libre sync opening
  for Negocio.
- **S2 — what each plan gets.** #472 (`bb7e5a3`): «Hecho con Miyagi Sánchez» on Gratis shops, AI allowances by plan
  (chat per month, photos), the check-in for Negocio and trial shops, the trial emails, and the subdomain free and
  sold nowhere (plus the cancel-at-period-end script). Migration M1 applied live.
- **S3 — one price list and «Tu suscripción».** #473 (`f001016`): `/mx/precios` shows the two plans, the
  `/shop/manage/negocio` billing page, and MCP `get_plan` / `start_negocio`. The standalone domain and ML-sync purchases
  retired.
- **S4 — promoter packages.** #474 (`7373268`): Anual $2,000, Arranque $600 and the free-plan setup $250, closed by
  transfer or card and settled at source, plus 10% of the year-2 renewal. Migration M2 applied live.
- **S5 — photos in the promoter workspace.** #475: the promoter fills a new shop from product photos, with their own
  daily budget (`39ae94e`).

## What went well
- The architecture lock against live data (60 shops, 18 owned, the real CHECK constraints and RPC definitions) held:
  no decision had to be reversed, only sharpened.
- The fresh reviewer and Codex found real money bugs on every high-risk PR before merge: unpaid sessions granted, a
  JSON-null guard bypass, domain teardown ignoring Negocio, a package IDOR, a 0% fallback when a rate could not be
  read, self-close, and a retry that doubled the AI cost.

## What we learned
- **Stripe `2026-06-24.dahlia` moved a subscription's period to its item** (`items.data[0].current_period_*`). A handler
  reading `subscription.current_period_end` gets `undefined`, and the sibling monthly handlers (domain, subdomain, ML
  sync) still do.
- **A CI that skips the API suite lets main go red unseen.** The Vercel preview is blocked, so CI skipped the API
  specs, and S4 shipped a stale flag inventory that only a local full run caught in S5.
- **An `indexOf` ordering spec must assert `> -1` first.** A missing call returns -1, which is "before" everything.
- **Charge the unit that costs, not the request.** One budget spend in front of a retry loop let 60 a day buy 120
  model calls.
- **I committed with red specs twice** (S2, S3). The fix each time was a follow-up commit; the cause was running only
  the new spec, not its neighbours.

## Gaps / follow-ups
- **Owed to Daniel:** the VM deploy (`update.sh`) for Backend #224 and Storefront #471–#475; `seed-negocio-plan.mjs`
  with production credentials; `npm run negocio:trial-backfill -- --apply` and `npm run subdomain:cancel-paid -- --apply`
  (dry run first, once); the money smokes (a monthly and a yearly Negocio payment, the installment option, a transfer
  and a card package close); the phone walkthroughs in each sprint doc; the self-close product call; this retro's
  Intent word.
- **Not built:** the `current_period` fix in the sibling monthly handlers; a per-IP share of the monthly chat
  allowance; pagination past 1,000 rows in the trial notices; the admin tenant list does not show the plan.
