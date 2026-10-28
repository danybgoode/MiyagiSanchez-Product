# Pricing page — Retrospective

_Closed: 2026-10-28_
_Intent: yes | mostly | no_
<!-- Did we build what the product owner meant? One word, THEIR answer: yes, mostly or no. Required by `epic-dod` only
     when the epic's seed or README carries a numeric `intent_match:` (intent-match D17); the calibration learns from
     it. Keep the line and leave exactly one of the three words between `_Intent: ` and the closing underscore. -->
<!-- OWED: Daniel's one-word answer. The builder does not fill this in. -->
_Quote vs actual: $20–120 (M, n=1, wide) → ≈$29 (−76% vs the quote's top)_
_Crew (actual): claude-opus-5-5 ≈$29 (orchestrator + builder, both sprints) · reviewers: fresh `pr-reviewer` ×2, agy gemini-3.8-flash-high ×4 (codex capped every time) · prose: the builder — one session built both sprints in place; the plan's codex general pass never ran (usage cap), so the family-independent read was agy_

## What shipped
- **S1 · One price source + `/mx/precios`** — storefront #445 → `ebef359`, deployed and verified live 2026-10-28.
  `lib/pricing-catalog.ts` (pure) + `lib/pricing-catalog-server.ts` (bounded, cached admin reads). `/mx/precios`:
  free forever · extras with real prices («Precio a cotizar» when unset) · Stripe / Mercado Pago / SPEI with sources ·
  compare · FAQ; OG image, JSON-LD offers for fixed prices, sitemap. `/acerca`, `/agent`, `llms.txt`, the UCP manifest's
  about block and MCP about resource read the catalog through `{token}`s. Footer «Precios» (MX only), `/mx/vende`
  callout, comparador back-link, `precios_*` events. A source-sweep spec bans typed MXN prices in public copy.
- **S2 · T1 in the comparador** — storefront #446 → `78e73d2`. T1 Básico/Avanzado, T1pagos or external gateway (T1's
  cut + the gateway's own fee), every figure cited to t1.com (2026-10-28); `/mx/precios` opens the comparador on T1.

## What went well
- **The lock disproved five premises before any code** (admin prices are promoter discounts; `/acerca` renders the
  locales, not `about-content.ts`, and the two had drifted; the type name; the analyze route is a URL detector; no
  migration). Each would have produced a confident wrong build.
- **The source-sweep spec earned its keep on day one** — it found two more hand-typed prices the lock had not
  listed (the promoter sales scripts, one also calling a yearly renewal «pago único»).
- **The fresh reviewer was the review that mattered both times** — 4 deterministic blockers on S1, an honesty bug
  and a red lint gate on S2. The four agy passes said "clean" each time.

## What we learned
- Claiming "existing specs green" from a targeted subset was wrong; the full `api` project is a one-minute run and
  caught four cross-cutting invariants (promoted to `LEARNINGS.md`).
- A competitor's pricing must be read from the **rendered** page: T1's served HTML and the October press both
  disagreed with the live table (free plan cannot transact; the external charge is an alternative plus the
  gateway's fee). Promoted.
- A comparison's alternative path must include every party's fee — T1's external path first flattered T1 by
  ~$700/mo. Promoted; the same gap exists for Tiendanube.
- D6 assumed `/mx/precios` could be static with `revalidate`; every `app/(shell)` route renders per request and
  `revalidate-truth` rejects the export. The lock should check the route group, not just the page.

## Gaps / follow-ups
- **Owed to Daniel:** both sprints' phone walkthroughs (`sprint-1.md`, `sprint-2.md`); the `_Intent:` line above.
- **Follow-up:** hand-typed SKU prices in `app/api/ucp/manifest/route.ts`, `app/api/ucp/mcp/route.ts` and
  `lib/{subdomain,ml-sync}-billing.ts` → move to the catalog and extend the sweep's enforced paths.
- **Follow-up:** Tiendanube's external-gateway path omits the gateway's own fee (A3's fix, not yet applied to TN).
- **Follow-up:** MCP `compare_costs`, the manifest description and `/agent` copy list four platforms, not T1.
- **Descoped:** T1 shop-URL detection (no verifiable storefront marker); SPEI in the T1 model.
- The print ad shows «Precio a cotizar» until a print edition is `open`; the page picks up a price within ~5 min.
