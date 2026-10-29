# Share kit — Retrospective

_Closed: 2026-10-29_
_Intent: yes | mostly | no_
<!-- Did we build what the product owner meant? One word, THEIR answer: yes, mostly or no. Required by `epic-dod` only
     when the epic's seed or README carries a numeric `intent_match:` (intent-match D17); the calibration learns from
     it. Keep the line and leave exactly one of the three words between `_Intent: ` and the closing underscore. -->
_Quote vs actual: $20–120 (M, n=1, wide) → ≈$49.75 (−59% vs the quote's top)_
_Crew (actual): claude-opus-5-5 ≈$49.75 (orchestrator, builder of all three sprints) · reviewers: fresh `verifier` subagents on every PR (Claude, context-independent) + codex gpt-6-luna @ xhigh general and security lens on every final tip · prose Claude — agy was out of quota for the whole run and vibe stalled between turns, so codex ran both cross-family passes; CodeQL caught one finding no reviewer had._

## What shipped
- **Sprint 1, the catalog link** (Storefront #447 → `3daba88`):
  - `/mx/s/<slug>/catalogo` on every shop channel: one server-rendered scroll of the shop's own products, each with one order button. «Pedir por WhatsApp» appears only when the merchant turned WhatsApp on and the shop is claimed; otherwise «Comprar».
  - The «Catálogo» tile in Comparte and on the publish screen: copy, WhatsApp, and a QR to `mschz.org/s/<slug>/catalogo`.
  - A shop's products are now read in full (paged), not just the backend's first 20.
- **Sprint 2, the catalog PDF** (Storefront #448 → `96b8fe5`, #450 → `9448ab2`, #451 → `ea08414`; root #234, #235):
  - The PDF renderer is back as a fourth container on the VM, after being dead since GCP was deleted on 2026-10-16. It is internal-only, secret-checked and allow-listed, takes one render at a time, and redacts URLs in its logs and errors.
  - An A4 print page with 6 products a sheet and a QR on each.
  - `/api/catalogo/<slug>/pdf`, cached in R2 by a hash of what the buyer sees, rate-limited only when it has to render.
  - The «Catálogo PDF» tile. Admin print editions and rate cards render again too.
- **Sprint 3, Instagram and WhatsApp catalogs** (Storefront #449 → `100ae4e`):
  - A Meta Commerce Manager feed at `/api/feeds/meta/<slug>.csv`, covering the required columns, stock-aware availability, and products excluded and counted by reason. A partial read is a 503, never a short feed.
  - The «Instagram y WhatsApp» tile with the address, a four-step guide and the excluded count.
  - `get_share_kit` for a seller's AI agent, scoped to its own shop.
  - Order-tap events on the catalog page.

## What went well
- **The lock held.** D1–D21 were written against the live code and data, corrected once after the S1 verifier: the backend `take: 2000` is platform-wide, the `(shell)` layout forbids `revalidate`, and the `/us` mirror is a 404. No sprint had to reopen a decision.
- **Every PR met an independent reader, and each one earned its keep.** The verifier found:
  - S1: 6 CI regressions plus a spec that always skipped.
  - S2: an `ADMIN_SECRET` leak path to promoters, and a shop limit charged before the IP limit.
  - S3: a sold-out item sent to Meta as `in stock`, and a failed read that would wipe a shop's Instagram catalog.
  - #450: JPEG turning transparency black.

  Codex caught Chromium surviving a timed-out launch, and an empty header parsing as 0. CodeQL caught the renderer navigating to the caller's string.
- **Mutation discipline found real gaps.** Several specs were only proven real by turning them red. One harness bug (a `git checkout` restore stacking mutations) was caught that way too.
- **Measuring on the VM before fixing.** The render timeout could have been "raise the budget". Timing each phase inside the container showed two distinct causes: a page that never goes idle, and lossless WebP. Each fix was then sized from numbers.

## What we learned
- **A deploy script that swallows a failed pull reports success on the old commit.** `$(…)` does not inherit `set -e`. Production ran the previous build while the deploy said ✓. The fix checks every pull and exits on a failed `resolve`. (Root #234.)
- **A stalled registry pull can be a stuck local partial, not the network.** The containerd ingest for one layer sat at exactly 125 MiB across restarts, and every pull resumed it and hung. Deleting that one ingest directory fixed it.
- **An I/O shell with no harness needs a mechanical import check.** A script edit that "replaced" an import silently matched nothing. `node --check` parsed the result, every test passed, and every PDF failed in production. Two guards now exist: an import-coverage test, and `no-undef` on `services/**`. The meta-lesson: **an edit script must assert that its anchor matched.** Later edits in this run all did (`assert a in s`).
- **Chromium's PDF writer keeps a JPEG as-is but stores a WebP losslessly.** A 16-product catalog went from 12.6 MB and 24 s inside `page.pdf()` to 1.6 MB. Print pages ask for JPEG.
- **A print page must not wait for network idle.** The app shell keeps requests open; two `blob:` fetches never settle. Print pages are server-rendered, so the renderer loads them with scripts off and waits for `load`.
- **Run the thing before calling it fixed.** The hotfix was run end to end against the live print pages before the PR opened. #450 was not, and that is how the unimported helper reached production.

## Gaps / follow-ups
- **Owed to Daniel:**
  - The phone walkthroughs in all three sprint files: the signed-in Comparte tiles, a QR scan, admin «Descargar PDF» on a print edition, and editing a price then downloading again.
  - Adding one real feed in Meta Commerce Manager. `angela` is a claimed shop with a valid row. This is sprint 3's product-owner acceptance step: the sprint is shipped (merged, deployed, agent-verified), and this acceptance is owed, not assumed.
  - An agent call with a real `ms_agent_` token.
  - The `_Intent:` line above.
  - **Putting `print.env` and the two new `web.env` lines in the password manager.**
- **Daniel's call:** Cloudflare-only ingress on the VM. Today a client that bypasses Cloudflare can set `CF-Connecting-IP`, and so choose its own rate-limit bucket. This predates the epic and affects every limiter.
- **Known limits:**
  - A cold catalog render takes 17–31 s on 0.2 CPU; Chromium's launch alone is 5–7 s.
  - `get_share_kit` and the Comparte feed tile read counts from a partial model during a Medusa outage. The feed itself 503s.
  - Meta's title and description length limits are not enforced.
  - Non-product listing types go into the commerce feed.
- **Clean-ups:**
  - Orphaned R2 PDFs for paused shops.
  - `/api/sell/*` picks the user's oldest shop.
  - `lib/image-variant.ts` and `services/print-pdf/**` are not in the review security-path globs.
  - `document` should be scoped to the evaluate callback in the services lint globals.
  - The backend `take: 2000` cap is platform-wide.
  - `update.sh` does not detect a lagging `:main` tag that pulls successfully.
