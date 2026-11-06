# El panel del promotor: open a shop in one visit, manual-first, in four steps — Retrospective

_Closed: 2026-11-06 (built and merged; the deploy and the money smokes are owed to Daniel)_
_Intent: yes | mostly | no_
<!-- Did we build what the product owner meant? One word, THEIR answer: yes, mostly or no. Required by `epic-dod` only
     when the epic's seed or README carries a numeric `intent_match:` (intent-match D17); the calibration learns from
     it. Keep the line and leave exactly one of the three words between `_Intent: ` and the closing underscore. -->
_Quote vs actual: $27–40 (M, n=3, p25–p75) → actual not stamped yet (run `node scripts/epic-actuals.mjs --epic promoter-panel --write`)_
_Crew (actual): Opus 5.5 orchestrated and built all four sprints (no Sonnet builders: each sprint's review fixes touched the previous one's seams) · reviewers: a fresh pr-reviewer on #480, #481 and #483; Codex gpt-6-luna xhigh general + security lens on #480, #481 and #483; CodeQL · prose: the builder_

## What shipped
- **S1 · #480 (`ff3a8be`):** writes are guarded by `promoterShopEditAccess`, so a promoter writes only to an unclaimed shop they opened. Promoters can import a Shopify catalog, or a Tiendanube or WooCommerce export file, into that shop. Up to 150 products are free, counting what is already in the shop. Imports run one at a time per shop, and images are fetched SSRF-safe and copied byte-exact.
- **S2 · #481 (`3774d43`):** «El negocio», one form for the lead and the shop.
  - It is built mostly from choices: what they sell, main category, where they sell today and the preferred channel.
  - WhatsApp is required and is now a duplicate key; a duplicate in another promoter's list says only that it exists.
  - The US market and the business description are kept under «Más datos».
- **S3 · #482 (`7205a60`):** «Sus productos». It opens with a big camera button and typed cards. The import offered depends on where the merchant sells today. The optional photo fill stays.
- **S4 · #483:** «Cobra» with the owner's receipt: WhatsApp from the promoter's phone, plus email when there is one. The receipt page `/recibo/…` reads Pendiente, Activo, Listo or «terminó» live. «Entrégala» holds the preview and the claim link. All copy lives in `promotorPanel`, and every button in the panel and /admin/promoter is now a `.btn`.

## What went well
- **The lock's platform-first reuse held.** The epic needed no migration, no new table and no new flag. The Shopify import is the supply batch with a `resolveSeller` hook, and the receipt status is read from the attribution and transfer rows that already exist.
- **Review earned its cost on every high-risk PR.**
  - #480: the 150 cap applied per request (two imports could add 300), a race between concurrent imports, an image buffer that would have published pooled memory, and an unbounded body.
  - #481: the shop linked to a stale lead, consent shown in exactly the states the route refuses, a +1 number turned into +52, and the cross-promoter existence leak.
  - #483: «Activo» on a repeat sale, a 404 on a database blip, and rounded centavos.
  - Each fix landed with a spec that was seen red under a mutation.
- **Copy was written once, in the locales,** and specs keep raw strings out of the step components.

## What we learned
- **A cross-tenant duplicate check is an existence oracle.** Answer the caller's own match in full, and anyone else's with a bare "exists". Promoted to LEARNINGS.
- **A status keyed on "a paid row exists" lies on a repeat sale and on a lapsed grant.** Decide from the latest event, then the entitlement's expiry. Promoted to LEARNINGS.
- **`Buffer.concat(...).buffer` is the shared pool.** Promoted to LEARNINGS.
- **Stacked PRs: regenerate generated artifacts at each rebase step.** The flag inventory conflicted at every restack and went stale on S1 without CI saying so: the API suite is skipped while Vercel is "Account blocked". Run `flag-inventory.spec` locally before pushing any route that adds an `isEnabled` call.
- **Source-text specs miss data-path regressions.** The first receipt spec pinned query strings. The reviewer was right that a dropped filter would stay green. Injecting the database (`lib/promoter-receipt-read.ts`) made the filters assertable.

## Gaps / follow-ups
- **Owed to Daniel:**
  - Deploy main: S1–S4, plus #479's favicon.
  - Money smokes: a card close and a transfer close with a test promoter, checking that the receipt page turns Activo after the admin approves.
  - Phone walkthroughs of sprints 1–4 (each sprint doc has its walkthrough).
  - The Intent answer above.
- **Follow-up:** `main_category` is saved for a new shop opened from the panel, but not for an existing seller's shop.
- **Follow-up:** with private previews on, «Ver su tienda» is the preview link; the public link appears only when previews are off.
- **Known:** the API suite does not run in CI while the Vercel account is blocked, so every PR's suite was run locally.
