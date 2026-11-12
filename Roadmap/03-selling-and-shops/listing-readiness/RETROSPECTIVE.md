# Guided listing readiness — Retrospective

_Closed: 2026-11-12_
_Intent: yes | mostly | no_
_Quote vs actual: $27–40 (M, n=3, p25–p75) → not stamped (`scripts/epic-actuals.mjs` unavailable in this session) (—)_
_Crew (actual): Claude Opus 5.5 builder (epic mode, one run) · reviewers: fresh pr-reviewer ×4 passes, Codex gpt-6-luna xhigh general + security ×9 rounds · prose: builder — more review rounds than planned; each round found a real gap (see below)._

## What shipped
- **S1 — one rule, every door** (storefront #497, backend #234): `lib/listing-readiness.ts` replaces five drifted
  copies; `POST /api/sell/create`, activation, prompt-to-shop and Catálogo re-activation refuse an unready product
  unless «Publicar como catálogo»; the activation gate now sees drafts; offers (create, seller accept/counter, buyer
  accept-counter) and the PDP's «Comprar»/«Hacer oferta» follow each listing's own rule; every offer transition is a
  conditional claim with its deadline.
- **S2 — guided and visible**: «Antes de publicar» panel with the inline `CobrosChooser`; the panel banner names what is
  missing (cobro / entrega / SPEI-o-efectivo); «Solo catálogo» badges; the setup guide can't be hidden while it matters.
- **Rode along** (reported live by Daniel during the build): an accepted offer showed «Trato expirado»; the
  conversation's product link 404'd after refresh.

## What went well
- The live data pass (12/20 claimed shops could not collect; 3/5 with live products) made the scope obvious.
- Reusing `CobrosChooser` made the inline fix a component, not a feature.

## What we learned
- See `Roadmap/LEARNINGS.md` → Architecture (2026-11-12): published-only reads fail open for drafts; a recorded
  decision goes stale when a flag changes backend behaviour; every producer of one payload shares its derivation.
- The arranged-delivery rule was first argued down with the 07-11 "coexist" decision; the backend had changed under
  it. The reviewers were right.

## Gaps / follow-ups
- **Owed to Daniel:** the sprint-1 and sprint-2 walkthroughs (authed: publish on a no-payment shop, inline CLABE,
  catalog publish, offer refusal, banner/badges).
- Publish gate does not cover services/rentals (exempt by D1) while checkout takes only SPEI/cash for them — a
  service on a card-only shop publishes but cannot be bought online. Candidate seed.
- Recorded no-gos: CSV/Shopify import and promoter activation publish without the rule (visible via S2.2); bulk
  activate stays strict; the offer gate looks the shop up by the mirror slug (a collision fails closed).
