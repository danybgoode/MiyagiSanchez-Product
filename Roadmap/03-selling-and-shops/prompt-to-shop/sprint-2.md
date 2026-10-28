---
epic: prompt-to-shop
sprint: 2
title: "Describe, shape, preview"
risk: high
phase: Shaping
stories_total: 5
stories:
  - id: S2.1
    title: "Draft → view-props adapter + presentational extraction"
    as_a: "the builder"
    i_want: "a pure adapter from a draft to the props the real storefront components take, and presentational halves of any component that fetches its own data"
    so_that: "the preview is the real shop, not a mock"
    risk: low
    status: done
  - id: S2.2
    title: "Describe box on /mx/vende and the /sell first run"
    as_a: "a merchant who just heard of Miyagi"
    i_want: "one box that says «Cuéntanos qué vendes» with three tappable examples, right where I land"
    so_that: "I start by describing, not by filling forms"
    risk: low
    status: in-progress
  - id: S2.3
    title: "Taking-shape screen"
    as_a: "a merchant who just tapped «Armar mi tienda»"
    i_want: "to watch my shop skeleton fill block by block with a narration line per step"
    so_that: "I trust something real is being made for me"
    risk: low
    status: in-progress
  - id: S2.4
    title: "Preview canvas: EJEMPLO cards, inline edits, versions counter"
    as_a: "a merchant looking at my new shop"
    i_want: "to change the name, pick one of three colour alternates, change the tone and ask for another version, with every change saved"
    so_that: "shaping it feels like play, and nothing is lost"
    risk: low
    status: in-progress
  - id: S2.5
    title: "View-only draft link"
    as_a: "a merchant who wants to show my draft to my partner before deciding"
    i_want: "«Compartir vista previa» that gives a link anyone can open but nobody can edit or keep"
    so_that: "I can get a second opinion without giving my shop away"
    risk: high
    status: in-progress
---
# Prompt-to-shop — Sprint 2: Describe, shape, preview

**Status:** ✅ merged + deployed (storefront #439 → `cd894f0`, live 2026-10-28). The phone walkthrough below is owed to Daniel.

## Stories

### Story 2.1 — Draft → view-props adapter + presentational extraction
**As** the builder, **I want** a pure adapter from a draft to the props the real storefront components take, and presentational halves of any component that fetches its own data, **so that** the preview is the real shop, not a mock.
**Acceptance:** The locking pass checks `ShopHeader`, `ShopHero`, `ShopIndexBody`, `WallFeed` and `ShopThemeShell` for internal fetches; where one fetches, its presentational half is extracted and the live shop keeps rendering identically (a visual check on one real shop). The adapter is pure and spec-covered.
**Risk:** low

### Story 2.2 — Describe box on /mx/vende and the /sell first run
**As** a merchant who just heard of Miyagi, **I want** one box that says «Cuéntanos qué vendes» with three tappable examples, right where I land, **so that** I start by describing, not by filling forms.
**Acceptance:** On a 375 px phone the box is above the fold on `/mx/vende`; `/sell` with no shop shows the same box. The no-JS marketing-surface spec still passes (substantive content + OG). Secondary links: «¿Ya tienes tu catálogo en un archivo?» and «Armar a mano». **The new hero line ships here, with the box** (moved from E2 `pricing-page` by Daniel, 2026-10-27, so the claim goes live with the feature): «Describe tu negocio. En segundos tienes tienda, compradores en el marketplace y una IA que la atiende — sin comisión.», replacing the anchor hero title and the `/mx/vende` metadata title/description in `locales/es.json` → `sellerAcquisition.anchor`.
**Risk:** low

### Story 2.3 — Taking-shape screen
**As** a merchant who just tapped «Armar mi tienda», **I want** to watch my shop skeleton fill block by block with a narration line per step, **so that** I trust something real is being made for me.
**Acceptance:** Narration within 1 s of the tap (Nombre ✓, Colores ✓, Textos ✓, Productos de ejemplo ✓); the skeleton is the real canvas, not a spinner; a failed block shows its fallback and says what to do next.
**Risk:** low

### Story 2.4 — Preview canvas: EJEMPLO cards, inline edits, versions counter
**As** a merchant looking at my new shop, **I want** to change the name, pick one of three colour alternates, change the tone and ask for another version, with every change saved, **so that** shaping it feels like play, and nothing is lost.
**Acceptance:** Every example product carries an EJEMPLO tag, an illustration (never photo-like), a suggested price and no Buy affordance; edits autosave with «Guardado» and survive reload; the versions counter reads «Te quedan 2 versiones»; the page is `noindex` and `Cache-Control: private`; a spec guards that JSON, CSV, prompt, agente, borrador, slug and SKU never appear on screens 1–3; the client-JS diet budget holds or its change is justified.
**Risk:** low

### Story 2.5 — View-only draft link
**As** a merchant who wants to show my draft to my partner before deciding, **I want** «Compartir vista previa» that gives a link anyone can open but nobody can edit or keep, **so that** I can get a second opinion without giving my shop away.
**Acceptance:** Decision a. A separate read-only token, never the device cookie; lives as long as the draft (7 days); `noindex`, `private`; the page shows the shop with no edit controls and no «Quedármela»; a spec proves a request with only the view token cannot edit, version or claim.
**Risk:** high

## Sprint QA
- **api spec(s):** a view-token spec (read only: edit, version and claim refused); the forbidden-word spec on screens 1–3; the adapter's pure spec
- **browser smoke owed:** yes, to Daniel: the phone walkthrough below on a real phone at 375 px
- **rails:** no-JS marketing-surface spec, Tailwind JIT arbitrary-value guard, emoji guard, es-MX copy completeness, client-JS diet budget
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. On a phone, open https://miyagisanchez.com/mx/vende
   → the describe box and three examples show above the fold
2. Tap the «Tamales» example, then «Armar mi tienda»
   → within 1 s the narration starts and the shop skeleton fills block by block
3. When it finishes, look at the products
   → each one says EJEMPLO, has an illustration and a suggested price, and has no buy button
4. Change the shop name and pick another colour, then reload the page
   → both changes are still there and «Guardado» showed after each
5. Tap «Otra versión»
   → a new version renders and the counter drops by one
6. Tap «Compartir vista previa» and open the link in a private window
   → the shop shows, with no edit controls and no «Quedármela»

If any step fails, note the step number + what you saw — that's the bug report.

### Results — 2026-10-28, production (`miyagi-web` at `cd894f0`)
- **Step 1 (partial) ✅** — `/mx/vende` serves the new hero line «Describe tu negocio. En segundos tienes tienda…» and the «Cuéntanos qué vendes» box. Whether it sits above the fold at 375 px is not checked (needs a phone).
- **Draft pages ✅** — an unknown `/p2s/<id>` and `/p2s/v/<token>` both return the friendly 404 with `cache-control: private, no-store`, `x-robots-tag: noindex, nofollow` and `cf-cache-status: DYNAMIC`.
- **Steps 2–6 — OWED to Daniel.** They need a real browser, because the Turnstile token comes only from the widget. The Chrome extension was not connected on 2026-10-28, and headless browsers do not get a token. These steps are also S1's owed generation smoke: SSE through Cloudflare and Caddy, latency, and the `via: vertex` log line.
- **Found, pre-existing:** `/mx/vende`'s `<title>` reads «… — Miyagi Sánchez | Miyagi Sánchez»; the layout template appends the brand a second time. The old title had the same pattern. To be fixed in S3.
- **Review:** the fresh verifier found two should-fixes and agy's general pass two more plus a nit; all are fixed and spec-guarded. The security lens is DARK: vibe stalls, and agy's fallback model cannot fit the 42-file diff. Said so on #439.
- **Folded in this wave:** the Supabase grants hardening (#438 → `bf71f79`, migrations `20261028120000` + `20261028130000`, verified live).
