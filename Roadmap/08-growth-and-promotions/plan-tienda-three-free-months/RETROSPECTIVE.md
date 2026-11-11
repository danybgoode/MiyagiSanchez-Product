# Plan Tienda, three free months, and the promoter packages that follow — Retrospective

_Closed: 2026-11-11_
_Intent: yes | mostly | no_
_Quote vs actual: $27–40 (M, n=3, p25–p75) → not stamped (`epic-actuals.mjs` was not run in this session) (—)_
_Crew (actual): Fable 5.2 then Opus 5.5 orchestrated (the session switched models mid-run) · builders Fable 5.2 and Opus 5.5 subagents for every story, including the money stories planned for the orchestrator · reviewers the fresh verifier on every PR, Codex gpt-6-luna xhigh general and, on four of six PRs, security (agy could not fit three diffs and returned nothing on two) · prose by the orchestrator — usage limits stopped agents six times, so the orchestrator delegated more than planned and resumed agents from their saved work._

## What shipped
- **Sprint 1 — Plan Tienda exists** (Storefront #484 `94c99b6`, migration M0 `merge_shop_metadata_guards`): five plans in one seam; every plan-grant write guards every key it read; the legacy marker script with a required `--cutoff`; the AI usage report (cost is not logged anywhere yet).
- **Sprint 2 — Buying Plan Tienda** (Backend #228 `21830e8`, Storefront #485 `6f817a3`): $228 a year or $29 a month; the webhook asks Stripe for each plan subscription's current status and a failed plan step makes Stripe retry; a cancelled subscription can never come back. Found and fixed on the way: Plan Negocio's lapse write had never landed (Medusa call shape).
- **Backend #229** (`a2fd738`): five more routes with the same dead write; the public subscription list could be walked for buyer emails and billing ids and is now server-only.
- **Sprint 3 — Three free months, then a pause** (Storefront #487 `ef400ae`): 90-day trial; 15- and 5-day notices; a Mexico-only pause job that refuses to run while no shop is marked, never releases on an unknown answer and undoes itself if a payment landed; the restore on every recorded payment.
- **Sprint 4 — The promoter's three packages** (Storefront #486 `6ceb707`, migration M1): Tienda · 1 año $500, Negocio · 6 meses $1,100, Negocio · 1 año $2,000, each with three free months on top; 10% renewals in the 12 months after the package ends; 20% on a first move up; Arranque and the free setup retired.
- **Live 2026-11-11**: deployed, legacy marker 61/61, Plan Tienda monthly seeded, pause dry run 0 candidates.

## What went well
- The fresh verifier found the defects that mattered on every PR: the pause job's unknown-answer release, the only-process-order protection of the 18 trial shops, a correctly-unpaid share retried for days, the public subscription list. Codex found real races the verifier did not, and was wrong three times (an "English string" that was Spanish, a Negocio double charge the ranking already prevents, an unreadable plan that already said so).
- Reading live data before each migration changed the plan twice: the integer rate column (the six-month split became $495/$605) and the missing `migration` value in the transfers check.

## What we learned
- **A Medusa generated `update<Model>s` takes ONE argument.** `updateSubscriptions(id, patch)` reads the id as data and throws; behind a `.catch(() => {})` it was silent on six routes. Fixing a dead write makes it live, so guard it (cancelled stays cancelled, one conditional statement) in the same change.
- **A webhook that alerts and answers 200 never heals.** Make a step a later delivery can fix answer 500, order idempotent records before one-time messages, and run the "on payment" hooks on a replay too.
- **A job that takes shops offline needs a code guard for its precondition**, not only a deploy step: it refused to run while no shop carried the legacy marker, and that guard is what made the deploy order safe to get wrong.
- **The api Playwright project's default base URL is production.** Two builders ran unauthenticated suites against it before every brief said to use a dead host.

## Gaps / follow-ups
- **Owed to Daniel:** the Intent word above; the pause timer (`miyagi-cron-plan-pause.timer`, must call `?dry_run=0`), only after reading a dry run; the money smokes (Plan Tienda yearly and monthly with a test card and a cancel; a pause and restore on a test shop; a card and a transfer package with a test promoter); phone walkthroughs of sprints 1–4.
- **Follow-ups (not built):** the backend cannot finish a partial pause or relink by being asked again (paused → paused is a 409); the AI cost is not stored, so the allowances still rest on a guess; a restore sweep for a failed restore; two accepted races on the 20% upgrade share (out-of-order invoices of the same price; a package recorded in the milliseconds between re-check and confirm, about $30); a transfer approval whose attribution fails after the grants shows approved and needs a hand repair; the US shop-created welcome email still describes the old offer.
- **Recorded by the orchestrator, reversible by Daniel:** D20 (sprints 2 and 3 deployed together), D22 (only Mexico shops are paused).
