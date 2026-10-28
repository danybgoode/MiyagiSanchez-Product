# Prompt-to-shop — Retrospective

_Closed: 2026-10-28_
_Intent: mostly_
_Quote vs actual: quote $50–300 (L, n=0, wide) → actual not stamped (no `epic-actuals.mjs` in this repo)_
_Crew (actual): orchestrator claude-opus-5-5; builders claude-opus-5-5 (S1, S3–S5) and sonnet (S2) · reviewers codex gpt-5.6-terra (general + security), agy (S1/S2; S3's security pass was rejected by the output guard), fresh golden-frijoles verifier on every PR · prose: claude_

## What shipped
- **S1:** generation rail. #436 → `2ae4b25`, #437 → `2c1a591` (Vertex service account, minimal thinking).
- **Hardening:** Supabase grants lockdown, #438 → `bf71f79`.
- **S2:** describe, shape, preview, plus a view-only link. #439 → `cd894f0`.
- **S3:** «Quedármela», claim → one shop, the three doors off the main path. #440 → `871e7ee`.
- **S4:** owner checklist, photo → product, example → real. #441 → `16bcd1f`.
- **S5:** cobros/entregas chooser, checkout preview, publish, funnel, day 1/3/7 nudges. #442 → `1b2123c`.
- **Root:** deploy ✅/❌ Telegram ping (#226) and the nudge timer unit (#227).
- **Production** runs web `1b2123c` and medusa `6cf1431`, verified by the containers' revision labels.

## What went well
- The fresh verifier plus codex caught every real defect before merge. Examples: a draft applied over an existing shop, a photo double spend after a stale takeover, an unbounded spend on paid analyses, and the cron secret accepted in a query string.
- Stacking S4 and S5 on the sprint under review, then rebasing after each squash-merge, kept builders busy without conflicts beyond one file.

## What we learned
- An idempotent create-or-get's 200 is not proof that this call made the record. Apply a draft only on the 201.
- In a stale-takeover idempotency ledger, record "paid" BEFORE the side effect, and bound the side effect with a timeout shorter than the stale window.
- A dependabot (bot-token) merge starts no workflow, so the prod image silently lagged `main`. Prove the deployed revision label equals the merge SHA.
- Moving deploy rails dropped the old rail's side effects: the "deployed" Telegram ping was missing for 12 days.

## Gaps / follow-ups
- **OWED to Daniel:**
  - **Enable the nudge timer on the VM.** The agent's attempt was refused by the classifier. The command is in `sprint-5.md`.
  - **Phone walkthroughs:** sprint-2 (which also covers S1's generation smoke), 3, 4 and 5. They include Mercado Pago OAuth and a real test order.
- **Done at close:** the poster line and the four learnings promoted to `LEARNINGS.md`.
