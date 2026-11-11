---
title: "Measure AI cost per shop for a month"
slug: ai-cost-per-shop
status: raw
area: "08"
type: chore
priority: null
risk: low
epic: null
build_order: null
updated: 2026-11-11
---

# Raw seed: AI cost per shop

Decided with Daniel on 2026-11-09: Plan Tienda's AI allowance stays at 50 chat answers and 20 photos a month, and
we measure the real AI cost per shop for a month before revisiting it. The Plan Tienda retrospective records that
the cost is **not stored**, so the allowance still rests on a guess.

## What it needs

- Record the cost of each AI call (shop chat, photo enhancement, import, agent/MCP-driven work) against the shop
  and its plan, at the moment of the call.
- After a month, read the cost per shop for each plan (Tienda, Negocio, trial, legacy Gratis) against what the plan
  brings in. Then decide whether the allowances move.
- Three states, never two: «not measured» must not read as «costs nothing».
