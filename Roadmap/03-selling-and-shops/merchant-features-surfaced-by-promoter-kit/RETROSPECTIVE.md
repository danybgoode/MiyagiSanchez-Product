# Merchant panel gaps: seats, one Evento, Comparte into Canales, the field loop — Retrospective

_Closed: 2026-11-11_
_Intent: owed_
_Quote vs actual: $27–40 (M, n=3) → not measured on this machine (—)_
_Crew (actual): Opus 5.5 orchestrator · Sonnet 5.5 builders · reviewers: fresh pr-reviewer on every PR, codex gpt-6-luna @ xhigh general + security (agy did not fit the diffs, vibe stopped without a review) · prose: builders — the plan said a different family for the security lens; only codex could read these diffs._

## What shipped
- **S3 · Canales and the field loop** — storefront #489 `f664098`, follow-up #493 `8a4437c`. The share tools (catalog link, PDF, Meta feed) moved from the unlinked Comparte page into Canales, and `/shop/manage/comparte` redirects there. Promoters file «Reportar» from `/promotor/cerrar` into `platform_feedback` (`author_kind='promoter'`, migration `20261111010000` applied live first). Reports are rate-limited, never fail after saving, and arrive in Telegram as «Reporte de promotor». Canales still opens when the catalog can't load.
- **S1 · Seats** — storefront #490 `d0d6ab1`, backend #230 `9fa411f`. An event listing (a service or digital listing with a date or venue) takes «Lugares disponibles» as Medusa tracked inventory. It sells out instead of overselling, proven on real Postgres: two buyers add the last seats, the first completes and the second is refused at reservation. Bad counts are refused at the field and never rewritten. Agents can set seats only on events. Nothing defaults a quantity any more.
- **S2 · One Evento** — storefront #491 `28ddd82`. «Evento» is one wizard choice. A $0 Evento runs on the existing RSVP system (registration, QR ticket, roster), linked by `rsvp_event_slug`, with no migration. «Gratis» appears only while the price is $0 and the event belongs to the same shop. Its price can't leave $0 through any edit path. Eventos left the seller nav.
- **Found on the way, also shipped** — backend #231 `c203387`: start-checkout charged whatever `offer_amount_cents` a caller sent, so anyone could pay one centavo for any listing. An offer price is now honoured only for an accepted offer, on the right listing, inside its payment window, paid by the signed-in buyer who made it.

## What went well
- Checking the plan against the code and the live database changed two decisions before any builder started: the field became «Lugares disponibles», and a free Evento needed no re-keying migration.
- The fresh reviewer and codex each found real money defects on every round: one-seat events from a backend-first deploy, «Gratis» on a paid listing, a $0 checkout through caller-chosen exemptions, and the live one-centavo offer hole.

## What we learned
- A storefront change that adds meaning to an existing field ("a quantity was sent" now means seats) can make the OLD caller dangerous. Find the deploy order by asking what the old version of the other repo sends.
- A guard that exempts by request-body flags is no guard. Decide from what the server can see, here the cart's own line prices.
- The review rail has a coverage gap: `scripts/review-config.json` `securityPaths` misses `**/*checkout*`, so the backend charge route sat outside the security lens.

## Gaps / follow-ups
- **Owed to Daniel:** the S1 and S2 phone walkthroughs with their money steps (a Cupo-2 event sold out to «Agotado»; a free Evento registered with its QR redeemed; a paid Evento bought), one real offer checkout after #231, a Canales authed view, and one promoter report.
- **Follow-ups:** backend start-checkout has no zero-total refusal of its own; `shipping_quote.amount_cents` is charged as the caller sends it; one accepted offer can open several checkouts; an automatic repair for a failed RSVP-row sync; `securityPaths` should add `**/*checkout*`; a $0 Evento is Mexico-only.
