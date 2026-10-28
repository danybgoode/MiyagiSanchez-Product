---
epic: prompt-to-shop
sprint: 1
title: "Generation rail"
risk: high
phase: Building
stories_total: 4
stories:
  - id: S1.1
    title: "shop_drafts + ai_allowance migration and conditional-increment RPC"
    as_a: "the platform"
    i_want: "an anonymous shop draft store and a usage ledger whose spend is one conditional write"
    so_that: "a merchant can see their shop before signup and a double tap can never spend an allowance twice"
    risk: high
    status: done
  - id: S1.2
    title: "Pure generation planner, prompts and per-block validation"
    as_a: "the builder"
    i_want: "a pure `lib/prompt-to-shop/` seam that turns one description into three structured Gemini calls (identity → words → example catalog) and validates each block"
    so_that: "generation is tested without the network and always lands a valid `MiyagiSetupFile`"
    risk: low
    status: done
  - id: S1.3
    title: "POST /api/p2s/drafts + SSE block stream + device cookie"
    as_a: "a merchant on a phone"
    i_want: "to send one description and receive my shop in three narrated blocks"
    so_that: "I watch it take shape instead of waiting on a spinner"
    risk: high
    status: in-progress
  - id: S1.4
    title: "Rate limits, Turnstile, daily budget"
    as_a: "the platform"
    i_want: "the public describe box protected by per-IP and per-device limits, a Cloudflare Turnstile check and a global daily generation budget"
    so_that: "inference cost is bounded and bots cannot spend it"
    risk: high
    status: in-progress
---
# Prompt-to-shop — Sprint 1: Generation rail

**Status:** 🟡 merged + deployed (storefront #436 → `2ae4b25`, live 2026-10-28); migration `20261027120000` applied + verified live. Generation smoke owed: blocked on `GEMINI_API_KEY` + Turnstile keys, which are not yet on the VM.

## Stories

### Story 1.1 — shop_drafts + ai_allowance migration and conditional-increment RPC
**As** the platform, **I want** an anonymous shop draft store and a usage ledger whose spend is one conditional write, **so that** a merchant can see their shop before signup and a double tap can never spend an allowance twice.
**Acceptance:** Two Supabase tables (non-commerce staging, AGENTS rule 2): `shop_drafts` (id, device_id, setup JSON per block, version count, view token, `claimed_by`, `expires_at` 7 days) and `ai_allowance` (subject = device or Clerk user, kind = `version` | `photo`, period, count). A Postgres function increments only under the cap and returns the new count or nothing; two concurrent calls at count 2 of 3 spend at most one. The **orchestrator applies** the migration via Supabase MCP (never `db push`), realigns `schema_migrations` and verifies live. A pure spec on the allowance decision is observed failing under a mutation.
**Risk:** high

### Story 1.2 — Pure generation planner, prompts and per-block validation
**As** the builder, **I want** a pure `lib/prompt-to-shop/` seam that turns one description into three structured Gemini calls (identity → words → example catalog) and validates each block, **so that** generation is tested without the network and always lands a valid `MiyagiSetupFile`.
**Acceptance:** Prompts ground on `EXAMPLE_SETUP`; each block passes `validateSetup` / `validateRows`; example rows are marked `example: true` with a suggested price and an illustration key, never a photo URL. A failed block retries once, then falls back to a safe default block, and the stream says so. Specs cover the planner, the block merge and the example marking; each observed red once.
**Risk:** low

### Story 1.3 — POST /api/p2s/drafts + SSE block stream + device cookie
**As** a merchant on a phone, **I want** to send one description and receive my shop in three narrated blocks, **so that** I watch it take shape instead of waiting on a spinner.
**Acceptance:** A POST with a description (≤ 500 characters) sets an httpOnly device cookie, creates the draft, and streams exactly three block events plus a done event; each block is saved before it is sent. A new version re-runs the calls against the same draft and spends one allowance. The route is `dynamic`, `Cache-Control: private`. No Medusa write. Tokens per block are logged for cost tuning. The locking pass confirms `responseSchema` support and per-call latency on `gemini-3.5-flash` against the 20 s narration budget.
**Risk:** high

### Story 1.4 — Rate limits, Turnstile, daily budget
**As** the platform, **I want** the public describe box protected by per-IP and per-device limits, a Cloudflare Turnstile check and a global daily generation budget, **so that** inference cost is bounded and bots cannot spend it.
**Acceptance:** New `LimitKey`s in `lib/ratelimit.ts`; Turnstile verified server-side before any Gemini call (Decision b; `TURNSTILE_SITE_KEY` / `TURNSTILE_SECRET_KEY` added to the VM env by the orchestrator); `P2S_DAILY_BUDGET` defaults to 300 (Decision c). A 4th version from one device is refused with the allowance message and no Gemini call; an exhausted budget closes the box with «Hoy ya armamos muchas tiendas. Vuelve mañana o déjanos tu correo.»; a missing Turnstile secret fails **closed**.
**Risk:** high

## Sprint QA
- **api spec(s):** `e2e/p2s-drafts.spec.ts` (three block events, the 4th version refused with no Gemini call, budget closed, Turnstile missing → refused); pure specs `lib/prompt-to-shop/*.test.ts` (planner, block validation, allowance decision), each observed failing under a deliberate mutation
- **browser smoke owed:** no UI this sprint; the API smoke below is the orchestrator's
- **migration:** applied by the orchestrator (Supabase MCP), `schema_migrations` realigned, tables and the RPC verified live
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge

## Sprint 1 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com   (or the preview URL while testing pre-merge)

1. Run `curl -N -X POST https://miyagisanchez.com/api/p2s/drafts` with a JSON body `{"description":"Vendo tamales de masa madre en Puebla, por pedido"}` and a valid Turnstile token
   → three `block` events (identity, words, catalog) and a `done` event arrive within 20 s; the identity block names a shop
2. Repeat step 1 three more times with the same cookie jar
   → the 4th response is the allowance message, and the server log shows no Gemini call for it
3. Repeat step 1 without a Turnstile token
   → refused with a friendly message; no draft row is created
4. (orchestrator) In Supabase, select the newest `shop_drafts` row
   → one row with three saved blocks, `claimed_by` null, `expires_at` 7 days out; no new Medusa seller or product exists

If any step fails, note the step number + what you saw — that's the bug report.

### Results — 2026-10-28, production (`miyagi-web` at `2ae4b25`)
- **Step 3 ✅** — a POST without a Turnstile token returned 403 «No pudimos verificar que eres tú…». It was `private, no-store` and `cf-cache-status: DYNAMIC`. The log line was `[p2s] {"event":"turnstile_refused","reason":"not_configured"}`, and `shop_drafts` and `ai_allowance` both held 0 rows afterwards. A 500-plus or empty description returned 400 with the friendly copy; GET returned 405.
- **Step 4 (partial) ✅** — the migration was verified live inside a transaction that rolled back: spends 1–3 ok, the 4th refused `allowance`; a budget refusal gave the version back; a stale-version save was rejected; `block_status` merged; `expires_at` 7 days out. RLS is on, and anon/authenticated hold no table grants and no EXECUTE on any of the four functions.
- **Steps 1, 2 and the rest of 4 — OWED.** They need `GEMINI_API_KEY`, `TURNSTILE_SITE_KEY` and `TURNSTILE_SECRET_KEY` in `/opt/miyagi/infra/oci/web.env`; none is set, and `P2S_DAILY_BUDGET='300'` is. The route fails closed until they land. Once they do, also settle: (a) whether the `gemini-3.5-flash` default is a real model (a 404 shows as `error` in `[p2s] block` and as `status: fallback`), (b) latency against the 20 s budget, (c) whether SSE frames arrive unbuffered through Cloudflare and Caddy.
- **Follow-up #437 → `2c1a591`, deployed 2026-10-28.** The first real generation found that every identity fell back: default thinking used up the 1024-token cap. Minimal thinking fixed it: all blocks `ok` first time, 6.6 s and 7.4 s through Vertex. The Gemini path now runs through **Vertex** on the credited project when `GOOGLE_VERTEX_SA_JSON` is set; it is set, and it parses in the live container. `GEMINI_API_KEY` and both Turnstile keys are also set now, and `gemini-3.5-flash` exists (200).
- **Still owed for steps 1–2:** a real Turnstile token comes only from the widget, and that ships in S2's describe box. So the browser generation smoke, including SSE through Cloudflare, runs at S2's smoke.
- The fresh verifier ran two rounds, plus agy (general), agy and vibe (security); every finding is fixed or answered on #436. Codex was at its usage cap.
