# Own-shop positioning: the site says what Miyagi Sánchez is now — Retrospective

_Closed: 2026-11-11_
_Intent: owed_
_Quote vs actual: $27–40 (M, n=3) → not measured on this machine (—)_
_Crew (actual): Opus 5.5 orchestrator · one Sonnet 5.5 builder for all three sprints · reviewers: deterministic gate (low risk, no security path) · prose: the builder — the copy-bank log and the prose rail (D7) were not run._

## What shipped
- **S1 · The definition** — `lib/about-content.ts` (es + en) leads with «Miyagi Sánchez es tu propia tienda en línea, armada contigo, sin comisión por venta.» `/acerca`, `/agent`, `llms.txt`, the UCP manifest and `about_miyagi` inherit it, and «P2P» and «marketplace nativo» are gone. Every CTA reads «Abrir mi tienda» and points at the shop builder. The Vecindario moved to the footer and appears as one benefit line. The support block names the promoter, on their own WhatsApp, and the merchant's AI agent.
- **S2 · Six features** — `lib/shop-features.ts` covers omnichannel, finances, offers and haggling, AI, sorteos and «pon tu negocio en línea». They appear on `/`, `/acerca` and the agent surfaces, and `/mx/precios` gets «Qué incluye tu tienda».
- **S3 · Ten business-type pages** — inmuebles, comida, imprentas, vestidos-de-novia, plomeria, ropa-interior-mayoreo, materiales-e-interiorismo, bazar, plus autos and servicios. Each has its own OG image and canonical, and a demo shop labelled «Ejemplo». The proof slot stays empty until a real shop consents.
- Storefront #492 `0616a71`, deployed. 55/55 specs pass against production, and `llms.txt` has no «P2P».

## What went well
- One source fans out to five agent surfaces, so the definition changed in one place.
- Cloudflare does not cache these pages (BYPASS/DYNAMIC), so no purge was needed.

## What we learned
- CodeQL flags regex-based HTML stripping even in a test helper. An index scan satisfies it and reads more clearly.

## Gaps / follow-ups
- **Owed to Daniel:** a phone walkthrough of the header, footer, `/acerca` and two business-type pages; an AI ask-test («¿qué es miyagisanchez.com?»); the Intent answer.
- **Calls for Daniel:** the servicios page still says «Publicar mi servicio», and the English `/en` and `/us` CTAs are unchanged.
- **Not done:** the copy-bank log and the prose-rail pass on the merchant copy (D7).
