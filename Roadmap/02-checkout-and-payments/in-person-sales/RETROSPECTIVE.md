# In person: POS-lite and payment links — Retrospective

_Closed: 2026-10-31 (all four sprints merged and deployed: Backend `ba22692`, Storefront `8fd0046`)_
_Intent: mostly_
<!-- Did we build what the product owner meant? One word, THEIR answer: yes, mostly or no. Required by `epic-dod` only
     when the epic's seed or README carries a numeric `intent_match:` (intent-match D17); the calibration learns from
     it. Keep the line and leave exactly one of the three words between `_Intent: ` and the closing underscore. -->
_Quote vs actual: $50–300 (L, n=0, wide) → not stamped (`scripts/epic-actuals.mjs` does not exist in this repo) (—)_
_Crew (actual): Opus 5.5 orchestrator (lock, every backend money path) · Sonnet 5.5 builder (storefront S1–S4, D19) · reviewers codex gpt-6-luna @ xhigh (both lenses once agy hit quota and vibe produced none) + golden-frijoles verifier on every PR — Opus built all backend instead of only the riskiest stories, because each sprint's review loop changed the money core._

> `Intent` above is the builder's reading, pending Daniel's own one-word answer.

## What shipped
- **S1 · Counter and cash.** «Vender en persona» turns a cash sale into one real Medusa order on the MX operating
  channel, exactly once per device `client_id` (a unique index plus owner-token CAS). Backend #214 → `4a6db92` and
  storefront #458 → `35e1ba1`, **deployed**.
- **S2 · QR and transfers.** Card by QR through the shop's own Stripe or Mercado Pago checkout, paid only on a
  processor-confirmed order. Transfer by CLABE or DiMo with «Ya me llegó». Pedidos and Ganancias show the source.
  #218 → `211b8db` and #459 → `bae1775`. Plus #217 → `b258f70` (MX region provider repair route, deployed) and
  #219 → `397b56d` (Stripe authorization verified with Stripe and bound to the checkout).
- **S3 · Offline cash.** An IndexedDB queue (per entry, per seller, Web-Lock-serialised) syncs exactly once. A
  counter-scoped service worker serves the page offline. An offline oversell is recorded and flagged, never dropped.
  #220 → `74ed305` and #460 → `2898d47`.
- **S4 · Payment links.** Products or a free amount (via a hidden per-seller product), single or multi-use, with
  expiry. `/pagar/<token>` pays on the shop's checkout; there is «Cobrar con un link» with WhatsApp, QR and a short
  link, plus three seller-agent MCP tools. #221 → `ba22692` and #461 → `8fd0046`.

## What went well
- **The lock disproved scope before any code.** The operating channel is per market, not per shop. A variant-less
  custom line would hide the order from its seller. The service worker had no fetch handler. Each became a decision
  instead of a bug.
- **Real-database CI found what local runs could not.** The money-path gate caught Medusa mapping a unique violation
  to `invalid_data`, the region provider check, and a missing marketplace-channel env. Each was found on the first run.
- **The fresh verifier found the bugs that mattered most:**
  - Stripe's provider trusted client session data, so free paid orders were possible on every Stripe cart.
  - The swapped-session exploit.
  - Two ways a queued offline sale could be lost.
  - A manual order closing a link before any money arrived.

## What we learned
- **Medusa's public store routes are a write surface for anyone holding an id.** Any server-built cart needs the
  server's own record (claim or link-cart tables), a lock on the public cart, payment-session and collection routes,
  and a completion hook. Codex rounds 5–9 on #218 and 3–9 on #221 were each a new form of this one fact.
- **A payment provider may only trust what the processor says, bound to its own session.** `data.status` written by
  whoever creates the session is not evidence (#219), and an approved payment id is not evidence for *this* cart.
- **The region decides which providers can complete a cart.** Medusa ≥ 2.20 refuses providers the region does not
  enable, and live «Pago directo» had silently lost its provider since about 2026-09-11.
- **Take a hold after the expensive step and release it on failure.** A hold taken early can be pinned by a request
  that fails later.
- **Idempotency through a native record beats a flag written after the side effect.** Line-item reservations closed
  the last double-decrement window that per-line "applied" flags left open.

## Gaps / follow-ups
- **Deployed 2026-10-31** on Daniel's go (Backend `ba22692`, Storefront `8fd0046`). Verified by behaviour: the routes
  answer as designed, and the `payment_link` migration ran on boot.
- **Owed to Daniel by name:**
  - the MX region repair run (`POST /internal/mx-region-payment-providers`, dry run first);
  - a check of Stripe Checkout sessions opened before the #219 deploy that have no order (expected zero). The check
    did not run before the deploy, so any such session is now refused at completion instead of being trusted;
  - the sweep for stuck «Pago directo» carts since about 2026-09-11;
  - the phone walkthroughs in sprint-1 to sprint-4;
  - the test-mode card QR and link payments;
  - one real low-value link charge.
- **Infrastructure.** Vercel's preview account is blocked, so PR preview shards cannot run.
- **Follow-ups:**
  - Mercado Pago approved-payment replay for **online** carts (closed for counter and link carts only).
  - An application check for US Stripe direct charges (today it rests on Express accounts having no API keys).
  - The «En persona» label derived from the claim instead of client-writable metadata.
  - An ML stock push after an offline oversell.
  - A rate limit on link-cart minting at the backend.
  - The open `offer_amount_cents` hole in `start-checkout` for ordinary carts (found at the lock).
