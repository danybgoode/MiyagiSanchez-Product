# The shop builder opens at miyagisanchez.com — Retrospective

_Closed: 2026-10-30_
_Intent: yes | mostly | no_
<!-- Owed to Daniel: one word after the phone walkthrough. Left as the template line on purpose — it is
     Daniel's answer, not the builder's. -->
_Quote vs actual: $27–40 (M, n=3, p25–p75) → not stamped (`epic-actuals`: nothing measured on this machine) (—)_
_Crew (actual): Opus 5.5 planned, locked, built and orchestrated every story (no Sonnet builders were dispatched —
the stories shared one moved page and one guard, so splitting them would have collided) · reviewers: Codex
gpt-6-luna @ xhigh (clean ×4) + a fresh `pr-reviewer` per PR (found 2 + 4 real defects) · prose: Opus — differed
from the plan by building in one hand; the reviews, not the builders, were where independence came from._

## What shipped
- **S1 — the shop builder opens at the root** (Storefront #454 → `dadfc8c`, deployed and verified live): `/` renders
  the Mexico seller page with the describe box first; `/mx/vende` and `/vende` 308 to `/` in one hop with tags kept;
  `/mercado` → `/mx`; no language hop on `/`; a bottom strip links Marketplace México · Estados Unidos · English
  (the English link stores the choice so `/en` does not bounce es-MX phones back); every seller-landing link,
  agent prompt and report text names `/`; the AI-agent button on `/` gets the seller prompt. `/en` untouched.
- **S2 — the upgraded pitch** (Storefront #455 → `9e4094a`, deployed and verified live): shop-first headline;
  "Lo que te llevas" (address, direct payments at 0%, catalog link/PDF/Instagram-WhatsApp catalog, setup guide, AI);
  steps that match the real flow; catalog-filled prices; marketplace as a bonus; «¿Vienes a comprar?» in the hero.
- Follow-up: Storefront #456 — the home-page smoke ignores Turnstile's own iframe console output.

## What went well
- The lock caught two "this would have been `//creadores`" bugs before any reviewer did: deriving persona URLs and
  the US operators link from the landing path. Moving a base to `/` breaks every `${base}/x` concatenation.
- Every new spec was seen red twice over: against production (the old behaviour) and by source mutation. One
  mutation survived the first guard and drove the whole-line scan.
- The fresh reviewer earned its keep on a low-risk epic: the English link bounce and the `https://`-as-comment blind
  spot (S1), and an es/en contract break, a missing manifest entry and two overclaims in copy (S2). Codex was clean
  on all four passes and found none of them.

## What we learned
- **A path constant becoming `/` silently breaks two idioms at once**: `${base}/child` concatenation (gives `//child`,
  a protocol-relative URL) and `includes(base)`/`startsWith(base)` exemptions (every URL matches). Sweep for both
  idioms, not for the constant's old value.
- **A comment-stripper written as `//[^\n]*` eats every `https://` URL** — a guard that strips comments before
  scanning cannot see absolute links. Fixtures must run through the sweep's own preprocessing, not only the predicate.
- **Third-party iframes log to the page console.** Moving a widget (Turnstile) onto a page made a strict
  console-error smoke flake 1 in 4. Filter by message SOURCE (`message.location().url`), never by text.
- **A hex-colour guard reads `#454` in a comment as a colour.** Write "PR 454" in code comments.

## Gaps / follow-ups
- **Owed to Daniel:** the two phone walkthroughs in `sprint-1.md` / `sprint-2.md`, and the `_Intent:_` word above.
- **Daniel's call:** the live admin override `sellerAcquisition.anchor.proofTitle` («Estas son algunas de las
  funcionalidades incluidas», 07-12) does not render on `/` today; clear it in `/admin/contenido` if it is stale.
- `/en` still names `/` as its Spanish hreflang alternate (accepted, D3) and still sends an `en-MX` seller to the US
  market (the earlier owed D7 product call) — both wait for the day `/en` gets its own decision.
- `/` TTFB went ≈ 0.28 s → ≈ 0.39 s (per-request render). Inside the limit; worth a look if the page gains data reads.
- No "real shops" proof section (product owner, 10-29) — add when there are shops worth showing.
