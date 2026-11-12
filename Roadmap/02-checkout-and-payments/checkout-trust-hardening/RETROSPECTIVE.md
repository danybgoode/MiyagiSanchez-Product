# Checkout trusts nothing the caller names — Retrospective

_Closed: 2026-11-12_
_Intent: owed_
_Quote vs actual: $5–40 (S, n=0, wide) → not measured on this machine (—)_
_Crew (actual): Opus 5.5 orchestrator · one Sonnet 5.5 builder · reviewers: fresh pr-reviewer, codex gpt-6-luna @ xhigh general, agy security (once its pin was bumped to 1.5.6; it could not fit the final diffs) · prose: the builder._

## What shipped
- **S1.1 · Signed shipping rates.** `/store/envia/rates` signs every rate (HKDF from `JWT_SECRET`, binding rate id, carrier, service, amount, currency, product ids, postcode and a 30-minute expiry). `start-checkout` charges only a valid signature that matches the cart, else «Vuelve a elegir el envío.», and the storefront re-quotes once instead of looping. **The delivery method is now checked server-side** against what the listing offers (`buildDeliveryCatalog`), so a ship-only product can't be checked out as "no delivery".
- **S1.2 · $0 refusal in the backend** on the final amount, with a coupon-specific message.
- **S1.3 · One checkout per accepted offer.** `checkout_reserved_at` (migration `20261111020000`, applied live) is claimed with a conditional update that is read back. Offer sessions last 31 minutes, the reservation 36, and a manual-payment checkout reserves the offer for good. The older card and Mercado Pago offer routes now also require the signed-in buyer and the reservation.
- **S1.4 · Review rail.** `securityPaths` now matches every `*checkout*` path (`f8e3bf7`).
- Backend #233 `f0ef512` and storefront #495 `856b925` deployed together in one `update.sh`.

## What went well
- `JWT_SECRET` was confirmed `SET` by Daniel before the deploy: one command that printed one word, never the secret.
- Two premises were proven before relying on them. A live read-only PostgREST query showed that two `or=` filters are ANDed. The builder STOPPED when the existing offer columns turned out to be in use, and a new column replaced the planned reuse.

## What we learned
- GitHub can leave runs `queued` with zero jobs for hours while cancel reports them "completed". An empty commit creates fresh runs and unsticks it.
- A quote signature has to bind what the PRICE depends on. Our rates ignore quantity, so binding quantity would not have mattered until the quote counts units (seeded).

## Gaps / follow-ups
- **Owed to Daniel:**
  - the first real shipped checkout after Envía or Correos is enabled for a seller (carrier rates are off platform-wide today, so signed rates have not been seen live);
  - one offer checkout opened in two tabs;
  - the Intent answer.
- **Follow-ups:**
  - seed `quantity-aware-shipping-quotes`;
  - the offer's own Stripe pay link created at accept time is a third path, not gated by the reservation;
  - no route-level integration test for rates → start-checkout.
