---
title: "Plan Tienda follow-ups: finish a partial pause, restore sweep, approval repair, US welcome email"
slug: plan-tienda-follow-ups
status: raw
area: "08"
type: chore
priority: null
risk: high
epic: null
build_order: null
updated: 2026-11-11
---

# Raw seed: Plan Tienda follow-ups

From the Plan Tienda retrospective (*Gaps / follow-ups*), not built at close (2026-11-11):

1. **A partial pause cannot be finished by asking again:** in the backend, paused → paused answers 409, so a pause
   or relink that stopped halfway needs a hand repair.
2. **No restore sweep:** a failed restore after a payment is not retried on its own.
3. **Transfer approval:** if the attribution write fails after the grants are written, the transfer shows
   approved but needs a hand repair.
4. **Two accepted races on the 20% upgrade share:** out-of-order invoices of the same price, and a package recorded
   in the milliseconds between re-check and confirm (about $30). Accepted at close; revisit if they occur.
5. **The US shop-created welcome email** still describes the old offer.

Not urgent: the first real pause can happen around mid-February 2027, when the first shops opened on 11 November end
their free months. The pause timer runs daily at 16:00 UTC (enabled 2026-11-11). Items 1–2 should land before then.
