---
epic: business-infrastructure
sprint: 5
title: "Handoff that learns"
risk: high
phase: Shaping
stories_total: 1
stories:
  - id: S5.1
    title: "Handoff that learns"
    as_a: "a merchant whose shop could not answer a buyer"
    i_want: "the question sent to me, my reply emailed to the buyer, and my reply saved as a frequent question"
    so_that: "I answer each question once and the shop answers it next time"
    risk: high
    status: planned
---
# Business infrastructure — Sprint 5: Handoff that learns

**Status:** ⬜ not started

## Build contract (locked by the architect before the builder started)
Cite D17. Migration **M2** (`shop_chat_threads`, service role only, REVOKE `PUBLIC, anon, authenticated`) applied by
the orchestrator before the PR merges. `leave_message` validates an email and a question, writes one thread, and
dispatches to the seller (`dispatchToSeller`, group `mensajes`) with the transcript; new senders registered in
`COMMUNICATION_CATALOG`. The seller page `/shop/manage/preguntas` reads only the seller's own threads (resolved from
`auth()`, never the body). Reply: conditional update `open → answered` with `.select()` back, THEN the email
(validate → claim → apply). «Guardar como pregunta frecuente» goes through `applyStoreConfig` (`content.faq`, the
existing validator and its 12-item cap — a full FAQ says so). The monthly cron nulls `buyer_email` 90 days after
`answered_at`.

## Stories

### Story 5.1 — Handoff that learns
**As a** merchant whose shop could not answer a buyer, **I want** the question sent to me, my reply emailed to the
buyer, and my reply saved as a frequent question, **so that** I answer each question once and the shop answers it next
time.
**Acceptance:** leaving a message alerts the merchant on their channels; `/shop/manage/preguntas` lists it; replying
emails the buyer once (a double tap sends one email); one tap adds it to the FAQ and the chat answers it next time;
another seller cannot see or answer it; buyer emails are purged 90 days after the reply.
**Risk:** high (PII, email, authorization)

## Sprint QA
- **api spec(s):** `e2e/shop-chat-handoff.spec.ts` (order: validate → claim → send; ownership; double reply; FAQ cap;
  purge selection).
- **browser smoke owed:** yes, to Daniel — leave a message as a buyer, answer it as the merchant (authed).
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green; M2 verified live.

## Sprint 5 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. On your shop's chat, ask something it cannot answer and leave your email.
   → It confirms the shop will write back.
2. (auth — owed to Daniel) Check your Telegram or email as the merchant.
   → The question arrives with the conversation.
3. (auth — owed to Daniel) Open https://miyagisanchez.com/shop/manage/preguntas and reply.
   → The buyer email receives your answer once.
4. Tap «Guardar como pregunta frecuente», then ask the chat the same question again.
   → It now answers with your reply.

If any step fails, note the step number + what you saw — that's the bug report.
