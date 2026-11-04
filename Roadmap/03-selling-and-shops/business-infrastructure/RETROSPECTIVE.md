# Business infrastructure — describe any business, we set up everything — Retrospective

_Closed: 2026-11-04_
_Intent: mostly_
<!-- Did we build what the product owner meant? One word, THEIR answer: yes, mostly or no. Required by `epic-dod` only
     when the epic's seed or README carries a numeric `intent_match:` (intent-match D17); the calibration learns from
     it. Keep the line and leave exactly one of the three words between `_Intent: ` and the closing underscore. -->
_Quote vs actual: $50–300 (L, n=0, wide) → stamped ≈$2.25 (a LOWER BOUND: `epic-actuals` matched only the session's last branches by name; the whole run was one long Opus session)_
_Crew (actual): claude-opus-5-5 orchestrated and built every story (no Sonnet builder was used — every story was high risk) · reviewers: fresh `pr-reviewer` on every PR, agy (Gemini) general pass from PR #466 on, the same-family verifier as the security lens on #465/#466 · prose: Opus — codex was capped all run, agy was out of quota at the start and could not fit a security-lens pass on any PR (its fallback model's context is too small), vibe produced no review once given real files._

> **Intent** is the orchestrator's proposal pending Daniel's word: the five sprints shipped what the pitch named, and
> the chat, the plan and the check-in await his phone walkthroughs. Change the word above if his answer differs.

## What shipped
- **S1 — the door opens, for any business.** The «Quedármela» sheet bug (Storefront #465): an unlayered
  global rule turned the sheet's `fixed` and the keep bar's `sticky` into `relative`; the rule moved into a CSS layer
  and every p2s sheet mounts on the body. Business shapes (Storefront #466): six kinds of business, shape-aware
  examples, hand delivery pre-selected for those who meet their buyers, Correos only for those who ship.
- **S2 — one business model per shop** (Storefront #467; migration M1 `20261104000000` applied live): «Tus números»
  on the draft, «Tu plan» for every shop, every number with its source, the merchant's own numbers kept above any
  estimate, nothing ever deleted (retired instead).
- **S3 — «Tu plan»** (Storefront #468; Backend #223): volume, break-even, capacity, the binding constraint,
  up to three linked moves, a guarded explanation, the monthly check-in (daily timer, once a month), `get_business_plan`.
- **S4 — the shop answers** (Storefront #469): the shop's chat on shop pages, product pages and the embed, `ask_shop`,
  FAQ from the description shown before keep.
- **S5 — handoff that learns** (Storefront #470; migration M2 `20261104010000` applied live): «Preguntas», the buyer's emailed
  answer, one tap to the FAQ, the 90-day email purge.

## What went well
- **The lock disproved scope before a line was written** (D4: prompt-to-shop examples never become products at keep),
  and the build kept disproving it (the D4 amendment: an estimate written into COGS would read back as measured).
- **The fresh `pr-reviewer` earned its keep on every PR.** It found the bugs that mattered: examples eroding one batch
  per visit (#467), a confident «you sold 0» after a partial ledger (#468), the chat's payment facts drifting from the
  platform's own rule and agents able to exhaust a shop's chat (#469), «Respuesta enviada» when the email failed (#470).
- **Every new spec was seen red**, and twice a mutation that stayed green exposed a spec scenario that could not tell
  the cases apart (push per hour vs per sale; a signed loss) — the scenario was fixed, not the mutation dismissed.

## What we learned
- An unlayered global CSS rule beats Tailwind v4's `@layer utilities` whatever the specificity → LEARNINGS.
- A merge that prunes its own stored output erodes data one visit at a time; recompute from the full list, retire
  instead of delete → LEARNINGS.
- A mutation that stays green may be the SCENARIO, not the code: when the two branches of a decision give the same
  answer on the fixture, the spec cannot see the decision → LEARNINGS (sharpened).
- `cross-review.mjs` run from the root repo reads none of an app PR's files and can still post «clean» → LEARNINGS.
- Re-writing a platform rule in a new consumer (payment availability) drifts the same week it is written → reuse the
  platform's function (sharpens the existing "paraphrased contract" learning).
- A chat history window of even length over an alternating dialog starts on the model's turn; Gemini refuses it.

## Gaps / follow-ups
- **Owed to Daniel:** the phone walkthroughs in sprint-1..5; a Google sign-up from the keep sheet; his own «Tu plan»;
  a real question on a real shop and its handoff; **enabling `miyagi-cron-business-checkin.timer` on the VM** (the
  classifier refused the agent; one `systemctl enable --now`). The first check-in is due 2026-12-01.
- **Product call owed:** may a partner (`PARTNER_READ_TOOLS`) read a merchant's plan — their goal and costs? It is
  owner-only until he decides.
- Outside this epic, found during it: no `frame-ancestors` anywhere but `/embed/*`; `/internal/*` publicly routable
  (401); `cross-review.mjs` must fetch an app PR's head from its own remote; the check-in's month is UTC.
- Cross-family review: no security-lens pass by another family ran on any PR this epic (tooling, not choice).
